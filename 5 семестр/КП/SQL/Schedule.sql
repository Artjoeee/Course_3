CREATE OR REPLACE PACKAGE pkg_trainer_schedule IS

    PROCEDURE add_session(
        p_trainer_id  IN NUMBER,
        p_name        IN VARCHAR2,
        p_date        IN DATE,
        p_start_time  IN TIMESTAMP,
        p_end_time    IN TIMESTAMP,
        p_capacity    IN NUMBER
    );

    PROCEDURE update_session(
        p_trainer_id  IN NUMBER,
        p_schedule_id IN NUMBER,
        p_start_time  IN TIMESTAMP,
        p_end_time    IN TIMESTAMP
    );

    PROCEDURE delete_session(
        p_trainer_id  IN NUMBER,
        p_schedule_id IN NUMBER
    );

    PROCEDURE get_my_schedule(
        p_trainer_id IN NUMBER,
        p_date       IN DATE
    );

END pkg_trainer_schedule;


CREATE OR REPLACE PACKAGE BODY pkg_trainer_schedule IS

    PROCEDURE add_session(
        p_trainer_id  IN NUMBER,
        p_name        IN VARCHAR2,
        p_date        IN DATE,
        p_start_time  IN TIMESTAMP,
        p_end_time    IN TIMESTAMP,
        p_capacity    IN NUMBER
    ) IS
    BEGIN
        pkg_security.assert_admin_or_trainer;
    
        -- Проверка: дата занятия не в прошлом
        IF TRUNC(p_date) < TRUNC(SYSDATE) THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: Нельзя создать занятие с датой меньше текущей.');
        END IF;
    
        -- Дополнительно (рекомендуется): проверка времени
        IF p_end_time <= p_start_time THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: Время окончания должно быть больше времени начала.');
        END IF;
    
        INSERT INTO schedules(
            coach_id,
            session_name,
            session_date,
            start_time,
            end_time,
            capacity
        )
        VALUES (
            p_trainer_id,
            p_name,
            p_date,
            p_start_time,
            p_end_time,
            p_capacity
        );
    
        COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка добавления занятия: ' || SQLERRM);
    END add_session;



    PROCEDURE update_session(
        p_trainer_id  IN NUMBER,
        p_schedule_id IN NUMBER,
        p_start_time  IN TIMESTAMP,
        p_end_time    IN TIMESTAMP
    ) IS
        v_cnt NUMBER;
    BEGIN
        pkg_security.assert_admin_or_trainer;
        -- Проверка собственности занятия
        SELECT COUNT(*) INTO v_cnt
        FROM schedules
        WHERE schedule_id = p_schedule_id
          AND coach_id    = p_trainer_id;

        IF v_cnt = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: попытка изменить чужое занятие.');
            RETURN;
        END IF;

        UPDATE schedules
        SET start_time = p_start_time,
            end_time   = p_end_time
        WHERE schedule_id = p_schedule_id;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка обновления занятия: ' || SQLERRM);
    END update_session;


    PROCEDURE delete_session(
        p_trainer_id  IN NUMBER,
        p_schedule_id IN NUMBER
    ) IS
        v_cnt NUMBER;
    BEGIN
        pkg_security.assert_admin_or_trainer;
        SELECT COUNT(*) INTO v_cnt
        FROM schedules
        WHERE schedule_id = p_schedule_id
          AND coach_id    = p_trainer_id;

        IF v_cnt = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: попытка удалить чужое занятие.');
            RETURN;
        END IF;

        DELETE FROM schedules WHERE schedule_id = p_schedule_id;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка удаления занятия: ' || SQLERRM);
    END delete_session;

    PROCEDURE get_my_schedule(
        p_trainer_id IN NUMBER,
        p_date       IN DATE
    ) IS
    BEGIN
        pkg_security.assert_admin_or_trainer;
        FOR rec IN (
            SELECT schedule_id, session_name, start_time, end_time
            FROM schedules
            WHERE coach_id = p_trainer_id
              AND session_date = p_date
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                'ID: ' || rec.schedule_id ||
                ', Name: ' || rec.session_name ||
                ', Time: ' || rec.start_time || ' - ' || rec.end_time
            );
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка получения расписания: ' || SQLERRM);
    END get_my_schedule;

END pkg_trainer_schedule;


DROP PACKAGE pkg_trainer_schedule;


CREATE OR REPLACE PACKAGE pkg_schedule_view IS
    PROCEDURE get_schedule_by_date(p_date IN DATE);
    PROCEDURE get_schedule_for_trainer(p_trainer_id IN NUMBER, p_date IN DATE);
END pkg_schedule_view;


CREATE OR REPLACE PACKAGE BODY pkg_schedule_view IS

    PROCEDURE get_schedule_by_date(p_date IN DATE) IS
    BEGIN
        pkg_security.assert_all;
        FOR rec IN (
            SELECT schedule_id, session_name, start_time, end_time, coach_id, capacity
            FROM schedules
            WHERE session_date = p_date
            ORDER BY start_time
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Session: ' || rec.schedule_id || ', Name: ' || rec.session_name ||
                                 ', Time: ' || rec.start_time || ' - ' || rec.end_time || ', Coach: ' || rec.coach_id ||
                                 ', Cap: ' || rec.capacity);
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка получения расписания: ' || SQLERRM);
    END get_schedule_by_date;

    PROCEDURE get_schedule_for_trainer(p_trainer_id IN NUMBER, p_date IN DATE) IS
    BEGIN
        pkg_security.assert_all;
        FOR rec IN (
            SELECT schedule_id, session_name, start_time, end_time
            FROM schedules
            WHERE coach_id = p_trainer_id AND session_date = p_date
            ORDER BY start_time
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Session: ' || rec.schedule_id || ', Name: ' || rec.session_name ||
                                 ', Time: ' || rec.start_time || ' - ' || rec.end_time);
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка получения расписания тренера: ' || SQLERRM);
    END get_schedule_for_trainer;

END pkg_schedule_view;


DROP PACKAGE pkg_schedule_view;