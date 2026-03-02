ALTER SESSION SET CONTAINER = XEPDB1;

-- 1 
ALTER TABLE TEACHER
ADD (BIRTHDAY DATE, SALARY NUMBER);

UPDATE TEACHER
SET BIRTHDAY = TRUNC(SYSDATE) - FLOOR(DBMS_RANDOM.VALUE(365*65, 365*20)),
    SALARY = FLOOR(DBMS_RANDOM.VALUE(30000, 80000));

ALTER TABLE TEACHER
DROP COLUMN BIRTHDAY;

ALTER TABLE TEACHER
DROP COLUMN SALARY;

SELECT * FROM TEACHER;



-- 2
CREATE OR REPLACE FUNCTION GET_FIO(TEACHER_NAME VARCHAR2)
    RETURN VARCHAR2
IS
    FIO VARCHAR2(200);
BEGIN
    FIO := SUBSTR(TEACHER_NAME, 1, INSTR(TEACHER_NAME, ' ') - 1) || ' ' ||
                 SUBSTR(TEACHER_NAME, INSTR(TEACHER_NAME, ' ') + 1, 1) || '.' ||
                 SUBSTR(TEACHER_NAME, INSTR(TEACHER_NAME, ' ', 1, 2) + 1, 1) || '.';
    RETURN FIO;
END;

SELECT GET_FIO(TEACHER_NAME) FROM TEACHER;

DROP FUNCTION GET_FIO;



-- 3
SELECT TEACHER_NAME, BIRTHDAY FROM TEACHER
WHERE TO_CHAR(BIRTHDAY, 'D') = '1';



-- 4
CREATE VIEW TEACHERS_NEXT_MONTH as
SELECT GET_FIO(TEACHER_NAME) as TEACHER_NAME,
       to_char(BIRTHDAY, 'DD.MM.YYYY')   as BIRTHDAY
FROM teacher
WHERE to_char(BIRTHDAY, 'MM') = to_char(sysdate, 'MM')
OR (to_char(sysdate, 'MM') = '12' AND to_char(BIRTHDAY, 'MM') = '01');

SELECT * FROM TEACHERS_NEXT_MONTH;

DROP VIEW TEACHERS_NEXT_MONTH;



-- 5
DROP TABLE MONTHS;

CREATE TABLE MONTHS
(
  month_name   varchar(20),
  month_number varchar(2)
);

insert into MONTHS (month_name, month_number)
values ('Январь', '01');
insert into MONTHS (month_name, month_number)
values ('Февраль', '02');
insert into MONTHS (month_name, month_number)
values ('Март', '03');
insert into MONTHS (month_name, month_number)
values ('Апрель', '04');
insert into MONTHS (month_name, month_number)
values ('Май', '05');
insert into MONTHS (month_name, month_number)
values ('Июнь', '06');
insert into MONTHS (month_name, month_number)
values ('Июль', '07');
insert into MONTHS (month_name, month_number)
values ('Август', '08');
insert into MONTHS (month_name, month_number)
values ('Сентябрь', '09');
insert into MONTHS (month_name, month_number)
values ('Октябрь', '10');
insert into MONTHS (month_name, month_number)
values ('Ноябрь', '11');
insert into MONTHS (month_name, month_number)
values ('Декабрь', '12');

CREATE VIEW TEACHER_COUNT_BY_MONTH as
SELECT month_name,
       (SELECT count(*) FROM TEACHER WHERE to_char(birthday, 'MM') = month_number) as count
FROM MONTHS;

SELECT * FROM TEACHER_COUNT_BY_MONTH;

DROP VIEW TEACHER_COUNT_BY_MONTH;


-- 6
DECLARE
  CURSOR c1 is
    SELECT GET_FIO(TEACHER_NAME) as teacher_name,
           to_char(BIRTHDAY, 'DD.MM.YYYY')   as birthday
    FROM TEACHER
    WHERE MOD((to_number(to_char(sysdate, 'YYYY')) - to_number(to_char(BIRTHDAY, 'YYYY')) + 1), 5) = 0;
BEGIN
  for i in c1
    LOOP
      dbms_output.put_line(i.teacher_name || ' ' || i.birthday);
    END LOOP;
END;



-- 7
SELECT * FROM TEACHER;
SELECT * FROM FACULTY;

DECLARE
  CURSOR c_average_salary IS
    SELECT P.FACULTY, AVG(T.SALARY) AS AVERAGE_SALARY
    FROM TEACHER T
    INNER JOIN PULPIT P ON T.PULPIT = P.PULPIT
    GROUP BY P.FACULTY;

  v_faculty CHAR(20);
  v_average_salary NUMBER;
  v_count_faculty NUMBER;
  v_total_average_salary NUMBER := 0;
  v_average_salary_all_faculty NUMBER;
BEGIN
  OPEN c_average_salary;
  
  DBMS_OUTPUT.PUT_LINE('Average Salary by Faculty:');
  DBMS_OUTPUT.PUT_LINE('-------------------------');
  
  LOOP
    FETCH c_average_salary INTO v_faculty, v_average_salary;
    EXIT WHEN c_average_salary%NOTFOUND;
    
    SELECT COUNT(*) INTO v_count_faculty FROM FACULTY;
    v_total_average_salary := v_total_average_salary + v_average_salary;
    v_average_salary_all_faculty := v_total_average_salary / v_count_faculty;
    
    DBMS_OUTPUT.PUT_LINE('Faculty: ' || v_faculty || ', Average Salary: ' || FLOOR(v_average_salary));
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE('-------------------------');
  DBMS_OUTPUT.PUT_LINE('Total: ' || FLOOR(v_total_average_salary));
  DBMS_OUTPUT.PUT_LINE('Total Average Salary: ' || FLOOR(v_average_salary_all_faculty));
  
  CLOSE c_average_salary;
END;



-- 8
SELECT * FROM TEACHER;

CREATE OR REPLACE PROCEDURE demonstrate_record AS
    TYPE teacher_record IS RECORD (
    teacher       VARCHAR2(20),
    teacher_name  VARCHAR2(200),
    pulpit        CHAR(20)
  );
  t teacher_record;
BEGIN
  t.teacher := 'УРБ';
  t.teacher_name := 'Урбанович Павел Павлович';
  t.pulpit := 'ИСиТ';

  DBMS_OUTPUT.PUT_LINE('Teacher: ' || t.teacher);
  DBMS_OUTPUT.PUT_LINE('Teacher Name: ' || t.teacher_name);
  DBMS_OUTPUT.PUT_LINE('Pulpit: ' || t.pulpit);
END;

BEGIN
  demonstrate_record;
END;

DROP PROCEDURE demonstrate_record;