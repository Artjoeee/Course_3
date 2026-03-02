EXEC xp_readerrorlog 0, 1, N'Login failed';

DECLARE @login SYSNAME = 'student';

DECLARE @kill NVARCHAR(MAX) = (
    SELECT STRING_AGG('KILL ' + CAST(session_id AS NVARCHAR(10)), '; ')
    FROM sys.dm_exec_sessions
    WHERE login_name = @login
);

PRINT @kill;
EXEC(@kill);


-- 1 создаем бд
CREATE DATABASE ZAI;
GO

DROP DATABASE ZAI;

-- 2 проверяем (можно в инспекторе посмотреть)
SELECT name FROM sys.databases;

-- 3 переключаемся
USE ZAI;
GO

-- 4 создаем пользователя
USE master;
GO

CREATE LOGIN student
WITH PASSWORD = N'fitfit',
     DEFAULT_DATABASE = [master],
     CHECK_POLICY = ON,
     CHECK_EXPIRATION = OFF;
GO

DROP LOGIN student;
-----------------------------------------
USE ZAI;
GO

CREATE USER student FOR LOGIN student;
ALTER ROLE db_owner ADD MEMBER student;

ALTER SERVER ROLE [sysadmin] ADD MEMBER student;
GO

DROP USER student;

USE master;
GO

GRANT ALTER ANY LOGIN TO student;
GRANT VIEW SERVER STATE TO student;
GRANT SHUTDOWN TO student;
GRANT CREATE ANY DATABASE TO student;

ALTER SERVER ROLE [sysadmin] ADD MEMBER student;          
ALTER ROLE [db_owner] ADD MEMBER student;

-- проверяем пользователей бд
SELECT name FROM sys.database_principals;
