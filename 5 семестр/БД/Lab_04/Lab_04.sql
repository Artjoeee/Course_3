SELECT name FROM v$datafile;

// 1
SELECT file_name, tablespace_name, bytes/1024/1024 AS mb, status
FROM dba_data_files
ORDER BY tablespace_name;

SELECT file_name, tablespace_name, bytes/1024/1024 AS mb
FROM dba_temp_files
ORDER BY tablespace_name;

SELECT name, enabled FROM v$datafile;
SELECT name, enabled FROM v$tempfile;


// 2
ALTER SESSION SET CONTAINER = XEPDB1;

CREATE ROLE RL_ZAICORE;
GRANT CREATE SESSION,
        CREATE TABLE,
        CREATE TABLESPACE,
        CREATE VIEW,
        CREATE PROCEDURE,
        DROP ANY TABLE,
        DROP TABLESPACE,
        DROP ANY VIEW,
        DROP ANY PROCEDURE TO RL_ZAICORE;
        
DROP ROLE RL_ZAICORE;

CREATE PROFILE PF_ZAICORE LIMIT
    PASSWORD_LIFE_TIME 180
    SESSIONS_PER_USER 3
    FAILED_LOGIN_ATTEMPTS 7
    PASSWORD_LOCK_TIME 1
    PASSWORD_REUSE_TIME 10
    PASSWORD_GRACE_TIME DEFAULT
    CONNECT_TIME 180
    IDLE_TIME 30;

DROP PROFILE PF_ZAICORE CASCADE;

CREATE TABLESPACE ZAI_QDATA
    DATAFILE 'ZAI_QDATA.dbf' 
    SIZE 10M
    OFFLINE;

ALTER DATABASE DATAFILE 'ZAI_QDATA.dbf' ONLINE;
ALTER TABLESPACE ZAI_QDATA ONLINE;

DROP TABLESPACE ZAI_QDATA INCLUDING CONTENTS AND DATAFILES;

CREATE USER ZAI IDENTIFIED BY 12345
    DEFAULT TABLESPACE ZAI_QDATA QUOTA 2M ON ZAI_QDATA
    PROFILE PF_ZAICORE
    ACCOUNT UNLOCK;

GRANT RL_ZAICORE TO ZAI;

DROP USER ZAI;

--ZAI_USER
CREATE TABLE ZAI_T1 (
    ID NUMBER PRIMARY KEY,
    DESCR VARCHAR2(100)
) TABLESPACE ZAI_QDATA;

INSERT INTO ZAI_T1 VALUES (1, 'Один');
INSERT INTO ZAI_T1 VALUES (2, 'Два');
INSERT INTO ZAI_T1 VALUES (3, 'Три');

DROP TABLE ZAI_T1;

COMMIT;


// 3
SELECT segment_name, segment_type, owner, bytes/1024/1024 AS mb
FROM dba_segments
WHERE tablespace_name = 'ZAI_QDATA';

// 4
--ZAI_USER
DROP TABLE ZAI_T1;

--ZAI
SELECT segment_name, segment_type
FROM dba_segments
WHERE tablespace_name = 'ZAI_QDATA';

--ZAI_USER
SELECT object_name, original_name, type, droptime
FROM user_recyclebin;


// 5
--ZAI_USER
FLASHBACK TABLE ZAI_T1 TO BEFORE DROP;

--ZAI
SELECT segment_name, segment_type
FROM dba_segments
WHERE tablespace_name = 'ZAI_QDATA';


// 6
BEGIN
  FOR i IN 4..10003 LOOP
    INSERT INTO ZAI_T1 (ID, DESCR) VALUES (i, 'data_' || i);
    IF MOD(i,1000)=0 THEN
      COMMIT;
    END IF;
  END LOOP;
  COMMIT;
END;

SELECT * FROM ZAI_T1
ORDER BY id;


// 7
SELECT extents, bytes, blocks FROM dba_segments WHERE segment_name = 'ZAI_T1';
SELECT * FROM dba_extents WHERE segment_name = 'ZAI_T1';


// 8
DROP TABLESPACE ZAI_QDATA INCLUDING CONTENTS AND DATAFILES;


// 9
ALTER SESSION SET CONTAINER = CDB$ROOT;

SELECT group#, status, members
FROM v$log;


// 10
SELECT group#, member FROM V$LOGFILE;


// 11
-- как SYS
SELECT group#, status FROM v$log;

ALTER SYSTEM SWITCH LOGFILE;

SELECT SYSTIMESTAMP FROM dual;


