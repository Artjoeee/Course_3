-- 1. USERS (5 тренеров + 10 клиентов = 15 записей)
-- Тренеры (user_id будут 1-5)
INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('ivanov_coach', 'a1b2c3d4e5f6789012345678901234567890abcdef', HEXTORAW('0A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D'), 'ROLE_TRAINER');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('petrova_coach', 'b2c3d4e5f67890123456789012345678901abcdef0', HEXTORAW('1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E'), 'ROLE_TRAINER');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('sidorov_coach', 'c3d4e5f6789012345678901234567890abcdef012', HEXTORAW('2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E7F'), 'ROLE_TRAINER');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('kozlova_coach', 'd4e5f67890123456789012345678901abcdef0123', HEXTORAW('3D4E5F6A7B8C9D0E1F2A3B4C5D6E7F8A'), 'ROLE_TRAINER');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('morozov_coach', 'e5f6789012345678901234567890abcdef01234567', HEXTORAW('4E5F6A7B8C9D0E1F2A3B4C5D6E7F8A9B'), 'ROLE_TRAINER');

-- Клиенты (user_id будут 6-15)
INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('sokolova_anna', 'f67890123456789012345678901abcdef012345678', HEXTORAW('5F6A7B8C9D0E1F2A3B4C5D6E7F8A9B0C'), 'ROLE_CLIENT');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('kuznetsov_dmitry', '7890123456789012345678901abcdef0123456789a', HEXTORAW('6A7B8C9D0E1F2A3B4C5D6E7F8A9B0C1D'), 'ROLE_CLIENT');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('novikova_elena', '890123456789012345678901abcdef0123456789ab', HEXTORAW('7B8C9D0E1F2A3B4C5D6E7F8A9B0C1D2E'), 'ROLE_CLIENT');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('volkov_sergey', '90123456789012345678901abcdef0123456789abc', HEXTORAW('8C9D0E1F2A3B4C5D6E7F8A9B0C1D2E3F'), 'ROLE_CLIENT');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('lebedeva_maria', '0123456789012345678901abcdef0123456789abcd', HEXTORAW('9D0E1F2A3B4C5D6E7F8A9B0C1D2E3F4A'), 'ROLE_CLIENT');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('orlov_alexey', '123456789012345678901abcdef0123456789abcde', HEXTORAW('0E1F2A3B4C5D6E7F8A9B0C1D2E3F4A5B'), 'ROLE_CLIENT');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('fedorova_olga', '23456789012345678901abcdef0123456789abcdef', HEXTORAW('1F2A3B4C5D6E7F8A9B0C1D2E3F4A5B6C'), 'ROLE_CLIENT');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('pavlov_ivan', '3456789012345678901abcdef0123456789abcdef0', HEXTORAW('2A3B4C5D6E7F8A9B0C1D2E3F4A5B6C7D'), 'ROLE_CLIENT');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('smirnova_tatyana', '456789012345678901abcdef0123456789abcdef01', HEXTORAW('3B4C5D6E7F8A9B0C1D2E3F4A5B6C7D8E'), 'ROLE_CLIENT');

INSERT INTO USERS (username, password_hash, password_salt, role_name) 
VALUES ('belov_nikita', '56789012345678901abcdef0123456789abcdef012', HEXTORAW('4C5D6E7F8A9B0C1D2E3F4A5B6C7D8E9F'), 'ROLE_CLIENT');


-- 2. COACHES (5 тренеров, связаны с user_id 1-5)
INSERT INTO COACHES (user_id, first_name, last_name, phone_number, email, specialization, hire_date) 
VALUES (1, 'Андрей', 'Иванов', '+7-916-123-4567', 'ivanov@sportics.ru', 'Силовые тренировки', DATE '2022-03-15');

INSERT INTO COACHES (user_id, first_name, last_name, phone_number, email, specialization, hire_date) 
VALUES (2, 'Екатерина', 'Петрова', '+7-916-234-5678', 'petrova@sportics.ru', 'Йога и пилатес', DATE '2021-09-01');

