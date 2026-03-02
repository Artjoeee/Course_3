-- Создаём директорию на сервере Oracle
CREATE OR REPLACE DIRECTORY json_dir AS '/opt/oracle/json';
GRANT READ, WRITE ON DIRECTORY json_dir TO PUBLIC;

-- Пакет
CREATE OR REPLACE PACKAGE pkg_json IS
    -- Чтение JSON из файла в CLOB
    PROCEDURE read_json_file(p_file_name IN VARCHAR2, p_clob OUT CLOB);

    -- Запись CLOB в файл
    PROCEDURE write_json_file(p_file_name IN VARCHAR2, p_clob IN CLOB);

    -- Экспорт
    PROCEDURE export_users(p_file_name IN VARCHAR2);
    PROCEDURE export_clients(p_file_name IN VARCHAR2);
    PROCEDURE export_coaches(p_file_name IN VARCHAR2);
    PROCEDURE export_memberships(p_file_name IN VARCHAR2);
    PROCEDURE export_membership_orders(p_file_name IN VARCHAR2);
    PROCEDURE export_schedules(p_file_name IN VARCHAR2);
    PROCEDURE export_client_session_records(p_file_name IN VARCHAR2);

    -- Импорт
    PROCEDURE import_users(p_file_name IN VARCHAR2);
    PROCEDURE import_clients(p_file_name IN VARCHAR2);
    PROCEDURE import_coaches(p_file_name IN VARCHAR2);
    PROCEDURE import_memberships(p_file_name IN VARCHAR2);
    PROCEDURE import_membership_orders(p_file_name IN VARCHAR2);
    PROCEDURE import_schedules(p_file_name IN VARCHAR2);
    PROCEDURE import_client_session_records(p_file_name IN VARCHAR2);
END pkg_json;


