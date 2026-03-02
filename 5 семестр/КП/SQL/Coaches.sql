CREATE OR REPLACE PACKAGE pkg_trainers_admin IS

    -- Добавление нового тренера
    PROCEDURE add_trainer(
        p_user_id       IN NUMBER,
        p_first_name    IN VARCHAR2,
        p_last_name     IN VARCHAR2,
        p_phone         IN VARCHAR2,
        p_email         IN VARCHAR2,
        p_specialization IN VARCHAR2,
        p_hire_date     IN DATE DEFAULT SYSDATE
    );

    -- Обновление данных тренера
    PROCEDURE update_trainer(
        p_coach_id  IN NUMBER,
        p_phone     IN VARCHAR2,
        p_email     IN VARCHAR2,
        p_specialization IN VARCHAR2
    );

    -- Изменение статуса тренера (активен/неактивен)
    PROCEDURE change_status(
        p_coach_id IN NUMBER,
        p_status   IN VARCHAR2
    );

    -- Получение информации о тренере
    PROCEDURE get_trainer_info_admin(p_coach_id IN NUMBER);

END pkg_trainers_admin;


CREATE OR REPLACE PACKAGE BODY pkg_trainers_admin IS

    PROCEDURE add_trainer(
        p_user_id       IN NUMBER,
        p_first_name    IN VARCHAR2,
        p_last_name     IN VARCHAR2,
        p_phone         IN VARCHAR2,
        p_email         IN VARCHAR2,
        p_specialization IN VARCHAR2,
        p_hire_date     IN DATE DEFAULT SYSDATE
    ) IS
    BEGIN
        pkg_security.assert_admin;

        INSERT INTO coaches(user_id, first_name, last_name, phone_number, email, specialization, hire_date)
        VALUES (p_user_id, p_first_name, p_last_name, p_phone, p_email, p_specialization, p_hire_date);

        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: тренер с таким email или user_id уже существует.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка добавления тренера: ' || SQLERRM);
    END add_trainer;


    PROCEDURE update_trainer(
        p_coach_id      IN NUMBER,
        p_phone         IN VARCHAR2,
        p_email         IN VARCHAR2,
        p_specialization IN VARCHAR2
    ) IS
    BEGIN
        pkg_security.assert_admin;

        UPDATE coaches
        SET phone_number = p_phone,
            email = p_email,
            specialization = p_specialization
        WHERE coach_id = p_coach_id;

        IF SQL%ROWCOUNT = 0 THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: тренер не найден.');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка обновления тренера: ' || SQLERRM);
    END update_trainer;


    PROCEDURE change_status(
        p_coach_id IN NUMBER,
        p_status   IN VARCHAR2
    ) IS
    BEGIN
        pkg_security.assert_admin;

        UPDATE coaches
        SET status = p_status
        WHERE coach_id = p_coach_id;

        IF SQL%ROWCOUNT = 0 THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: тренер не найден.');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка изменения статуса тренера: ' || SQLERRM);
    END change_status;


    PROCEDURE get_trainer_info_admin(p_coach_id IN NUMBER) IS
        v_first  coaches.first_name%TYPE;
        v_last   coaches.last_name%TYPE;
        v_phone  coaches.phone_number%TYPE;
        v_email  coaches.email%TYPE;
        v_spec   coaches.specialization%TYPE;
        v_hire   coaches.hire_date%TYPE;
        v_status coaches.status%TYPE;
    BEGIN
        pkg_security.assert_admin;

        SELECT first_name, last_name, phone_number, email, specialization, hire_date, status
        INTO v_first, v_last, v_phone, v_email, v_spec, v_hire, v_status
        FROM coaches
        WHERE coach_id = p_coach_id;

        DBMS_OUTPUT.PUT_LINE('Trainer: ' || v_first || ' ' || v_last ||
                             ', Phone: ' || v_phone ||
                             ', Email: ' || v_email ||
                             ', Specialization: ' || v_spec ||
                             ', Hire Date: ' || v_hire ||
                             ', Status: ' || v_status);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: тренер не найден.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка получения информации о тренере: ' || SQLERRM);
    END get_trainer_info_admin;

END pkg_trainers_admin;


DROP PACKAGE pkg_trainers_admin;