INSERT INTO COACHES (user_id, first_name, last_name, phone_number, email, specialization, hire_date) 
VALUES (3, 'Максим', 'Сидоров', '+7-916-345-6789', 'sidorov@sportics.ru', 'Кроссфит', DATE '2023-01-10');

INSERT INTO COACHES (user_id, first_name, last_name, phone_number, email, specialization, hire_date) 
VALUES (4, 'Наталья', 'Козлова', '+7-916-456-7890', 'kozlova@sportics.ru', 'Аэробика и танцы', DATE '2020-06-20');

INSERT INTO COACHES (user_id, first_name, last_name, phone_number, email, specialization, hire_date) 
VALUES (5, 'Виктор', 'Морозов', '+7-916-567-8901', 'morozov@sportics.ru', 'Плавание', DATE '2022-11-05');


-- 3. CLIENTS (10 клиентов, связаны с user_id 6-15)
INSERT INTO CLIENTS (user_id, first_name, last_name, phone_number, email, date_of_birth, registration_date) 
VALUES (6, 'Анна', 'Соколова', '+7-903-111-2233', 'sokolova.anna@mail.ru', DATE '1992-05-14', DATE '2024-01-15');

INSERT INTO CLIENTS (user_id, first_name, last_name, phone_number, email, date_of_birth, registration_date) 
VALUES (7, 'Дмитрий', 'Кузнецов', '+7-903-222-3344', 'kuznetsov.d@gmail.com', DATE '1988-11-23', DATE '2023-09-20');

INSERT INTO CLIENTS (user_id, first_name, last_name, phone_number, email, date_of_birth, registration_date) 
VALUES (8, 'Елена', 'Новикова', '+7-903-333-4455', 'novikova.e@yandex.ru', DATE '1995-03-07', DATE '2024-06-01');

INSERT INTO CLIENTS (user_id, first_name, last_name, phone_number, email, date_of_birth, registration_date) 
VALUES (9, 'Сергей', 'Волков', '+7-903-444-5566', 'volkov.sergey@mail.ru', DATE '1990-08-30', DATE '2023-11-10');

INSERT INTO CLIENTS (user_id, first_name, last_name, phone_number, email, date_of_birth, registration_date) 
VALUES (10, 'Мария', 'Лебедева', '+7-903-555-6677', 'lebedeva.m@gmail.com', DATE '1997-01-18', DATE '2024-03-25');

INSERT INTO CLIENTS (user_id, first_name, last_name, phone_number, email, date_of_birth, registration_date) 
VALUES (11, 'Алексей', 'Орлов', '+7-903-666-7788', 'orlov.alex@yandex.ru', DATE '1985-12-05', DATE '2022-08-14');

INSERT INTO CLIENTS (user_id, first_name, last_name, phone_number, email, date_of_birth, registration_date) 
VALUES (12, 'Ольга', 'Фёдорова', '+7-903-777-8899', 'fedorova.olga@mail.ru', DATE '1993-07-22', DATE '2024-09-03');

INSERT INTO CLIENTS (user_id, first_name, last_name, phone_number, email, date_of_birth, registration_date) 
VALUES (13, 'Иван', 'Павлов', '+7-903-888-9900', 'pavlov.ivan@gmail.com', DATE '1991-04-11', DATE '2023-05-17');

INSERT INTO CLIENTS (user_id, first_name, last_name, phone_number, email, date_of_birth, registration_date) 
VALUES (14, 'Татьяна', 'Смирнова', '+7-903-999-0011', 'smirnova.t@yandex.ru', DATE '1989-09-28', DATE '2024-02-08');

INSERT INTO CLIENTS (user_id, first_name, last_name, phone_number, email, date_of_birth, registration_date) 
VALUES (15, 'Никита', 'Белов', '+7-903-000-1122', 'belov.nikita@mail.ru', DATE '1998-06-15', DATE '2024-11-20');


