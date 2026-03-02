CREATE OR REPLACE PACKAGE pkg_sessions_client IS
    -- Для админа: запись клиента на занятие
    PROCEDURE book_session_admin(p_client_id IN NUMBER, p_schedule_id IN NUMBER);

    -- Для клиента: запись на занятие по своему контексту
    PROCEDURE book_session_client(p_schedule_id IN NUMBER);

    -- Для админа и клиента: получение бронирований клиента
    PROCEDURE get_client_bookings(p_client_id IN NUMBER);

    -- Для админа: отмена записи клиента
    PROCEDURE cancel_booking_admin(p_client_id IN NUMBER, p_schedule_id IN NUMBER);

    -- Для клиента: отмена своей записи
    PROCEDURE cancel_booking_client(p_schedule_id IN NUMBER);
END pkg_sessions_client;

 
CREATE OR REPLACE PACKAGE BODY pkg_sessions_client IS

    ------------------------------------------------
    -- Админ записывает клиента на занятие
    ------------------------------------------------
    PROCEDURE book_session_admin(p_client_id IN NUMBER, p_schedule_id IN NUMBER) IS
    BEGIN
        pkg_security.assert_admin;
        INSERT INTO client_session_records(client_id, schedule_id, attended)
        VALUES (p_client_id, p_schedule_id, 'N');
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: клиент уже записан на это занятие.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка записи на занятие: ' || SQLERRM);
    END book_session_admin;

    ------------------------------------------------
    -- Клиент записывается на занятие сам
    ------------------------------------------------
    PROCEDURE book_session_client(p_schedule_id IN NUMBER) IS
        v_client_id NUMBER;
    BEGIN
        pkg_security.assert_client;
        v_client_id := SYS_CONTEXT('APP_CTX', 'CLIENT_ID');

        INSERT INTO client_session_records(client_id, schedule_id, attended)
        VALUES (v_client_id, p_schedule_id, 'N');

        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: вы уже записаны на это занятие.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка записи на занятие: ' || SQLERRM);
    END book_session_client;

    ------------------------------------------------
    -- Получение бронирований (для админа и клиента)
    ------------------------------------------------
    PROCEDURE get_client_bookings(p_client_id IN NUMBER) IS
    BEGIN
        pkg_security.assert_admin_or_client;
        FOR rec IN (
            SELECT csr.record_id, s.session_name, s.session_date, s.start_time
            FROM client_session_records csr
            JOIN schedules s ON csr.schedule_id = s.schedule_id
            WHERE csr.client_id = p_client_id
            ORDER BY s.session_date, s.start_time
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Booking: ' || rec.record_id || 
                ', ' || rec.session_name || 
                ', Date: ' || rec.session_date || 
                ', Time: ' || rec.start_time
            );
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка получения бронирований: ' || SQLERRM);
    END get_client_bookings;

    ------------------------------------------------
    -- Админ отменяет запись клиента
    ------------------------------------------------
    PROCEDURE cancel_booking_admin(p_client_id IN NUMBER, p_schedule_id IN NUMBER) IS
    BEGIN
        pkg_security.assert_admin;
        DELETE FROM client_session_records
        WHERE client_id = p_client_id
          AND schedule_id = p_schedule_id;

        IF SQL%ROWCOUNT = 0 THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: Запись не найдена.');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка отмены записи: ' || SQLERRM);
    END cancel_booking_admin;

    ------------------------------------------------
    -- Клиент отменяет свою запись
    ------------------------------------------------
    PROCEDURE cancel_booking_client(p_schedule_id IN NUMBER) IS
        v_client_id NUMBER;
    BEGIN
        pkg_security.assert_client;
        v_client_id := SYS_CONTEXT('APP_CTX', 'CLIENT_ID');

        DELETE FROM client_session_records
        WHERE client_id = v_client_id
          AND schedule_id = p_schedule_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: Запись не найдена или не принадлежит вам.');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка отмены записи: ' || SQLERRM);
    END cancel_booking_client;

END pkg_sessions_client;


DROP PACKAGE pkg_sessions_client;