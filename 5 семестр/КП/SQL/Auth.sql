CREATE OR REPLACE PACKAGE pkg_auth IS
     PROCEDURE change_password(
        p_username     IN VARCHAR2,
        p_old_password IN VARCHAR2,
        p_new_password IN VARCHAR2
    );

    PROCEDURE login_user(
        p_username IN VARCHAR2,
        p_password IN VARCHAR2,
        p_role OUT VARCHAR2
    );

    PROCEDURE register_user(
        p_username   IN VARCHAR2,
        p_password   IN VARCHAR2,
        p_first_name IN VARCHAR2,
        p_last_name  IN VARCHAR2,
        p_email      IN VARCHAR2,
        p_phone      IN VARCHAR2 DEFAULT NULL,
        p_dob        IN DATE DEFAULT NULL
    );

END pkg_auth;


CREATE OR REPLACE PACKAGE BODY pkg_auth IS
    -- Вспомогательная: возвращает RAW(16) случайной соли
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

    ----------------------------------------------------------------
    PROCEDURE change_password(
        p_username     IN VARCHAR2,
        p_old_password IN VARCHAR2,
        p_new_password IN VARCHAR2
    ) IS
        v_salt       RAW(16);
        v_hash       VARCHAR2(200);
        v_new_hash   VARCHAR2(200);
    BEGIN

        SELECT password_salt, password_hash
        INTO v_salt, v_hash
        FROM users
        WHERE username = p_username;

        IF hash_pwd(p_old_password, v_salt) != v_hash THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: старый пароль неверный.');
        END IF;

        v_salt := gen_salt();
        v_new_hash := hash_pwd(p_new_password, v_salt);

        UPDATE users
        SET password_salt = v_salt,
            password_hash = v_new_hash,
            must_change_password = 'N'
        WHERE username = p_username;

        COMMIT;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: пользователь не найден.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка смены пароля: ' || SQLERRM);
    END change_password;

    ----------------------------------------------------------------
    -- Логин пользователя
    ----------------------------------------------------------------
    PROCEDURE login_user(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_role     OUT VARCHAR2
) IS
    v_user_id   NUMBER;
    v_hash      VARCHAR2(200);
    v_salt      RAW(16);
    v_status    users.is_active%TYPE;
    v_must      CHAR(1);
    v_role      users.role_name%TYPE;
    v_client_id NUMBER := NULL;
    v_coach_id  NUMBER := NULL;
BEGIN
    -- Обнуляем роль заранее
    p_role := NULL;

    SELECT user_id,
           password_hash,
           password_salt,
           role_name,
           is_active,
           must_change_password
    INTO v_user_id,
         v_hash,
         v_salt,
         v_role,
         v_status,
         v_must
    FROM users
    WHERE username = p_username;

    IF v_status = 'N' THEN
        RAISE_APPLICATION_ERROR(-20010, 'Аккаунт заблокирован');
    END IF;

    IF v_hash IS NULL OR v_salt IS NULL THEN
        RAISE_APPLICATION_ERROR(-20011, 'Пароль не установлен');
    END IF;

    IF hash_pwd(p_password, v_salt) != v_hash THEN
        RAISE_APPLICATION_ERROR(-20012, 'Неверный пароль');
    END IF;

    IF v_must = 'Y' THEN
        RAISE_APPLICATION_ERROR(-20013, 'Требуется смена пароля');
    END IF;

    IF v_role = 'ROLE_CLIENT' THEN
        SELECT client_id INTO v_client_id
        FROM clients WHERE user_id = v_user_id;
    ELSIF v_role = 'ROLE_TRAINER' THEN
        SELECT coach_id INTO v_coach_id
        FROM coaches WHERE user_id = v_user_id;
    END IF;

    pkg_security.set_auth_context(
        p_user_id    => v_user_id,
        p_role       => v_role,
        p_client_id  => v_client_id,
        p_trainer_id => v_coach_id
    );

    -- ТОЛЬКО ЗДЕСЬ возвращаем роль
    p_role := v_role;

EXCEPTION
    WHEN OTHERS THEN
        p_role := NULL; -- 🔐 гарантированно
        RAISE;
