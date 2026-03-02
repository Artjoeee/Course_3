DECLARE
    v_role VARCHAR2(50);
BEGIN
    administrator.pkg_auth.login_user(
        p_username => 'admin',
        p_password => 'admin12345',
        p_role     => v_role
    );

    DBMS_OUTPUT.PUT_LINE('login_user: OK, Role: ' || v_role);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;


DECLARE
    v_role VARCHAR2(50);
BEGIN
    administrator.pkg_auth.login_user(
        p_username => 'trainer',
        p_password => 'trainer12345',
        p_role     => v_role
    );

    DBMS_OUTPUT.PUT_LINE('login_user: OK, Role: ' || v_role);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;


DECLARE
    v_username VARCHAR2(50) := 'client';
    v_email    VARCHAR2(100) := 'client@example.com';
BEGIN
    administrator.pkg_auth.register_user(
        p_username   => v_username,
        p_password   => 'client123',
        p_first_name => 'Artem',
        p_last_name  => 'Zhamoida',
        p_email      => v_email,
        p_phone      => '+375445730402',
        p_dob        => DATE '1991-01-01'
    );

    DBMS_OUTPUT.PUT_LINE('register_user: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

DECLARE
    v_role VARCHAR2(50);
BEGIN
    administrator.pkg_auth.login_user(
        p_username => 'client',
        p_password => 'client123',
        p_role     => v_role
    );

    DBMS_OUTPUT.PUT_LINE('login_user: OK, Role: ' || v_role);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;


------------ pkg_auth -------------
DECLARE
    v_username VARCHAR2(50) := 'newclient';
    v_email    VARCHAR2(100) := 'newclient@example.com';
BEGIN
    administrator.pkg_auth.register_user(
        p_username   => v_username,
        p_password   => 'Client123!',
        p_first_name => 'John',
        p_last_name  => 'Doe',
        p_email      => v_email,
        p_phone      => '1234567890',
        p_dob        => DATE '1990-01-01'
    );

    DBMS_OUTPUT.PUT_LINE('register_user: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



DECLARE
    v_username VARCHAR2(50) := 'newclient';
BEGIN
    administrator.pkg_auth.change_password(
        p_username     => v_username,
        p_old_password => 'Client123!',
        p_new_password => 'NewPass456'
    );

    DBMS_OUTPUT.PUT_LINE('change_password: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



DECLARE
    v_role VARCHAR2(50);
BEGIN
    administrator.pkg_auth.login_user(
        p_username => 'newclient',
        p_password => 'NewPass456',
        p_role     => v_role
    );

    DBMS_OUTPUT.PUT_LINE('login_user: OK, Role: ' || v_role);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_auth.change_password(
        p_username     => 'newclient',
        p_old_password => 'WrongOldPass',
        p_new_password => 'AnotherPass789'
    );
END;



DECLARE
    v_role VARCHAR2(50);
BEGIN
    administrator.pkg_auth.login_user(
        p_username => 'newclient',
        p_password => 'WrongPass',
        p_role     => v_role
    );
END;



------------ pkg_users_admin -------------
BEGIN
    administrator.pkg_users_admin.add_user(
        p_username  => 'test_user_1',
        p_role_name => 'ROLE_CLIENT',
        p_password  => 'StrongPass123'
    );

    DBMS_OUTPUT.PUT_LINE('add_user: OK');
END;


BEGIN
    administrator.pkg_users_admin.add_user_with_role(
        p_username   => 'client_1',
        p_role_name  => 'ROLE_CLIENT',
        p_password   => 'ClientPass123',
        p_first_name => 'Иван',
        p_last_name  => 'Иванов',
        p_email      => 'ivanov@test.ru',
        p_phone      => '+79990000001',
        p_dob        => DATE '1995-05-10'
    );

    DBMS_OUTPUT.PUT_LINE('add_user_with_role (client): OK');
END;


BEGIN
    administrator.pkg_users_admin.add_user_with_role(
        p_username        => 'trainer_1',
        p_role_name       => 'ROLE_TRAINER',
        p_password        => 'TrainerPass123',
        p_first_name      => 'Пётр',
        p_last_name       => 'Петров',
        p_email           => 'petrov@test.ru',
        p_phone           => '+79990000002',
        p_specialization  => 'Фитнес'
    );

    DBMS_OUTPUT.PUT_LINE('add_user_with_role (trainer): OK');
END;


DECLARE
    v_user_id NUMBER := 100022;
BEGIN

    administrator.pkg_users_admin.block_user(v_user_id);

    DBMS_OUTPUT.PUT_LINE('block_user: OK');
END;


SELECT *
FROM users
WHERE username = 'client_1';


DECLARE
    v_user_id NUMBER := 200087;
BEGIN
    administrator.pkg_users_admin.unblock_user(v_user_id);

    DBMS_OUTPUT.PUT_LINE('unblock_user: OK');
END;


SELECT *
FROM users
WHERE username = 'test_user_1';


DECLARE
    v_user_id NUMBER := 200086;
BEGIN
    administrator.pkg_users_admin.change_role(
        p_user_id   => v_user_id,
        p_role_name => 'ROLE_TRAINER'
    );

    DBMS_OUTPUT.PUT_LINE('change_role: OK');
END;


DECLARE
    v_user_id NUMBER := 200086;
BEGIN
    administrator.pkg_users_admin.get_user_info(v_user_id);
END;


BEGIN
    administrator.pkg_users_admin.add_user(
        p_username  => 'bad_user',
        p_role_name => 'ROLE_CLIENT',
        p_password  => '123'
    );
END;


------------- pkg_clients_admin -------------
DECLARE
    v_user_id NUMBER := 200086;
BEGIN
    administrator.pkg_clients_admin.add_client(
        p_user_id     => v_user_id,
        p_first_name  => 'Алексей',
        p_last_name   => 'Смирнов',
        p_phone       => '+79991112233',
        p_email       => 'smirnov@test.ru',
        p_dob         => DATE '1998-08-15'
    );

    DBMS_OUTPUT.PUT_LINE('add_client: OK');
END;


SELECT client_id
FROM clients
WHERE email = 'smirnov@test.ru';


DECLARE
    v_client_id NUMBER := 43;
BEGIN
    administrator.pkg_clients_admin.update_client(
        p_client_id => v_client_id,
        p_phone     => '+79992223344',
        p_email     => 'smirnov_new@test.ru'
    );

    DBMS_OUTPUT.PUT_LINE('update_client: OK');
END;



DECLARE
    v_client_id NUMBER := 43;
BEGIN
    administrator.pkg_clients_admin.change_status(
        p_client_id => v_client_id,
        p_status    => 'ACTIVE'
    );

    DBMS_OUTPUT.PUT_LINE('change_status: OK');
END;


SELECT *
FROM clients
WHERE email = 'smirnov_new@test.ru';


DECLARE
    v_client_id NUMBER := 43;
BEGIN
    administrator.pkg_clients_admin.get_client_info_admin(v_client_id);
END;



BEGIN
    administrator.pkg_clients_admin.update_client(
        p_client_id => -1,
        p_phone     => '+70000000000',
        p_email     => 'error@test.ru'
    );
END;



------------- pkg_trainers_admin ---------------
SELECT *
FROM users
WHERE username = 'trainer_2';

BEGIN
    administrator.pkg_users_admin.add_user(
        p_username  => 'trainer_2',
        p_role_name => 'ROLE_TRAINER',
        p_password  => 'TrainPass123'
    );

    DBMS_OUTPUT.PUT_LINE('add_user: OK');
END;

DECLARE
    v_user_id NUMBER := 200089;
BEGIN
    administrator.pkg_trainers_admin.add_trainer(
        p_user_id        => v_user_id,
        p_first_name     => 'Сергей',
        p_last_name      => 'Кузнецов',
        p_phone          => '+79993334455',
        p_email          => 'kuznetsov@test.ru',
        p_specialization => 'Силовые тренировки'
    );

    DBMS_OUTPUT.PUT_LINE('add_trainer: OK');
END;


SELECT coach_id
FROM coaches
WHERE email = 'kuznetsov@test.ru';


DECLARE
    v_coach_id NUMBER := 24;
BEGIN
    administrator.pkg_trainers_admin.update_trainer(
        p_coach_id       => v_coach_id,
        p_phone          => '+79994445566',
        p_email          => 'kuznetsov_new@test.ru',
        p_specialization => 'Кроссфит'
    );

    DBMS_OUTPUT.PUT_LINE('update_trainer: OK');
END;



DECLARE
    v_coach_id NUMBER := 24;
BEGIN
    administrator.pkg_trainers_admin.change_status(
        p_coach_id => v_coach_id,
        p_status   => 'INACTIVE'
    );

    DBMS_OUTPUT.PUT_LINE('change_status: OK');
END;



DECLARE
    v_coach_id NUMBER := 24;
BEGIN
    administrator.pkg_trainers_admin.get_trainer_info_admin(v_coach_id);
END;



BEGIN
    administrator.pkg_trainers_admin.update_trainer(
        p_coach_id       => -1,
        p_phone          => '+70000000000',
        p_email          => 'error@test.ru',
        p_specialization => 'Йога'
    );
END;



------------ pkg_memberships_admin -------------
BEGIN
    administrator.pkg_memberships_admin.add_membership(
        p_name     => 'Premium',
        p_desc     => 'Полный доступ ко всем услугам клуба',
        p_duration => 12,
        p_price    => 25000
    );

    DBMS_OUTPUT.PUT_LINE('add_membership: OK');
END;


SELECT membership_id
FROM memberships
WHERE name = 'Premium';


DECLARE
    v_membership_id NUMBER := 21;
BEGIN
    administrator.pkg_memberships_admin.update_membership(
        p_membership_id => v_membership_id,
        p_price         => 27000
    );

    DBMS_OUTPUT.PUT_LINE('update_membership: OK');
END;



DECLARE
    v_membership_id NUMBER := 21;
BEGIN
    administrator.pkg_memberships_admin.get_membership_info_admin(v_membership_id);
END;



DECLARE
    v_membership_id NUMBER := 21;
BEGIN
    administrator.pkg_memberships_admin.delete_membership(v_membership_id);

    DBMS_OUTPUT.PUT_LINE('delete_membership: OK');
END;



BEGIN
    administrator.pkg_memberships_admin.get_membership_info_admin(-1);
END;


SELECT client_id
FROM clients
WHERE ROWNUM = 1;

SELECT membership_id
FROM memberships
WHERE ROWNUM = 1;


------------- pkg_orders_client -----------
DECLARE
    v_client_id NUMBER := 21;
    v_membership_id NUMBER := 1;
BEGIN
    administrator.pkg_orders_client.purchase_membership_admin(
        p_client_id     => v_client_id,
        p_membership_id => v_membership_id
    );

    DBMS_OUTPUT.PUT_LINE('purchase_membership_admin: OK');
END;



DECLARE
    v_client_id NUMBER := 41;
BEGIN
    administrator.pkg_orders_client.get_client_orders(v_client_id);
END;


SELECT order_id, client_id
FROM membership_orders
WHERE status = 'ACTIVE'
    AND ROWNUM = 1;


DECLARE
    v_order_id NUMBER := 41;
    v_client_id NUMBER := 21;
BEGIN
    administrator.pkg_orders_client.cancel_own_order_admin(
        p_order_id  => v_order_id,
        p_client_id => v_client_id
    );

    DBMS_OUTPUT.PUT_LINE('cancel_own_order_admin: OK');
END;


SELECT membership_id FROM memberships WHERE ROWNUM = 1;
SELECT * FROM CLIENTS;


BEGIN
    -- Контекст клиента

    administrator.pkg_orders_client.purchase_membership_client(
        p_membership_id => 1
    );

    DBMS_OUTPUT.PUT_LINE('purchase_membership_client: OK');
END;



BEGIN
    -- Контекст клиента

    administrator.pkg_orders_client.cancel_own_order_client(
        p_order_id => 42
    );

    DBMS_OUTPUT.PUT_LINE('cancel_own_order_client: OK');
END;



BEGIN
    -- Контекст клиента

    administrator.pkg_orders_client.cancel_own_order_client(
        p_order_id => -1
    );
END;



----------- pkg_trainer_schedule --------------
SELECT *
FROM coaches;


DECLARE
    v_trainer_id NUMBER := 3;
BEGIN
    administrator.pkg_trainer_schedule.add_session(
        p_trainer_id => v_trainer_id,
        p_name       => 'Персональная тренировка',
        p_date       => TRUNC(SYSDATE),
        p_start_time => TIMESTAMP '2025-12-17 19:00:00',
        p_end_time   => TIMESTAMP '2025-12-17 20:00:00',
        p_capacity   => 5
    );

    DBMS_OUTPUT.PUT_LINE('add_session: OK');
END;


SELECT coach_id
FROM coaches
WHERE ROWNUM = 1;

SELECT *
FROM schedules;


DECLARE
    v_trainer_id NUMBER := 21;
    v_schedule_id NUMBER := 21;
BEGIN
    administrator.pkg_trainer_schedule.update_session(
        p_trainer_id  => v_trainer_id,
        p_schedule_id => v_schedule_id,
        p_start_time  => TIMESTAMP '2025-12-16 11:00:00',
        p_end_time    => TIMESTAMP '2025-12-16 12:00:00'
    );

    DBMS_OUTPUT.PUT_LINE('update_session: OK');
END;



DECLARE
    v_trainer_id NUMBER := 3;
BEGIN
    administrator.pkg_trainer_schedule.get_my_schedule(
        p_trainer_id => v_trainer_id,
        p_date       => TRUNC(SYSDATE)
    );
END;



DECLARE
    v_trainer_id NUMBER := 21;
    v_schedule_id NUMBER := 21;
BEGIN
    administrator.pkg_trainer_schedule.delete_session(
        p_trainer_id  => v_trainer_id,
        p_schedule_id => v_schedule_id
    );

    DBMS_OUTPUT.PUT_LINE('delete_session: OK');
END;



BEGIN
    administrator.pkg_trainer_schedule.update_session(
        p_trainer_id  => -1,
        p_schedule_id => -1,
        p_start_time  => SYSTIMESTAMP,
        p_end_time    => SYSTIMESTAMP + INTERVAL '1' HOUR
    );
END;



------------- pkg_schedule_view ------------
BEGIN
    administrator.pkg_schedule_view.get_schedule_by_date(
        p_date => TRUNC(SYSDATE)
    );
END;



DECLARE
    v_trainer_id NUMBER := 21;
BEGIN
    administrator.pkg_schedule_view.get_schedule_for_trainer(
        p_trainer_id => v_trainer_id,
        p_date       => TRUNC(SYSDATE)
    );
END;



BEGIN
    administrator.pkg_schedule_view.get_schedule_by_date(
        p_date => DATE '2099-01-01'
    );
END;



------------ pkg_sessions_client --------------
SELECT * FROM clients;

SELECT * FROM schedules;


DECLARE
    v_client_id NUMBER := 5;
    v_schedule_id NUMBER := 3;
BEGIN
    administrator.pkg_sessions_client.book_session_admin(
        p_client_id   => v_client_id,
        p_schedule_id => v_schedule_id
    );

    DBMS_OUTPUT.PUT_LINE('book_session_admin: OK');
END;



BEGIN
    -- Контекст клиента
    
    administrator.pkg_sessions_client.book_session_client(
        p_schedule_id => 22
    );

    DBMS_OUTPUT.PUT_LINE('book_session_client: OK');
END;



DECLARE
    v_client_id NUMBER := 41;
BEGIN
    administrator.pkg_sessions_client.get_client_bookings(v_client_id);
END;



DECLARE
    v_client_id NUMBER := 21;
    v_schedule_id NUMBER := 22;
BEGIN
    administrator.pkg_sessions_client.cancel_booking_admin(
        p_client_id   => v_client_id,
        p_schedule_id => v_schedule_id
    );

    DBMS_OUTPUT.PUT_LINE('cancel_booking_admin: OK');
END;



BEGIN
    -- Контекст клиента

    administrator.pkg_sessions_client.cancel_booking_client(
        p_schedule_id => 22
    );

    DBMS_OUTPUT.PUT_LINE('cancel_booking_client: OK');
END;



BEGIN
    -- Контекст клиента

    administrator.pkg_sessions_client.cancel_booking_client(
        p_schedule_id => -1
    );
END;



------------- pkg_clients_trainer -------------
SELECT * FROM coaches;


DECLARE
    v_trainer_id NUMBER := 21;
BEGIN
    administrator.pkg_clients_trainer.get_my_clients(v_trainer_id);
END;



DECLARE
    v_trainer_id NUMBER := 21;
    v_client_id  NUMBER := 41;
BEGIN
    administrator.pkg_clients_trainer.get_client_details(
        p_trainer_id => v_trainer_id,
        p_client_id  => v_client_id
    );
END;



DECLARE
    v_trainer_id NUMBER := 21;
    v_client_id  NUMBER := 41;
BEGIN
    administrator.pkg_clients_trainer.get_client_attendance(
        p_trainer_id => v_trainer_id,
        p_client_id  => v_client_id
    );
END;



BEGIN
    administrator.pkg_clients_trainer.get_client_details(
        p_trainer_id => -1,
        p_client_id  => -1
    );
END;




---------------- pkg_json ------------------
DECLARE
    v_clob CLOB;
BEGIN
    administrator.pkg_json.read_json_file(
        p_file_name => 'test_users.json',
        p_clob      => v_clob
    );

    DBMS_OUTPUT.PUT_LINE('read_json_file: ' || SUBSTR(v_clob, 1, 500)); -- вывод первых 500 символов
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
END;



DECLARE
    v_clob CLOB := '[{"test": "value"}]';
BEGIN
    administrator.pkg_json.write_json_file(
        p_file_name => 'output_test.json',
        p_clob      => v_clob
    );

    DBMS_OUTPUT.PUT_LINE('write_json_file: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
END;



BEGIN
    administrator.pkg_json.export_users(p_file_name => 'export_users.json');
    DBMS_OUTPUT.PUT_LINE('export_users: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_json.import_users(p_file_name => 'export_users.json');
    DBMS_OUTPUT.PUT_LINE('import_users: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_json.export_clients(p_file_name => 'export_clients.json');
    DBMS_OUTPUT.PUT_LINE('export_clients: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_json.import_clients(p_file_name => 'export_clients.json');
    DBMS_OUTPUT.PUT_LINE('import_clients: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_json.export_coaches(p_file_name => 'export_coaches.json');
    DBMS_OUTPUT.PUT_LINE('export_coaches: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_json.import_coaches(p_file_name => 'export_coaches.json');
    DBMS_OUTPUT.PUT_LINE('import_coaches: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_json.export_memberships(p_file_name => 'export_memberships.json');
    DBMS_OUTPUT.PUT_LINE('export_memberships: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_json.import_memberships(p_file_name => 'export_memberships.json');
    DBMS_OUTPUT.PUT_LINE('import_memberships: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_json.export_membership_orders(p_file_name => 'export_orders.json');
    DBMS_OUTPUT.PUT_LINE('export_membership_orders: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_json.import_membership_orders(p_file_name => 'export_orders.json');
    DBMS_OUTPUT.PUT_LINE('import_membership_orders: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_json.export_schedules(p_file_name => 'export_schedules.json');
    DBMS_OUTPUT.PUT_LINE('export_schedules: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_json.import_schedules(p_file_name => 'export_schedules.json');
    DBMS_OUTPUT.PUT_LINE('import_schedules: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.export_client_session_records(p_file_name => 'export_client_sessions.json');
    DBMS_OUTPUT.PUT_LINE('export_client_session_records: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



BEGIN
    administrator.pkg_json.import_client_session_records(p_file_name => 'export_client_sessions.json');
    DBMS_OUTPUT.PUT_LINE('import_client_session_records: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;



-------------- pkg_analytics ----------------
BEGIN
    administrator.pkg_analytics.refresh_all_mv;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка теста refresh_all_mv: ' || SQLERRM);
END;



BEGIN
    administrator.pkg_analytics.report_membership_sales;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка теста report_membership_sales: ' || SQLERRM);
END;



BEGIN
    administrator.pkg_analytics.report_popular_memberships(p_top_n => 3);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка теста report_popular_memberships: ' || SQLERRM);
END;



--------------  Тест экспорта пользователей -----------------
DECLARE
    v_file_name VARCHAR2(100) := 'users_test_hundred2.json';
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Экспорт пользователей ===');
    administrator.pkg_json.export_users(v_file_name);
    DBMS_OUTPUT.PUT_LINE('Экспорт завершён. Файл: ' || v_file_name);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
END;



-- 3. Проверка содержимого файла (опционально, через UTL_FILE)
DECLARE
    l_clob CLOB;
BEGIN
    administrator.pkg_json.read_json_file('users_test_hundred1.json', l_clob);
    DBMS_OUTPUT.PUT_LINE('Содержимое файла:');
    DBMS_OUTPUT.PUT_LINE(l_clob);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);    
END;



-- 4. Очистка таблицы USERS (для теста импорта)
BEGIN
    DELETE FROM users;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Таблица USERS очищена.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
END;


-- 5. Тест импорта пользователей
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Импорт пользователей ===');
    administrator.pkg_json.import_users('users_test_hundred1.json');
    DBMS_OUTPUT.PUT_LINE('Импорт завершён.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
END;


-- 6. Проверка результата
SELECT user_id, username, role_name, is_active, must_change_password
FROM users;




------------- Регистрация клиента ---------------
BEGIN
    administrator.pkg_auth.register_user(
        p_username => 'Zhamir',
        p_password => 'zhamir123',
        p_first_name => 'Artemir',
        p_last_name => 'Zhamoidir',
        p_email => 'artzhamir@gmail.com',
        p_phone => '+375445732252',
        p_dob => DATE '1996-01-30'
    );
    DBMS_OUTPUT.PUT_LINE('Регистрация выполнена.');
END;


BEGIN
    administrator.pkg_auth.register_admin(
        p_username => 'admin',
        p_password => 'admin12345'
    );
    DBMS_OUTPUT.PUT_LINE('Регистрация выполнена.');
END;

BEGIN
    administrator.pkg_auth.register_trainer(
        p_username       => 'trainer',
        p_password       => 'trainer12345',
        p_first_name     => 'Иван',
        p_last_name      => 'Петров',
        p_email          => 'trainer@test.ru',
        p_phone          => '+79990001122',
        p_specialization => 'Crossfit'
    );
END;

---------- Авторизация клиента ------------
DECLARE
    v_role VARCHAR2(20);
BEGIN
    administrator.pkg_auth.login_user(
        p_username => 'Zhamir',
        p_password => 'zhamir123',
        p_role     => v_role
    );
    DBMS_OUTPUT.PUT_LINE('Авторизация успешна. Роль: ' || v_role);
END;


---------- Авторизация тренера ------------
DECLARE
    v_role VARCHAR2(20);
BEGIN
    administrator.pkg_auth.login_user(
        p_username => 'trainer_test',
        p_password => 'trainer123',
        p_role => v_role
    );
    DBMS_OUTPUT.PUT_LINE('Авторизация успешна. Роль: ' || v_role);
END;


--------- Покупка абонемента (заказ) ----------
BEGIN
    administrator.pkg_orders_client.purchase_membership_client(
        p_membership_id => 1
    );
    DBMS_OUTPUT.PUT_LINE('Абонемент успешно приобретен.');
END;


BEGIN
    administrator.pkg_orders_client.get_client_orders(
        p_client_id => 23
    );
    DBMS_OUTPUT.PUT_LINE('Список абонементов клиента получен.');
END;


BEGIN
    administrator.pkg_orders_client.cancel_own_order_client(
        p_order_id => 22
    );
    DBMS_OUTPUT.PUT_LINE('Абонемент отменен.');
END;


BEGIN
    administrator.pkg_sessions_client.book_session_client(
        p_schedule_id => 1
    );
    DBMS_OUTPUT.PUT_LINE('Запись на занятие прошла успешно.');
END;


BEGIN
    administrator.pkg_sessions_client.get_client_bookings(
        p_client_id => 23
    );
    DBMS_OUTPUT.PUT_LINE('Список занятий получен.');
END;


BEGIN
    administrator.pkg_sessions_client.cancel_booking_client(
        p_schedule_id => 1
    );
    DBMS_OUTPUT.PUT_LINE('Запись на занятие отменена.');
END;