-- 4. MEMBERSHIPS (10 типов абонементов)
INSERT INTO MEMBERSHIPS (name, description, duration_months, price) 
VALUES ('Базовый', 'Доступ в тренажёрный зал с 6:00 до 16:00', 1, 3500.00);

INSERT INTO MEMBERSHIPS (name, description, duration_months, price) 
VALUES ('Стандарт', 'Полный доступ в тренажёрный зал без ограничений', 1, 5000.00);

INSERT INTO MEMBERSHIPS (name, description, duration_months, price) 
VALUES ('Премиум', 'Полный доступ + групповые занятия', 1, 7500.00);

INSERT INTO MEMBERSHIPS (name, description, duration_months, price) 
VALUES ('Базовый 3 месяца', 'Доступ в тренажёрный зал с 6:00 до 16:00', 3, 9000.00);

INSERT INTO MEMBERSHIPS (name, description, duration_months, price) 
VALUES ('Стандарт 3 месяца', 'Полный доступ в тренажёрный зал без ограничений', 3, 13500.00);

INSERT INTO MEMBERSHIPS (name, description, duration_months, price) 
VALUES ('Премиум 3 месяца', 'Полный доступ + групповые занятия', 3, 20000.00);

INSERT INTO MEMBERSHIPS (name, description, duration_months, price) 
VALUES ('Годовой базовый', 'Доступ в тренажёрный зал с 6:00 до 16:00 на год', 12, 30000.00);

INSERT INTO MEMBERSHIPS (name, description, duration_months, price) 
VALUES ('Годовой стандарт', 'Полный доступ в тренажёрный зал на год', 12, 48000.00);

INSERT INTO MEMBERSHIPS (name, description, duration_months, price) 
VALUES ('Годовой премиум', 'Полный доступ + групповые занятия на год', 12, 72000.00);

INSERT INTO MEMBERSHIPS (name, description, duration_months, price) 
VALUES ('VIP', 'Полный доступ + персональный тренер + спа-зона', 1, 15000.00);


-- 5. MEMBERSHIP_ORDERS (10 заказов)
INSERT INTO MEMBERSHIP_ORDERS (client_id, membership_id, order_date, start_date, end_date, status) 
VALUES (1, 8, DATE '2025-12-01', DATE '2025-12-01', DATE '2026-12-01', 'ACTIVE');

INSERT INTO MEMBERSHIP_ORDERS (client_id, membership_id, order_date, start_date, end_date, status) 
VALUES (2, 6, DATE '2025-10-15', DATE '2025-10-15', DATE '2026-01-15', 'ACTIVE');

INSERT INTO MEMBERSHIP_ORDERS (client_id, membership_id, order_date, start_date, end_date, status) 
VALUES (3, 3, DATE '2025-12-10', DATE '2025-12-10', DATE '2026-01-10', 'ACTIVE');

INSERT INTO MEMBERSHIP_ORDERS (client_id, membership_id, order_date, start_date, end_date, status) 
VALUES (4, 9, DATE '2025-06-01', DATE '2025-06-01', DATE '2026-06-01', 'ACTIVE');

INSERT INTO MEMBERSHIP_ORDERS (client_id, membership_id, order_date, start_date, end_date, status) 
VALUES (5, 5, DATE '2025-11-20', DATE '2025-11-20', DATE '2026-02-20', 'ACTIVE');

INSERT INTO MEMBERSHIP_ORDERS (client_id, membership_id, order_date, start_date, end_date, status) 
VALUES (6, 10, DATE '2025-12-14', DATE '2025-12-16', DATE '2026-01-16', 'ACTIVE');

INSERT INTO MEMBERSHIP_ORDERS (client_id, membership_id, order_date, start_date, end_date, status) 
VALUES (7, 2, DATE '2025-11-01', DATE '2025-11-01', DATE '2025-12-01', 'EXPIRED');

INSERT INTO MEMBERSHIP_ORDERS (client_id, membership_id, order_date, start_date, end_date, status) 
VALUES (8, 7, DATE '2025-08-10', DATE '2025-08-10', DATE '2026-08-10', 'ACTIVE');