-- Тело пакета
CREATE OR REPLACE PACKAGE BODY pkg_json IS

    --------------------------------------------------------------------
    -- Чтение JSON из файла
    --------------------------------------------------------------------
    PROCEDURE read_json_file(p_file_name IN VARCHAR2, p_clob OUT CLOB) IS
        l_file UTL_FILE.FILE_TYPE;
        l_buffer VARCHAR2(32767);
    BEGIN
        p_clob := '';
        l_file := UTL_FILE.FOPEN('JSON_DIR', p_file_name, 'R', 32767);
        LOOP
            BEGIN
                UTL_FILE.GET_LINE(l_file, l_buffer);
                p_clob := p_clob || l_buffer;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    EXIT;
            END;
        END LOOP;
        UTL_FILE.FCLOSE(l_file);
     EXCEPTION
        WHEN UTL_FILE.INVALID_PATH THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: неверная директория JSON_DIR.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка экспорта USERS: ' || SQLERRM);
    END;

    --------------------------------------------------------------------
    -- Запись CLOB в файл
    --------------------------------------------------------------------
    PROCEDURE write_json_file(p_file_name IN VARCHAR2, p_clob IN CLOB) IS
        l_file UTL_FILE.FILE_TYPE;
    BEGIN
        l_file := UTL_FILE.FOPEN('JSON_DIR', p_file_name, 'W', 32767);
        UTL_FILE.PUT_LINE(l_file, p_clob);
        UTL_FILE.FCLOSE(l_file);
     EXCEPTION
        WHEN UTL_FILE.INVALID_PATH THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: неверная директория JSON_DIR.');
        WHEN UTL_FILE.WRITE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка записи в файл ' || p_file_name);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка экспорта USERS: ' || SQLERRM);
    END;

    --------------------------------------------------------------------
    -- Экспорт USERS
    --------------------------------------------------------------------
    PROCEDURE export_users(p_file_name IN VARCHAR2) IS
        l_file  UTL_FILE.FILE_TYPE;
        is_first BOOLEAN := TRUE;
    BEGIN
        pkg_security.assert_admin;
    
        -- открываем файл
        l_file := UTL_FILE.FOPEN('JSON_DIR', p_file_name, 'W', 32767);
    
        -- начало JSON массива
        UTL_FILE.PUT_LINE(l_file, '[');
    
        -- курсор по строкам
        FOR r IN (
            SELECT user_id,
                   username,
                   password_hash,
                   RAWTOHEX(password_salt) AS password_salt,
                   role_name,
                   TO_CHAR(created_at,'YYYY-MM-DD HH24:MI:SS') AS created_at,
                   is_active,
                   must_change_password
            FROM users
            ORDER BY user_id
        )
        LOOP
            -- если не первая строка — ставим запятую
            IF NOT is_first THEN
                UTL_FILE.PUT_LINE(l_file, ',');
            END IF;
    
            is_first := FALSE;
    
            -- записываем JSON-объект
            UTL_FILE.PUT_LINE(l_file,
                '  {' ||
                '"user_id": ' || r.user_id || ',' ||
                '"username": "' || r.username || '",' ||
                '"password_hash": "' || r.password_hash || '",' ||
                '"password_salt": "' || r.password_salt || '",' ||
                '"role_name": "' || r.role_name || '",' ||
                '"created_at": "' || r.created_at || '",' ||
                '"is_active": "' || r.is_active || '",' ||
                '"must_change_password": "' || r.must_change_password || '"' ||
                '}'
            );
        END LOOP;
    
        -- конец JSON массива
        UTL_FILE.PUT_LINE(l_file, ']');
    
        UTL_FILE.FCLOSE(l_file);
    EXCEPTION
        WHEN UTL_FILE.INVALID_PATH THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: неверная директория JSON_DIR.');
        WHEN UTL_FILE.WRITE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка записи в файл ' || p_file_name);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка экспорта USERS: ' || SQLERRM);    
    END;


    --------------------------------------------------------------------
    -- Импорт USERS
    --------------------------------------------------------------------
    PROCEDURE import_users(p_file_name IN VARCHAR2) IS
        l_json CLOB;
    BEGIN
        pkg_security.assert_admin;
        read_json_file(p_file_name, l_json);

        INSERT INTO users(username, password_hash, password_salt, role_name, created_at, is_active, must_change_password)
        SELECT username,
               password_hash,
               HEXTORAW(password_salt),
               role_name,
               TO_DATE(created_at,'YYYY-MM-DD HH24:MI:SS'),
               is_active,
               must_change_password
        FROM JSON_TABLE(
            l_json, '$[*]'
            COLUMNS (
                username VARCHAR2(50) PATH '$.username',
                password_hash VARCHAR2(200) PATH '$.password_hash',
                password_salt VARCHAR2(32) PATH '$.password_salt',
                role_name VARCHAR2(20) PATH '$.role_name',
                created_at VARCHAR2(20) PATH '$.created_at',
                is_active CHAR(1) PATH '$.is_active',
                must_change_password CHAR(1) PATH '$.must_change_password'
            )
        );
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта USERS: дубликат данных.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта USERS: ' || SQLERRM);
    END;

    --------------------------------------------------------------------
    -- Экспорт CLIENTS
    --------------------------------------------------------------------
    PROCEDURE export_clients(p_file_name IN VARCHAR2) IS
        l_file UTL_FILE.FILE_TYPE;
        is_first BOOLEAN := TRUE;
    BEGIN
        pkg_security.assert_admin;
    
        l_file := UTL_FILE.FOPEN('JSON_DIR', p_file_name, 'W', 32767);
        UTL_FILE.PUT_LINE(l_file, '[');
    
        FOR r IN (
            SELECT client_id, user_id, first_name, last_name,
                   phone_number, email,
                   TO_CHAR(date_of_birth,'YYYY-MM-DD') AS date_of_birth,
                   TO_CHAR(registration_date,'YYYY-MM-DD') AS registration_date,
                   status
            FROM clients
            ORDER BY client_id
        ) LOOP
            IF NOT is_first THEN
                UTL_FILE.PUT_LINE(l_file, ',');
            END IF;
            is_first := FALSE;
    
            UTL_FILE.PUT_LINE(l_file,
                '  {' ||
                '"client_id": ' || r.client_id || ',' ||
                '"user_id": ' || NVL(TO_CHAR(r.user_id),'null') || ',' ||
                '"first_name": "' || r.first_name || '",' ||
                '"last_name": "' || r.last_name || '",' ||
                '"phone_number": "' || r.phone_number || '",' ||
                '"email": "' || r.email || '",' ||
                '"date_of_birth": "' || r.date_of_birth || '",' ||
                '"registration_date": "' || r.registration_date || '",' ||
                '"status": "' || r.status || '"' ||
                '}'
            );
        END LOOP;
    
        UTL_FILE.PUT_LINE(l_file, ']');
        UTL_FILE.FCLOSE(l_file);
    EXCEPTION
        WHEN UTL_FILE.INVALID_PATH THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: неверная директория JSON_DIR.');
        WHEN UTL_FILE.WRITE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка записи в файл ' || p_file_name);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка экспорта CLIENTS: ' || SQLERRM);    
    END;


    --------------------------------------------------------------------
    -- Импорт CLIENTS
    --------------------------------------------------------------------
    PROCEDURE import_clients(p_file_name IN VARCHAR2) IS
        l_json CLOB;
    BEGIN
        pkg_security.assert_admin;
        read_json_file(p_file_name, l_json);

        INSERT INTO clients(user_id, first_name, last_name, phone_number, email, date_of_birth, registration_date, status)
        SELECT user_id,
               first_name,
               last_name,
               phone_number,
               email,
               TO_DATE(date_of_birth,'YYYY-MM-DD'),
               TO_DATE(registration_date,'YYYY-MM-DD'),
               status
        FROM JSON_TABLE(
            l_json, '$[*]'
            COLUMNS (
                user_id NUMBER PATH '$.user_id',
                first_name VARCHAR2(50) PATH '$.first_name',
                last_name VARCHAR2(50) PATH '$.last_name',
                phone_number VARCHAR2(20) PATH '$.phone_number',
                email VARCHAR2(100) PATH '$.email',
                date_of_birth VARCHAR2(20) PATH '$.date_of_birth',
                registration_date VARCHAR2(20) PATH '$.registration_date',
                status VARCHAR2(20) PATH '$.status'
            )
        );
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта CLIENTS: дубликат данных.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта CLIENTS: ' || SQLERRM);
    END;

    --------------------------------------------------------------------
    -- Экспорт COACHES
    --------------------------------------------------------------------
    PROCEDURE export_coaches(p_file_name IN VARCHAR2) IS
        l_file UTL_FILE.FILE_TYPE;
        is_first BOOLEAN := TRUE;
    BEGIN
        pkg_security.assert_admin;
    
        l_file := UTL_FILE.FOPEN('JSON_DIR', p_file_name, 'W', 32767);
        UTL_FILE.PUT_LINE(l_file, '[');
    
        FOR r IN (
            SELECT coach_id, user_id, first_name, last_name,
                   phone_number, email, specialization,
                   TO_CHAR(hire_date,'YYYY-MM-DD') AS hire_date,
                   status
            FROM coaches
            ORDER BY coach_id
        ) LOOP
            IF NOT is_first THEN
                UTL_FILE.PUT_LINE(l_file, ',');
            END IF;
            is_first := FALSE;
    
            UTL_FILE.PUT_LINE(l_file,
                '  {' ||
                '"coach_id": ' || r.coach_id || ',' ||
                '"user_id": ' || NVL(TO_CHAR(r.user_id),'null') || ',' ||
                '"first_name": "' || r.first_name || '",' ||
                '"last_name": "' || r.last_name || '",' ||
                '"phone_number": "' || r.phone_number || '",' ||
                '"email": "' || r.email || '",' ||
                '"specialization": "' || r.specialization || '",' ||
                '"hire_date": "' || r.hire_date || '",' ||
                '"status": "' || r.status || '"' ||
                '}'
            );
        END LOOP;
    
        UTL_FILE.PUT_LINE(l_file, ']');
        UTL_FILE.FCLOSE(l_file);
    EXCEPTION
        WHEN UTL_FILE.INVALID_PATH THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: неверная директория JSON_DIR.');
        WHEN UTL_FILE.WRITE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка записи в файл ' || p_file_name);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка экспорта COACHES: ' || SQLERRM);    
    END;


    --------------------------------------------------------------------
    -- Импорт COACHES
    --------------------------------------------------------------------
    PROCEDURE import_coaches(p_file_name IN VARCHAR2) IS
        l_json CLOB;
    BEGIN
        pkg_security.assert_admin;
        read_json_file(p_file_name, l_json);

        INSERT INTO coaches(user_id, first_name, last_name, phone_number, email, specialization, hire_date, status)
        SELECT user_id, first_name, last_name, phone_number, email, specialization, TO_DATE(hire_date,'YYYY-MM-DD'), status
        FROM JSON_TABLE(
            l_json, '$[*]'
            COLUMNS (
                user_id NUMBER PATH '$.user_id',
                first_name VARCHAR2(50) PATH '$.first_name',
                last_name VARCHAR2(50) PATH '$.last_name',
                phone_number VARCHAR2(20) PATH '$.phone_number',
                email VARCHAR2(100) PATH '$.email',
                specialization VARCHAR2(100) PATH '$.specialization',
                hire_date VARCHAR2(20) PATH '$.hire_date',
                status VARCHAR2(20) PATH '$.status'
            )
        );
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта COACHES: дубликат данных.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта COACHES: ' || SQLERRM);
    END;

    --------------------------------------------------------------------
    -- Экспорт MEMBERSHIPS
    --------------------------------------------------------------------
    PROCEDURE export_memberships(p_file_name IN VARCHAR2) IS
        l_file UTL_FILE.FILE_TYPE;
        is_first BOOLEAN := TRUE;
    BEGIN
        pkg_security.assert_admin;
    
        l_file := UTL_FILE.FOPEN('JSON_DIR', p_file_name, 'W', 32767);
        UTL_FILE.PUT_LINE(l_file, '[');
    
        FOR r IN (
            SELECT membership_id, name, description, duration_months, price
            FROM memberships
            ORDER BY membership_id
        ) LOOP
            IF NOT is_first THEN
                UTL_FILE.PUT_LINE(l_file, ',');
            END IF;
            is_first := FALSE;
    
            UTL_FILE.PUT_LINE(l_file,
                '  {' ||
                '"membership_id": ' || r.membership_id || ',' ||
                '"name": "' || r.name || '",' ||
                '"description": "' || r.description || '",' ||
                '"duration_months": ' || r.duration_months || ',' ||
                '"price": ' || r.price ||
                '}'
            );
        END LOOP;
    
        UTL_FILE.PUT_LINE(l_file, ']');
        UTL_FILE.FCLOSE(l_file);
    EXCEPTION
        WHEN UTL_FILE.INVALID_PATH THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: неверная директория JSON_DIR.');
        WHEN UTL_FILE.WRITE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка записи в файл ' || p_file_name);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка экспорта MEMBERSHIPS: ' || SQLERRM);    
    END;


    --------------------------------------------------------------------
    -- Импорт MEMBERSHIPS
    --------------------------------------------------------------------
    PROCEDURE import_memberships(p_file_name IN VARCHAR2) IS
        l_json CLOB;
    BEGIN
        pkg_security.assert_admin;
        read_json_file(p_file_name, l_json);

        INSERT INTO memberships(name, description, duration_months, price)
        SELECT name, description, duration_months, price
        FROM JSON_TABLE(
            l_json, '$[*]'
            COLUMNS (
                name VARCHAR2(50) PATH '$.name',
                description VARCHAR2(200) PATH '$.description',
                duration_months NUMBER PATH '$.duration_months',
                price NUMBER PATH '$.price'
            )
        );
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта MEMBERSHIPS: дубликат данных.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта MEMBERSHIPS: ' || SQLERRM);
    END;

    --------------------------------------------------------------------
    -- Экспорт MEMBERSHIP_ORDERS
    --------------------------------------------------------------------
    PROCEDURE export_membership_orders(p_file_name IN VARCHAR2) IS
        l_file UTL_FILE.FILE_TYPE;
        is_first BOOLEAN := TRUE;
    BEGIN
        pkg_security.assert_admin;
    
        l_file := UTL_FILE.FOPEN('JSON_DIR', p_file_name, 'W', 32767);
        UTL_FILE.PUT_LINE(l_file, '[');
    
        FOR r IN (
            SELECT order_id, client_id, membership_id,
                   TO_CHAR(order_date,'YYYY-MM-DD') AS order_date,
                   TO_CHAR(start_date,'YYYY-MM-DD') AS start_date,
                   TO_CHAR(end_date,'YYYY-MM-DD') AS end_date,
                   status
            FROM membership_orders
            ORDER BY order_id
        ) LOOP
            IF NOT is_first THEN
                UTL_FILE.PUT_LINE(l_file, ',');
            END IF;
            is_first := FALSE;
    
            UTL_FILE.PUT_LINE(l_file,
                '  {' ||
                '"order_id": ' || r.order_id || ',' ||
                '"client_id": ' || r.client_id || ',' ||
                '"membership_id": ' || r.membership_id || ',' ||
                '"order_date": "' || r.order_date || '",' ||
                '"start_date": "' || r.start_date || '",' ||
                '"end_date": "' || r.end_date || '",' ||
                '"status": "' || r.status || '"' ||
                '}'
            );
        END LOOP;
    
        UTL_FILE.PUT_LINE(l_file, ']');
        UTL_FILE.FCLOSE(l_file);
    EXCEPTION
        WHEN UTL_FILE.INVALID_PATH THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: неверная директория JSON_DIR.');
        WHEN UTL_FILE.WRITE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка записи в файл ' || p_file_name);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка экспорта MEMBERSHIP_ORDERS: ' || SQLERRM);    
    END;


    --------------------------------------------------------------------
    -- Импорт MEMBERSHIP_ORDERS
    --------------------------------------------------------------------
    PROCEDURE import_membership_orders(p_file_name IN VARCHAR2) IS
        l_json CLOB;
    BEGIN
        pkg_security.assert_admin;
        read_json_file(p_file_name, l_json);

        INSERT INTO membership_orders(client_id, membership_id, order_date, start_date, end_date, status)
        SELECT client_id, membership_id, TO_DATE(order_date,'YYYY-MM-DD'), TO_DATE(start_date,'YYYY-MM-DD'), TO_DATE(end_date,'YYYY-MM-DD'), status
        FROM JSON_TABLE(
            l_json, '$[*]'
            COLUMNS (
                client_id NUMBER PATH '$.client_id',
                membership_id NUMBER PATH '$.membership_id',
                order_date VARCHAR2(20) PATH '$.order_date',
                start_date VARCHAR2(20) PATH '$.start_date',
                end_date VARCHAR2(20) PATH '$.end_date',
                status VARCHAR2(20) PATH '$.status'
            )
        );
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта MEMBERSHIP_ORDERS: дубликат данных.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта MEMBERSHIP_ORDERS: ' || SQLERRM);
    END;

    --------------------------------------------------------------------
    -- Экспорт SCHEDULES
    --------------------------------------------------------------------
    PROCEDURE export_schedules(p_file_name IN VARCHAR2) IS
        l_file UTL_FILE.FILE_TYPE;
        is_first BOOLEAN := TRUE;
    BEGIN
        pkg_security.assert_admin;
    
        l_file := UTL_FILE.FOPEN('JSON_DIR', p_file_name, 'W', 32767);
        UTL_FILE.PUT_LINE(l_file, '[');
    
        FOR r IN (
            SELECT schedule_id, coach_id, session_name,
                   TO_CHAR(session_date,'YYYY-MM-DD') AS session_date,
                   TO_CHAR(start_time,'YYYY-MM-DD HH24:MI:SS') AS start_time,
                   TO_CHAR(end_time,'YYYY-MM-DD HH24:MI:SS') AS end_time,
                   capacity
            FROM schedules
            ORDER BY schedule_id
        ) LOOP
            IF NOT is_first THEN
                UTL_FILE.PUT_LINE(l_file, ',');
            END IF;
            is_first := FALSE;
    
            UTL_FILE.PUT_LINE(l_file,
                '  {' ||
                '"schedule_id": ' || r.schedule_id || ',' ||
                '"coach_id": ' || NVL(TO_CHAR(r.coach_id),'null') || ',' ||
                '"session_name": "' || r.session_name || '",' ||
                '"session_date": "' || r.session_date || '",' ||
                '"start_time": "' || r.start_time || '",' ||
                '"end_time": "' || r.end_time || '",' ||
                '"capacity": ' || r.capacity ||
                '}'
            );
        END LOOP;
    
        UTL_FILE.PUT_LINE(l_file, ']');
        UTL_FILE.FCLOSE(l_file);
    EXCEPTION
        WHEN UTL_FILE.INVALID_PATH THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: неверная директория JSON_DIR.');
        WHEN UTL_FILE.WRITE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка записи в файл ' || p_file_name);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка экспорта SCHEDULES: ' || SQLERRM);    
    END;


    --------------------------------------------------------------------
    -- Импорт SCHEDULES
    --------------------------------------------------------------------
    PROCEDURE import_schedules(p_file_name IN VARCHAR2) IS
        l_json CLOB;
    BEGIN
        pkg_security.assert_admin;
        read_json_file(p_file_name, l_json);

        INSERT INTO schedules(coach_id, session_name, session_date, start_time, end_time, capacity)
        SELECT coach_id, session_name, TO_DATE(session_date,'YYYY-MM-DD'),
               TO_TIMESTAMP(start_time,'YYYY-MM-DD HH24:MI:SS'),
               TO_TIMESTAMP(end_time,'YYYY-MM-DD HH24:MI:SS'),
               capacity
        FROM JSON_TABLE(
            l_json, '$[*]'
            COLUMNS (
                coach_id NUMBER PATH '$.coach_id',
                session_name VARCHAR2(100) PATH '$.session_name',
                session_date VARCHAR2(20) PATH '$.session_date',
                start_time VARCHAR2(20) PATH '$.start_time',
                end_time VARCHAR2(20) PATH '$.end_time',
                capacity NUMBER PATH '$.capacity'
            )
        );
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта SCHEDULES: дубликат данных.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта SCHEDULES: ' || SQLERRM);
    END;

    --------------------------------------------------------------------
    -- Экспорт CLIENT_SESSION_RECORDS
    --------------------------------------------------------------------
    PROCEDURE export_client_session_records(p_file_name IN VARCHAR2) IS
        l_file UTL_FILE.FILE_TYPE;
        is_first BOOLEAN := TRUE;
    BEGIN
        pkg_security.assert_admin;
    
        l_file := UTL_FILE.FOPEN('JSON_DIR', p_file_name, 'W', 32767);
        UTL_FILE.PUT_LINE(l_file, '[');
    
        FOR r IN (
            SELECT record_id, client_id, schedule_id,
                   TO_CHAR(attendance_date,'YYYY-MM-DD') AS attendance_date,
                   performance_notes, attended
            FROM client_session_records
            ORDER BY record_id
        ) LOOP
            IF NOT is_first THEN
                UTL_FILE.PUT_LINE(l_file, ',');
            END IF;
            is_first := FALSE;
    
            UTL_FILE.PUT_LINE(l_file,
                '  {' ||
                '"record_id": ' || r.record_id || ',' ||
                '"client_id": ' || r.client_id || ',' ||
                '"schedule_id": ' || r.schedule_id || ',' ||
                '"attendance_date": "' || r.attendance_date || '",' ||
                '"performance_notes": "' || r.performance_notes || '",' ||
                '"attended": "' || r.attended || '"' ||
                '}'
            );
        END LOOP;
    
        UTL_FILE.PUT_LINE(l_file, ']');
        UTL_FILE.FCLOSE(l_file);
    EXCEPTION
        WHEN UTL_FILE.INVALID_PATH THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: неверная директория JSON_DIR.');
        WHEN UTL_FILE.WRITE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка записи в файл ' || p_file_name);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка экспорта CLIENT_SESSION_RECORDS: ' || SQLERRM);    
    END;


    --------------------------------------------------------------------
    -- Импорт CLIENT_SESSION_RECORDS
    --------------------------------------------------------------------
    PROCEDURE import_client_session_records(p_file_name IN VARCHAR2) IS
        l_json CLOB;
    BEGIN
        pkg_security.assert_admin;
        read_json_file(p_file_name, l_json);

        INSERT INTO client_session_records(client_id, schedule_id, attendance_date, performance_notes, attended)
        SELECT client_id, schedule_id, TO_DATE(attendance_date,'YYYY-MM-DD'), performance_notes, attended
        FROM JSON_TABLE(
            l_json, '$[*]'
            COLUMNS (
                client_id NUMBER PATH '$.client_id',
                schedule_id NUMBER PATH '$.schedule_id',
                attendance_date VARCHAR2(20) PATH '$.attendance_date',
                performance_notes VARCHAR2(200) PATH '$.performance_notes',
                attended CHAR(1) PATH '$.attended'
            )
        );
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта CLIENT_SESSION_RECORDS: дубликат данных.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка импорта CLIENT_SESSION_RECORDS: ' || SQLERRM);
    END;

END pkg_json;


DROP PACKAGE pkg_json;