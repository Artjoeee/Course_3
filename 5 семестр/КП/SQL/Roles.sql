-- ===========================
-- 1. Создание ролей
-- ===========================
CREATE ROLE ROLE_ADMIN;
CREATE ROLE ROLE_TRAINER;
CREATE ROLE ROLE_CLIENT;


-- ===========================
-- 2. Ограничение прямого доступа к таблицам
-- ===========================
REVOKE ALL ON USERS FROM PUBLIC;
REVOKE ALL ON CLIENTS FROM PUBLIC;
REVOKE ALL ON COACHES FROM PUBLIC;
REVOKE ALL ON MEMBERSHIPS FROM PUBLIC;
REVOKE ALL ON MEMBERSHIP_ORDERS FROM PUBLIC;
REVOKE ALL ON SCHEDULES FROM PUBLIC;
REVOKE ALL ON CLIENT_SESSION_RECORDS FROM PUBLIC;


------------------------------------------------------------
-- АДМИНИСТРАТОР — полный доступ
------------------------------------------------------------
GRANT EXECUTE ON administrator.pkg_users_admin        TO role_admin;
GRANT EXECUTE ON administrator.pkg_clients_admin      TO role_admin;
GRANT EXECUTE ON administrator.pkg_trainers_admin      TO role_admin;
GRANT EXECUTE ON administrator.pkg_memberships_admin  TO role_admin;
-- Админ имеет право работать с любыми тренировками и заказами
GRANT EXECUTE ON administrator.pkg_trainer_schedule   TO role_admin;
GRANT EXECUTE ON administrator.pkg_clients_trainer    TO role_admin;
GRANT EXECUTE ON administrator.pkg_sessions_client    TO role_admin;
GRANT EXECUTE ON administrator.pkg_orders_client      TO role_admin;
-- Просмотр расписания
GRANT EXECUTE ON administrator.pkg_schedule_view      TO role_admin;
GRANT EXECUTE ON administrator.pkg_analytics      TO role_admin;
GRANT EXECUTE ON administrator.pkg_json      TO role_admin;
GRANT EXECUTE ON administrator.pkg_auth      TO role_admin;


------------------------------------------------------------
-- ТРЕНЕР — строго ограниченный доступ
------------------------------------------------------------
-- Может видеть только своё расписание и создавать/редактировать свои занятия
GRANT EXECUTE ON administrator.pkg_trainer_schedule   TO role_trainer;
-- Может видеть клиентов, которые посещают его занятия
GRANT EXECUTE ON administrator.pkg_clients_trainer    TO role_trainer;
-- Может видеть расписание
GRANT EXECUTE ON administrator.pkg_schedule_view      TO role_trainer;
GRANT EXECUTE ON administrator.pkg_auth      TO role_trainer;


------------------------------------------------------------
-- КЛИЕНТ — минимальный доступ
------------------------------------------------------------
-- Просмотр расписания
GRANT EXECUTE ON administrator.pkg_schedule_view      TO role_client;
-- Запись на занятия, отмена, просмотр своих посещений
GRANT EXECUTE ON administrator.pkg_sessions_client    TO role_client;
-- Работа со своими заказами (покупка абонементов)
GRANT EXECUTE ON administrator.pkg_orders_client      TO role_client;
GRANT EXECUTE ON administrator.pkg_auth               TO role_client;


-- ===========================
-- 4. Создание пользователей
-- ===========================
-- Администратор
CREATE USER admin_user IDENTIFIED BY admin123;
GRANT ROLE_ADMIN TO admin_user;
GRANT CREATE SESSION TO admin_user;
GRANT EXECUTE ON DBMS_CRYPTO TO admin_user;
GRANT READ, WRITE ON DIRECTORY JSON_DIR TO admin_user;


-- Тренер
CREATE USER trainer_user IDENTIFIED BY trainer123;
GRANT ROLE_TRAINER TO trainer_user;
GRANT CREATE SESSION TO trainer_user;
GRANT EXECUTE ON DBMS_CRYPTO TO trainer_user;


-- Клиент
CREATE USER client_user IDENTIFIED BY client123;
GRANT ROLE_CLIENT TO client_user;
GRANT CREATE SESSION TO client_user;
GRANT EXECUTE ON DBMS_CRYPTO TO client_user;


DROP USER admin_user;
DROP USER trainer_user;
DROP USER client_user;

DROP ROLE ROLE_ADMIN;
DROP ROLE ROLE_TRAINER;
DROP ROLE ROLE_CLIENT;