INSERT INTO MEMBERSHIP_ORDERS (client_id, membership_id, order_date, start_date, end_date, status) 
VALUES (9, 3, DATE '2025-12-15', DATE '2025-12-16', DATE '2026-01-16', 'ACTIVE');

INSERT INTO MEMBERSHIP_ORDERS (client_id, membership_id, order_date, start_date, end_date, status) 
VALUES (10, 4, DATE '2025-12-01', DATE '2025-12-01', DATE '2026-03-01', 'ACTIVE');


-- 6. SCHEDULES (10 занятий на ближайшие дни)
INSERT INTO SCHEDULES (coach_id, session_name, session_date, start_time, end_time, capacity) 
VALUES (1, 'Силовая тренировка для начинающих', DATE '2025-12-16', TIMESTAMP '2025-12-16 09:00:00', TIMESTAMP '2025-12-16 10:30:00', 15);

INSERT INTO SCHEDULES (coach_id, session_name, session_date, start_time, end_time, capacity) 
VALUES (2, 'Утренняя йога', DATE '2025-12-16', TIMESTAMP '2025-12-16 07:00:00', TIMESTAMP '2025-12-16 08:00:00', 20);

INSERT INTO SCHEDULES (coach_id, session_name, session_date, start_time, end_time, capacity) 
VALUES (3, 'Кроссфит интенсив', DATE '2025-12-17', TIMESTAMP '2025-12-17 18:00:00', TIMESTAMP '2025-12-17 19:30:00', 12);

INSERT INTO SCHEDULES (coach_id, session_name, session_date, start_time, end_time, capacity) 
VALUES (4, 'Зумба', DATE '2025-12-17', TIMESTAMP '2025-12-17 19:00:00', TIMESTAMP '2025-12-17 20:00:00', 25);

INSERT INTO SCHEDULES (coach_id, session_name, session_date, start_time, end_time, capacity) 
VALUES (5, 'Аквааэробика', DATE '2025-12-18', TIMESTAMP '2025-12-18 10:00:00', TIMESTAMP '2025-12-18 11:00:00', 15);

INSERT INTO SCHEDULES (coach_id, session_name, session_date, start_time, end_time, capacity) 
VALUES (1, 'Функциональный тренинг', DATE '2025-12-18', TIMESTAMP '2025-12-18 17:00:00', TIMESTAMP '2025-12-18 18:30:00', 12);

INSERT INTO SCHEDULES (coach_id, session_name, session_date, start_time, end_time, capacity) 
VALUES (2, 'Пилатес', DATE '2025-12-19', TIMESTAMP '2025-12-19 12:00:00', TIMESTAMP '2025-12-19 13:00:00', 18);

INSERT INTO SCHEDULES (coach_id, session_name, session_date, start_time, end_time, capacity) 
VALUES (3, 'Круговая тренировка', DATE '2025-12-19', TIMESTAMP '2025-12-19 20:00:00', TIMESTAMP '2024-12-19 21:00:00', 10);

INSERT INTO SCHEDULES (coach_id, session_name, session_date, start_time, end_time, capacity) 
VALUES (4, 'Латиноамериканские танцы', DATE '2025-12-20', TIMESTAMP '2025-12-20 18:30:00', TIMESTAMP '2025-12-20 19:30:00', 20);

INSERT INTO SCHEDULES (coach_id, session_name, session_date, start_time, end_time, capacity) 
VALUES (5, 'Плавание для взрослых', DATE '2025-12-20', TIMESTAMP '2025-12-20 08:00:00', TIMESTAMP '2025-12-20 09:00:00', 8);


-- 7. CLIENT_SESSION_RECORDS (10 записей на занятия)
INSERT INTO CLIENT_SESSION_RECORDS (client_id, schedule_id, attendance_date, performance_notes, attended) 
VALUES (1, 1, DATE '2025-12-16', NULL, NULL);