END login_user;



    ----------------------------------------------------------------
    -- Регистрация пользователя (клиент через интерфейс)
    ----------------------------------------------------------------
    PROCEDURE register_user(
        p_username   IN VARCHAR2,
        p_password   IN VARCHAR2,
        p_first_name IN VARCHAR2,
        p_last_name  IN VARCHAR2,
        p_email      IN VARCHAR2,
        p_phone      IN VARCHAR2 DEFAULT NULL,
        p_dob        IN DATE DEFAULT NULL
    ) IS
        v_count   NUMBER;
        v_count_client NUMBER;
        v_salt    RAW(16);
        v_hash    VARCHAR2(200);
        v_user_id NUMBER;
    BEGIN
        pkg_security.assert_self_registration;
        
        IF LENGTH(p_password) < 8 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: пароль должен быть не короче 8 символов.');
        END IF;
        
        v_salt := gen_salt();
        v_hash := hash_pwd(p_password, v_salt);
        
        -- Проверка на существование
        SELECT COUNT(*)
        INTO v_count
        FROM users
        WHERE username = p_username;
        
        SELECT COUNT(*)
        INTO v_count_client
        FROM clients
        WHERE email = p_email;
        
        IF v_count > 0 AND v_count_client > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: пользователь уже существует.');
        END IF;
    
        -- 1. USERS
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
            'ROLE_CLIENT',
            'Y',
            'N'
        )
        RETURNING user_id INTO v_user_id;
    
        INSERT INTO clients (
            user_id,
            first_name,
            last_name,
            phone_number,
            email,
            date_of_birth
        ) VALUES (
            v_user_id,
            p_first_name,
            p_last_name,
            p_phone,
            p_email,
            p_dob
        );
    
        COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка регистрации: ' || SQLERRM);
    END register_user;

END pkg_auth;



DROP PACKAGE pkg_auth;






    PROCEDURE register_trainer(
        p_username        IN VARCHAR2,
        p_password        IN VARCHAR2,
        p_first_name      IN VARCHAR2,
        p_last_name       IN VARCHAR2,
        p_email           IN VARCHAR2,
        p_phone           IN VARCHAR2 DEFAULT NULL,
        p_specialization  IN VARCHAR2 DEFAULT NULL
    );

    PROCEDURE register_admin(
        p_username   IN VARCHAR2,
        p_password   IN VARCHAR2
    );
    
    PROCEDURE register_trainer(
        p_username        IN VARCHAR2,
        p_password        IN VARCHAR2,
        p_first_name      IN VARCHAR2,
        p_last_name       IN VARCHAR2,
        p_email           IN VARCHAR2,
        p_phone           IN VARCHAR2 DEFAULT NULL,
        p_specialization  IN VARCHAR2 DEFAULT NULL
    ) IS
        v_user_count  NUMBER;
        v_email_count NUMBER;
        v_salt        RAW(16);
        v_hash        VARCHAR2(200);
        v_user_id     NUMBER;
    BEGIN
        -- Проверка уникальности username
        SELECT COUNT(*)
        INTO v_user_count
        FROM users
        WHERE username = p_username;
    
        IF v_user_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20020, 'Пользователь с таким логином уже существует.');
        END IF;
    
        -- Проверка уникальности email тренера
        SELECT COUNT(*)
        INTO v_email_count
        FROM coaches
        WHERE email = p_email;
    
        IF v_email_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20021, 'Тренер с таким email уже существует.');
        END IF;
    
        -- Генерация соли и хэша
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
            'ROLE_TRAINER',
            'Y',
            'N'
        )
        RETURNING user_id INTO v_user_id;
    
        INSERT INTO coaches (
            user_id,
            first_name,
            last_name,
            phone_number,
            email,
            specialization
        ) VALUES (
            v_user_id,
            p_first_name,
            p_last_name,
            p_phone,
            p_email,
            p_specialization
        );
    
        COMMIT;
    
        DBMS_OUTPUT.PUT_LINE('Тренер успешно зарегистрирован.');
    
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(
                -20022,
                'Ошибка регистрации тренера: ' || SQLERRM
            );
    END register_trainer;

    PROCEDURE register_admin(
        p_username   IN VARCHAR2,
        p_password   IN VARCHAR2
    ) IS
        v_count   NUMBER;
        v_salt    RAW(16);
        v_hash    VARCHAR2(200);
        v_user_id NUMBER;
    BEGIN
        
        v_salt := gen_salt();
        v_hash := hash_pwd(p_password, v_salt);
        
        -- Проверка на существование
        SELECT COUNT(*)
        INTO v_count
        FROM users
        WHERE username = p_username;
         
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20020, 'Пользователь уже существует.');
        END IF;
    
        -- 1. USERS
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
            'ROLE_ADMIN',
            'Y',
            'N'
        )
        RETURNING user_id INTO v_user_id;
    
        COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(
                -20021,
                'Ошибка регистрации: ' || SQLERRM
            );
    END register_admin;
    
    