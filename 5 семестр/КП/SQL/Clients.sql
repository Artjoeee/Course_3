CREATE OR REPLACE PACKAGE pkg_clients_admin IS
    PROCEDURE add_client(p_user_id IN NUMBER, p_first_name IN VARCHAR2, p_last_name IN VARCHAR2,
                         p_phone IN VARCHAR2, p_email IN VARCHAR2, p_dob IN DATE);
    PROCEDURE update_client(p_client_id IN NUMBER, p_phone IN VARCHAR2, p_email IN VARCHAR2);
    PROCEDURE change_status(p_client_id IN NUMBER, p_status IN VARCHAR2);
    PROCEDURE get_client_info_admin(p_client_id IN NUMBER);
END pkg_clients_admin;


CREATE OR REPLACE PACKAGE BODY pkg_clients_admin IS
    PROCEDURE add_client(p_user_id IN NUMBER, p_first_name IN VARCHAR2, p_last_name IN VARCHAR2,
                         p_phone IN VARCHAR2, p_email IN VARCHAR2, p_dob IN DATE) IS
    BEGIN
        pkg_security.assert_admin;
        INSERT INTO clients(user_id, first_name, last_name, phone_number, email, date_of_birth)
        VALUES (p_user_id, p_first_name, p_last_name, p_phone, p_email, p_dob);
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: клиент с таким email уже существует.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка добавления клиента: ' || SQLERRM);
    END add_client;

    PROCEDURE update_client(p_client_id IN NUMBER, p_phone IN VARCHAR2, p_email IN VARCHAR2) IS
    BEGIN
        pkg_security.assert_admin;
        UPDATE clients SET phone_number = p_phone, email = p_email WHERE client_id = p_client_id;
        IF SQL%ROWCOUNT = 0 THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: клиент не найден.');
        END IF;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка обновления клиента: ' || SQLERRM);
    END update_client;

    PROCEDURE change_status(p_client_id IN NUMBER, p_status IN VARCHAR2) IS
    BEGIN
        pkg_security.assert_admin;
        UPDATE clients SET status = p_status WHERE client_id = p_client_id;
        IF SQL%ROWCOUNT = 0 THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: клиент не найден.');
        END IF;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка изменения статуса клиента: ' || SQLERRM);
    END change_status;

    PROCEDURE get_client_info_admin(p_client_id IN NUMBER) IS
        v_first clients.first_name%TYPE;
        v_last  clients.last_name%TYPE;
        v_status clients.status%TYPE;
    BEGIN
        pkg_security.assert_admin;
        SELECT first_name, last_name, status INTO v_first, v_last, v_status
        FROM clients
        WHERE client_id = p_client_id;

        DBMS_OUTPUT.PUT_LINE('Client: ' || v_first || ' ' || v_last || ', Status: ' || v_status);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: клиент не найден.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка получения информации о клиенте: ' || SQLERRM);
    END get_client_info_admin;

END pkg_clients_admin;


DROP PACKAGE pkg_clients_admin;




CREATE OR REPLACE PACKAGE pkg_clients_trainer IS
    -- Список клиентов, посещающих тренировки тренера
    PROCEDURE get_my_clients(p_trainer_id IN NUMBER);
    -- Подробная информация о клиенте тренера
    PROCEDURE get_client_details(p_trainer_id IN NUMBER, p_client_id  IN NUMBER);
    -- История посещений клиента только по тренировкам тренера
    PROCEDURE get_client_attendance(p_trainer_id IN NUMBER, p_client_id  IN NUMBER);
END pkg_clients_trainer;


CREATE OR REPLACE PACKAGE BODY pkg_clients_trainer IS
    PROCEDURE get_my_clients(
        p_trainer_id IN NUMBER
    ) IS
    BEGIN
        pkg_security.assert_admin_or_trainer;
        FOR rec IN (
            SELECT DISTINCT c.client_id, c.first_name, c.last_name
            FROM clients c
            JOIN client_session_records r ON c.client_id = r.client_id
            JOIN schedules s ON r.schedule_id = s.schedule_id
            WHERE s.coach_id = p_trainer_id
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE('Client: ' || rec.client_id || ' - ' ||
                                  rec.first_name || ' ' || rec.last_name);
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка получения списка клиентов: ' || SQLERRM);
    END get_my_clients;


    PROCEDURE get_client_details(
        p_trainer_id IN NUMBER,
        p_client_id  IN NUMBER
    ) IS
        v_cnt NUMBER;
    BEGIN
        pkg_security.assert_admin_or_trainer;
        -- Проверяем, клиент ли тренера
        SELECT COUNT(*) INTO v_cnt
        FROM client_session_records r
        JOIN schedules s ON r.schedule_id = s.schedule_id
        WHERE r.client_id = p_client_id
          AND s.coach_id = p_trainer_id;

        IF v_cnt = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: клиент не относится к данному тренеру.');
            RETURN;
        END IF;

        FOR rec IN (
            SELECT first_name, last_name, phone_number, email
            FROM clients
            WHERE client_id = p_client_id
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE('Client: ' || rec.first_name || ' ' || rec.last_name);
            DBMS_OUTPUT.PUT_LINE('Phone: ' || rec.phone_number);
            DBMS_OUTPUT.PUT_LINE('Email: ' || rec.email);
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка получения данных клиента: ' || SQLERRM);
    END get_client_details;


    PROCEDURE get_client_attendance(
        p_trainer_id IN NUMBER,
        p_client_id  IN NUMBER
    ) IS
    BEGIN
        pkg_security.assert_admin_or_trainer;
        FOR rec IN (
            SELECT s.session_name, r.attended, r.performance_notes
            FROM client_session_records r
            JOIN schedules s ON r.schedule_id = s.schedule_id
            WHERE r.client_id = p_client_id
              AND s.coach_id = p_trainer_id
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Session: ' || rec.session_name ||
                ', Attended: ' || rec.attended ||
                ', Notes: ' || rec.performance_notes
            );
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка получения посещений клиента: ' || SQLERRM);
    END get_client_attendance;

END pkg_clients_trainer;


DROP PACKAGE pkg_clients_trainer;