INSERT INTO CLIENT_SESSION_RECORDS (client_id, schedule_id, attendance_date, performance_notes, attended) 
VALUES (3, 1, DATE '2025-12-16', NULL, NULL);

INSERT INTO CLIENT_SESSION_RECORDS (client_id, schedule_id, attendance_date, performance_notes, attended) 
VALUES (5, 2, DATE '2025-12-16', NULL, NULL);

INSERT INTO CLIENT_SESSION_RECORDS (client_id, schedule_id, attendance_date, performance_notes, attended) 
VALUES (2, 3, DATE '2025-12-17', NULL, NULL);

INSERT INTO CLIENT_SESSION_RECORDS (client_id, schedule_id, attendance_date, performance_notes, attended) 
VALUES (4, 4, DATE '2025-12-17', NULL, NULL);

INSERT INTO CLIENT_SESSION_RECORDS (client_id, schedule_id, attendance_date, performance_notes, attended) 
VALUES (6, 4, DATE '2025-12-17', NULL, NULL);

INSERT INTO CLIENT_SESSION_RECORDS (client_id, schedule_id, attendance_date, performance_notes, attended) 
VALUES (8, 5, DATE '2025-12-18', NULL, NULL);

INSERT INTO CLIENT_SESSION_RECORDS (client_id, schedule_id, attendance_date, performance_notes, attended) 
VALUES (9, 6, DATE '2025-12-18', NULL, NULL);

INSERT INTO CLIENT_SESSION_RECORDS (client_id, schedule_id, attendance_date, performance_notes, attended) 
VALUES (10, 7, DATE '2025-12-19', NULL, NULL);

INSERT INTO CLIENT_SESSION_RECORDS (client_id, schedule_id, attendance_date, performance_notes, attended) 
VALUES (1, 8, DATE '2025-12-19', NULL, NULL);

COMMIT;



DECLARE
    v_salt RAW(16);
    v_hash VARCHAR2(200);
BEGIN
    FOR i IN 1..100000 LOOP
        v_salt := DBMS_CRYPTO.RANDOMBYTES(16);

        v_hash := RAWTOHEX(
            DBMS_CRYPTO.HASH(
                UTL_RAW.CAST_TO_RAW('password' || i || v_salt),
                DBMS_CRYPTO.HASH_SH256
            )
        );

        INSERT INTO USERS (username, password_hash, password_salt, role_name, must_change_password)
        VALUES (
            'user_' || LPAD(i, 6, '0'),
            v_hash,
            v_salt,
            'ROLE_CLIENT',
            'Y'
        );

        IF MOD(i, 1000) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
END;


SELECT user_id, username FROM USERS
    ORDER BY user_id;
    
SET AUTOTRACE ON STATISTICS;
SELECT * FROM USERS WHERE username = 'user_050000';
SET AUTOTRACE OFF;

EXPLAIN PLAN FOR
SELECT *
FROM users
WHERE username = 'user_050000';

SELECT * 
FROM TABLE(DBMS_XPLAN.DISPLAY);

ALTER SESSION SET statistics_level = ALL;

SELECT *
FROM users
WHERE username = 'user_050000';

SELECT *
FROM TABLE(
    DBMS_XPLAN.DISPLAY_CURSOR(
        NULL, NULL, 'ALLSTATS LAST'
    )
);


ALTER SYSTEM FLUSH SHARED_POOL;
ALTER SYSTEM FLUSH BUFFER_CACHE;

DECLARE
    t_start  TIMESTAMP;
    t_end    TIMESTAMP;
    elapsed  INTERVAL DAY TO SECOND;
BEGIN
    t_start := SYSTIMESTAMP;

    EXECUTE IMMEDIATE 'SELECT * FROM USERS WHERE role_name = ''ROLE_CLIENT''';

    t_end := SYSTIMESTAMP;

    elapsed := t_end - t_start;

    DBMS_OUTPUT.PUT_LINE('Время выполнения: ' || elapsed);
END;