// 12
SELECT group#, member FROM V$LOGFILE;

ALTER DATABASE ADD LOGFILE GROUP 10 (
 '/opt/oracle/oradata/XE/redo10a.log',
 '/opt/oracle/oradata/XE/redo10b.log',
 '/opt/oracle/oradata/XE/redo10c.log'
) SIZE 50M;

SELECT group#, status FROM v$log;

ALTER SYSTEM SWITCH LOGFILE;

SELECT GROUP#, STATUS, SEQUENCE#, FIRST_CHANGE#, FIRST_TIME FROM V$LOG;


// 13
ALTER DATABASE DROP LOGFILE GROUP 10;

SELECT group#, status FROM v$log;
SELECT group#, member FROM V$LOGFILE;


// 14
ARCHIVE LOG LIST;

SELECT DBID, NAME, LOG_MODE FROM V$DATABASE;


// 15

SELECT sequence#, first_change#, name FROM V$ARCHIVED_LOG;

// 16 
-- docker exec -it oracle-xe bash
-- sqlplus sys/MyStrongPassw0rd@XE as sysdba

-- SHUTDOWN IMMEDIATE;
-- CONNECT / AS SYSDBA
-- STARTUP MOUNT;
-- ALTER DATABASE ARCHIVELOG;
-- ALTER DATABASE OPEN;

SHOW PARAMETER log_archive_dest;
SHOW PARAMETER db_recovery_file_dest;

select DBID, NAME, LOG_MODE from V$DATABASE;
select INSTANCE_NAME, ARCHIVER, ACTIVE_STATE from V$INSTANCE;


// 17
SELECT group#, status FROM v$log;

ALTER SYSTEM SWITCH LOGFILE;

select sequence#, first_change#, name from V$ARCHIVED_LOG;


// 18
-- docker exec -it oracle-xe bash
-- sqlplus sys/MyStrongPassw0rd@XE as sysdba

-- SHUTDOWN IMMEDIATE;
-- CONNECT / AS SYSDBA
-- STARTUP MOUNT;
-- ALTER DATABASE NOARCHIVELOG;
-- ALTER DATABASE OPEN;

ARCHIVE LOG LIST;

select DBID, name, LOG_MODE from V$DATABASE;
select INSTANCE_NAME, ARCHIVER, ACTIVE_STATE from V$INSTANCE;


// 19
SELECT name FROM v$controlfile;


// 20
ALTER DATABASE BACKUP CONTROLFILE TO TRACE;
-- /opt/oracle/diag/rdbms/xe/XE/trace/XE_ora_697.trc

-- Показывает информацию о записях секций контрольного файла
select * from V$CONTROLFILE_RECORD_SECTION;

// 21
SHOW PARAMETER spfile;

SELECT value FROM v$parameter WHERE name='spfile';


// 22
CREATE PFILE='/opt/oracle/dbs/ZAI_PFILE.ORA' FROM SPFILE;

-- cat /opt/oracle/dbs/ZAI_PFILE.ORA


// 23
select * from V$PWFILE_USERS;
SHOW PARAMETER remote_login_passwordfile;

-- ls $ORACLE_HOME/dbs/orapwXE


// 24
SHOW PARAMETER diagnostic_dest;
SHOW PARAMETER background_dump_dest;
SHOW PARAMETER user_dump_dest;
SHOW PARAMETER core_dump_dest;

SELECT * FROM V$DIAG_INFO;


// 25
-- cat /opt/oracle/diag/rdbms/xe/XE/alert/log.xml


// 26
-- Таблица
DROP TABLE ZAI_T1 PURGE;

-- Табспейс (если ещё остался)
DROP TABLESPACE ZAI_QDATA INCLUDING CONTENTS AND DATAFILES;

-- Drop redo group (после переключения и убедившись, что группа не active)
ALTER DATABASE DROP LOGFILE GROUP 10;

-- rm /opt/oracle/homes/OraDBHome21cXE/dbs/arch1_101_1181008281.dbf
-- rm /opt/oracle/diag/rdbms/xe/XE/trace/XE_ora_697.trc
-- rm /opt/oracle/dbs/ZAI_PFILE.ORA


SELECT file_name FROM dba_data_files WHERE file_name LIKE '%ZAI_QDATA%';
SELECT member FROM v$logfile WHERE member LIKE '%redo10%';
SELECT name FROM v$archived_log WHERE name LIKE '%ZAI%';
SELECT name FROM v$parameter WHERE value LIKE '%ZAI%';
SELECT * FROM user_recyclebin WHERE original_name = 'ZAI_T1';
