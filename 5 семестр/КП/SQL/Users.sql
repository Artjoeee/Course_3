CREATE OR REPLACE PACKAGE pkg_users_admin IS

    PROCEDURE add_user(
        p_username   IN VARCHAR2,
        p_role_name  IN VARCHAR2,
        p_password   IN VARCHAR2
    );


    PROCEDURE add_user_with_role(
        p_username        IN VARCHAR2,
        p_role_name       IN VARCHAR2,
        p_password        IN VARCHAR2,
        p_first_name      IN VARCHAR2,
        p_last_name       IN VARCHAR2,
        p_email           IN VARCHAR2,
        p_phone           IN VARCHAR2 DEFAULT NULL,
        p_dob             IN DATE DEFAULT NULL,
        p_specialization  IN VARCHAR2 DEFAULT NULL
    );


    PROCEDURE block_user(p_user_id IN NUMBER);
    PROCEDURE unblock_user(p_user_id IN NUMBER);
    PROCEDURE change_role(p_user_id IN NUMBER, p_role_name IN VARCHAR2);
    PROCEDURE get_user_info(p_user_id IN NUMBER);

END pkg_users_admin;



CREATE OR REPLACE PACKAGE BODY pkg_users_admin IS

    FUNCTION gen_salt RETURN RAW IS
    BEGIN
        RETURN DBMS_CRYPTO.RANDOMBYTES(16);
    END;

    -- Вспомогательная: хэширует пароль+соль и возвращает HEX строку
    FUNCTION hash_pwd(p_password VARCHAR2, p_salt RAW) RETURN VARCHAR2 IS
        v_hash RAW(32);
    BEGIN
        v_hash := DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(p_password || p_salt), DBMS_CRYPTO.HASH_SH256);
        RETURN RAWTOHEX(v_hash);
    END;
    
    
    -- 1. Создание пользователя (с временным паролем)
    PROCEDURE add_user(
        p_username   IN VARCHAR2,
        p_role_name  IN VARCHAR2,
        p_password   IN VARCHAR2
    ) IS
        v_salt RAW(16);
        v_hash VARCHAR2(64);
    BEGIN
        pkg_security.assert_admin;
    
        -- запрет создания администратора
        IF p_role_name = 'ROLE_ADMIN' THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: создание пользователей с ролью администратора запрещено.');
        END IF;
    
        -- базовая валидация пароля
        IF LENGTH(p_password) < 8 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: пароль должен быть не короче 8 символов.');
        END IF;
    
        v_salt := gen_salt();
        v_hash := hash_pwd(p_password, v_salt);
    
        INSERT INTO users (
            username,
            password_hash,
            password_salt,
            role_name,
            is_active,
            must_change_password
        ) VALUES (
            p_username,
            v_hash,
            v_salt,
            p_role_name,
            'Y',
            'Y'
        );
    
        COMMIT;
    
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: пользователь с таким логином уже существует.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка создания пользователя: ' || SQLERRM);
    END add_user;


    -- 2. Создание пользователя + профиль (клиент/тренер)
    PROCEDURE add_user_with_role(
        p_username        IN VARCHAR2,
        p_role_name       IN VARCHAR2,
        p_password        IN VARCHAR2,
        p_first_name      IN VARCHAR2,
        p_last_name       IN VARCHAR2,
        p_email           IN VARCHAR2,
        p_phone           IN VARCHAR2 DEFAULT NULL,
        p_dob             IN DATE DEFAULT NULL,
        p_specialization  IN VARCHAR2 DEFAULT NULL
    ) IS
        v_user_id NUMBER;
    BEGIN
        pkg_security.assert_admin;
    
        -- запрет создания администратора
        IF p_role_name = 'ROLE_ADMIN' THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: нельзя создать администратора через данную процедуру.');
        END IF;
    
        -- 1. создаём пользователя
        add_user(
            p_username  => p_username,
            p_role_name => p_role_name,
            p_password  => p_password
        );
    
        -- 2. получаем user_id
        SELECT user_id
        INTO v_user_id
        FROM users
        WHERE username = p_username;
    
        -- 3. создаём профиль
        IF p_role_name = 'ROLE_CLIENT' THEN
            pkg_clients_admin.add_client(
                v_user_id,
                p_first_name,
                p_last_name,
                p_phone,
                p_email,
                p_dob
            );
        ELSIF p_role_name = 'ROLE_TRAINER' THEN
            pkg_trainers_admin.add_trainer(
                v_user_id,
                p_first_name,
                p_last_name,
                p_phone,
                p_email,
                p_specialization
            );
        ELSE
            DBMS_OUTPUT.PUT_LINE('Ошибка: недопустимая роль пользователя.');
        END IF;
    
        COMMIT;
    
        DBMS_OUTPUT.PUT_LINE('Пользователь успешно создан.');
    
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка создания пользователя с ролью: ' || SQLERRM);
    END add_user_with_role;


    -- 3. Блокировка пользователя
    PROCEDURE block_user(p_user_id IN NUMBER) IS
    BEGIN
        pkg_security.assert_admin;

        UPDATE users
        SET is_active = 'N'
        WHERE user_id = p_user_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: пользователь не найден.');
        END IF;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка блокировки: ' || SQLERRM);
    END block_user;


    -- 4. Разблокировка пользователя
    PROCEDURE unblock_user(p_user_id IN NUMBER) IS
    BEGIN
        pkg_security.assert_admin;

        UPDATE users
        SET is_active = 'Y'
        WHERE user_id = p_user_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: пользователь не найден.');
        END IF;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка разблокировки: ' || SQLERRM);
    END unblock_user;


    -- 5. Изменение роли пользователя
    PROCEDURE change_role(
        p_user_id   IN NUMBER,
        p_role_name IN VARCHAR2
    ) IS
    BEGIN
        pkg_security.assert_admin;
    
        -- Запрет назначения роли администратора
        IF p_role_name = 'ROLE_ADMIN' THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: назначение роли администратора запрещено.');
        END IF;
    
        -- Дополнительная валидация роли
        IF p_role_name NOT IN ('ROLE_CLIENT', 'ROLE_TRAINER') THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: недопустимая роль пользователя.');
        END IF;
    
        UPDATE users
        SET role_name = p_role_name
        WHERE user_id = p_user_id;
    
        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: пользователь не найден.');
        END IF;
    
        COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка изменения роли: ' || SQLERRM);
    END change_role;


    -- 6. Получение информации о пользователе
    PROCEDURE get_user_info(p_user_id IN NUMBER) IS
        v_username users.username%TYPE;
        v_role     users.role_name%TYPE;
        v_status   users.is_active%TYPE;
        v_must     users.must_change_password%TYPE;
    BEGIN
        pkg_security.assert_admin;

        SELECT username, role_name, is_active, must_change_password
        INTO v_username, v_role, v_status, v_must
        FROM users
        WHERE user_id = p_user_id;

        DBMS_OUTPUT.PUT_LINE(
            'User: ' || v_username ||
            ', Role: ' || v_role ||
            ', Active: ' || v_status ||
            ', Must change password: ' || v_must
        );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Пользователь не найден.');
    END get_user_info;

END pkg_users_admin;



DROP PACKAGE pkg_users_admin;
