-- 1
select * from v$sga;

select * from gv$sga_dynamic_components;


-- 2
select * from v$parameter;


-- 3
select * from v$controlfile;


-- 4
create pfile = 'pfile1.ora' from spfile;


-- 5
create table test (
    id number primary key,
    value nvarchar2(30)
);

drop table test CASCADE CONSTRAINTS;

select * from dba_segments 
where segment_name = 'TEST';

insert into test values (1, 'test1');
insert into test values (2, 'test2');

select blocks, bytes 
from user_extents 
where segment_name = 'TEST';


-- 6
select * from v$process;

select sid, serial#, server 
from v$session 
where type = 'USER';

select sid, serial#, server, status 
from v$session 
where type = 'BACKGROUND';


-- 7
select t.tablespace_name, f.file_name from dba_tablespaces t
left outer join dba_data_files f
on t.tablespace_name = f.tablespace_name;


-- 8
select * from dba_roles;


-- 9
select * from dba_sys_privs 
WHERE grantee = 'DBA';

select * from dba_tab_privs 
WHERE grantee = 'DBA';


-- 10
select * from dba_users;


-- 11
create role test_role;

grant create session to test_role;
grant create table to test_role;

drop role test_role;


-- 12
create user test_user identified by 12345
default tablespace users
temporary tablespace temp
quota 10M on users;

grant test_role to test_user;

drop user test_user;


-- 13
select distinct profile 
from dba_profiles;


-- 14
select resource_name from dba_profiles 
where profile = 'DEFAULT';


-- 15
create profile secure_profile
LIMIT
    SESSIONS_PER_USER 3
    CONNECT_TIME 60
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LIFE_TIME 90;
    
alter user test_user profile secure_profile;


-- 16
create SEQUENCE s1
start with 1000
INCREMENT by 10
MINVALUE 0
MAXVALUE 10000
CYCLE
CACHE 30
ORDER;

drop SEQUENCE s1;

create table t1 (
    id number primary key,
    value1 number,
    value2 date
);

drop table t1 CASCADE CONSTRAINTS;

begin
    for i in 1..10 loop
        insert into t1 values (s1.nextval, i, sysdate);
    end loop;
end;

select * from t1;


-- 17
create SYNONYM t1_priv FOR t1;

create public SYNONYM t1_pub FOR t1;

select * from dba_synonyms;
select * from user_synonyms;


-- 18
declare
    v_id t1.id%type;
begin
    select id into v_id
    from t1
    where value1 < 10;
    
    dbms_output.put_line('id = ' || v_id);
    
EXCEPTION
    when too_many_rows then
        dbms_output.put_line('Больше одного значения');
    when no_data_found then
        dbms_output.put_line('Данные не найдены');
END;


-- 19
select * from v$logfile;


-- 20
select * from v$log where status = 'CURRENT';


-- 21
select * from v$controlfile;


-- 22
create table test_table (
    id number primary key,
    value nvarchar2(30)
);

drop table test_table CASCADE CONSTRAINTS;

begin
    for i in 1..100 loop
        insert into test_table values (i, 'row ' || i);
    end loop;
end;

select * from test_table;


-- 23
select * from dba_segments
where tablespace_name = 'SYSTEM';


-- 24
select * from all_objects;


-- 25
select blocks from user_extents
where segment_name = 'T1';


-- 26
select * from v$session
where username is not null;

-- 27
select log_mode from v$database;


-- 28
create view test_view
as
select * from t1
where value1 < 5
with read only;

select * from test_view;

drop view test_view;


-- 29
ALTER SESSION SET CONTAINER = CDB$ROOT;
ALTER SESSION SET CONTAINER = XEPDB1;

CREATE PLUGGABLE DATABASE ZAI_PDB
    ADMIN USER PDB_ADMIN IDENTIFIED BY 12345
    ROLES = (DBA)
    FILE_NAME_CONVERT = ('/opt/oracle/oradata/XE/',
                        '/opt/oracle/oradata/XE/ZAI_PDB/');

ALTER PLUGGABLE DATABASE ZAI_PDB OPEN;

ALTER SESSION SET CONTAINER = ZAI_PDB;

ALTER PLUGGABLE DATABASE ZAI_PDB CLOSE IMMEDIATE;
DROP PLUGGABLE DATABASE ZAI_PDB INCLUDING DATAFILES;

CREATE DATABASE LINK REMOTE_DB
CONNECT TO CURRENT_USER
USING 'XEPDB1';

SELECT * FROM ALL_DB_LINKS;

DROP DATABASE LINK REMOTE_DB;

-- SELECT * FROM @REMOTE_DB;


-- 30
DECLARE
    v NUMBER;
BEGIN
    BEGIN
        v:= 10 / 0;
    EXCEPTION
        WHEN ZERO_DIVIDE THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка деления');
            RAISE;
    END;
END;
