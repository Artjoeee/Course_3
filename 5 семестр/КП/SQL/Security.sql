CREATE OR REPLACE PACKAGE pkg_security IS
    PROCEDURE assert_admin;
    PROCEDURE assert_trainer;
    PROCEDURE assert_client;

    PROCEDURE assert_admin_or_trainer;
    PROCEDURE assert_admin_or_client;
    PROCEDURE assert_trainer_or_client;
    PROCEDURE assert_all;

    -- служебные
    FUNCTION get_user_id RETURN NUMBER;
    FUNCTION get_role RETURN VARCHAR2;
    
    PROCEDURE set_auth_context(
        p_user_id IN NUMBER,
        p_role    IN VARCHAR2,
        p_client_id IN NUMBER DEFAULT NULL,
        p_trainer_id IN NUMBER DEFAULT NULL
    );
    
    PROCEDURE assert_self_registration;

END pkg_security;


CREATE CONTEXT app_ctx USING pkg_security;


CREATE OR REPLACE PACKAGE BODY pkg_security IS

    ------------------------------------------------
    -- Получение user_id из контекста
    ------------------------------------------------
    FUNCTION get_user_id RETURN NUMBER IS
        v_user_id NUMBER;
    BEGIN
        v_user_id := SYS_CONTEXT('APP_CTX', 'USER_ID');

        IF v_user_id IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: пользователь не авторизован.');
        END IF;

        RETURN v_user_id;
    END get_user_id;


    ------------------------------------------------
    -- Получение роли из контекста
    ------------------------------------------------
    FUNCTION get_role RETURN VARCHAR2 IS
        v_role VARCHAR2(50);
    BEGIN
        v_role := SYS_CONTEXT('APP_CTX', 'ROLE');

        IF v_role IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: роль пользователя не определена.');
        END IF;

        RETURN v_role;
    END get_role;


    ------------------------------------------------
    -- Проверки ролей
    ------------------------------------------------
    PROCEDURE assert_admin IS
    BEGIN
        IF get_role() <> 'ROLE_ADMIN' THEN
            DBMS_OUTPUT.PUT_LINE('Доступ запрещён: требуется роль ADMIN.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END assert_admin;


    PROCEDURE assert_trainer IS
    BEGIN
        IF get_role() <> 'ROLE_TRAINER' THEN
            DBMS_OUTPUT.PUT_LINE('Доступ запрещён: требуется роль TRAINER.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END assert_trainer;


    PROCEDURE assert_client IS
    BEGIN
        IF get_role() <> 'ROLE_CLIENT' THEN
            DBMS_OUTPUT.PUT_LINE('Доступ запрещён: требуется роль CLIENT.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END assert_client;


    PROCEDURE assert_admin_or_trainer IS
    BEGIN
        IF get_role() NOT IN ('ROLE_ADMIN', 'ROLE_TRAINER') THEN
            DBMS_OUTPUT.PUT_LINE('Доступ запрещён: требуется роль ADMIN или TRAINER.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END assert_admin_or_trainer;


    PROCEDURE assert_admin_or_client IS
    BEGIN
        IF get_role() NOT IN ('ROLE_ADMIN', 'ROLE_CLIENT') THEN
            DBMS_OUTPUT.PUT_LINE('Доступ запрещён: требуется роль ADMIN или CLIENT.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END assert_admin_or_client;


    PROCEDURE assert_trainer_or_client IS
    BEGIN
        IF get_role() NOT IN ('ROLE_TRAINER', 'ROLE_CLIENT') THEN
            DBMS_OUTPUT.PUT_LINE('Доступ запрещён: требуется роль TRAINER или CLIENT.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END assert_trainer_or_client;


    PROCEDURE assert_all IS
    BEGIN
        IF get_role() NOT IN (
            'ROLE_ADMIN',
            'ROLE_TRAINER',
            'ROLE_CLIENT'
        ) THEN
            DBMS_OUTPUT.PUT_LINE('Доступ запрещён.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END assert_all;
    
    
    PROCEDURE set_auth_context(
        p_user_id    IN NUMBER,
        p_role       IN VARCHAR2,
        p_client_id  IN NUMBER DEFAULT NULL,
        p_trainer_id IN NUMBER DEFAULT NULL
    ) IS
    BEGIN
        DBMS_SESSION.SET_CONTEXT('APP_CTX', 'USER_ID', p_user_id);
        DBMS_SESSION.SET_CONTEXT('APP_CTX', 'ROLE', p_role);
        DBMS_SESSION.SET_CONTEXT('APP_CTX', 'CLIENT_ID', p_client_id);
        DBMS_SESSION.SET_CONTEXT('APP_CTX', 'TRAINER_ID', p_trainer_id);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END;

    
    
    PROCEDURE assert_self_registration IS
    BEGIN
        IF DBMS_SESSION.IS_ROLE_ENABLED('ROLE_ADMIN')
           OR DBMS_SESSION.IS_ROLE_ENABLED('ROLE_TRAINER') THEN
            DBMS_OUTPUT.PUT_LINE('Регистрация запрещена для административных соединений.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END;

END pkg_security;


DROP CONTEXT app_ctx;
DROP PACKAGE pkg_security;