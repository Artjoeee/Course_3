-- 1
BEGIN
   NULL;
END;


-- 2
SET SERVEROUTPUT ON SIZE 1000000

BEGIN
  DBMS_OUTPUT.PUT_LINE('Hello World!');
END;
/


-- 3
BEGIN
  DECLARE
    num NUMBER := 10;
    den NUMBER := 0;
    res NUMBER;
  BEGIN
    res := num / den;
    DBMS_OUTPUT.PUT_LINE('Результат: ' || res);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
      DBMS_OUTPUT.PUT_LINE('Код ошибки: ' || SQLCODE);
  END;
END;


-- 4
BEGIN
  DBMS_OUTPUT.PUT_LINE('Внешний блок: начало');
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Вложенный блок: до ошибки');
    RAISE_APPLICATION_ERROR(-20001, 'Вложенная ошибка');
    DBMS_OUTPUT.PUT_LINE('Эта строка не выполнится');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Вложенный блок поймал исключение: ' || SQLERRM);
  END;
  DBMS_OUTPUT.PUT_LINE('Внешний блок: после вложенного блока');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Внешний блок поймал: ' || SQLERRM);
END;


-- 5
SELECT * FROM V$PARAMETER
WHERE NAME LIKE 'plsql_warnings';


-- 6
SELECT keyword, reserved
FROM v$reserved_words
WHERE length = 1 and keyword != 'A'
ORDER BY keyword;


-- 7
SELECT keyword, reserved
FROM v$reserved_words
WHERE length > 1 and keyword != 'A'
ORDER BY keyword;


-- 8
SELECT * FROM V$PARAMETER
WHERE NAME LIKE '%plsql%';

SHOW PARAMETER PLSQL;


-- 9 - 17
BEGIN
  DECLARE
    n1 NUMBER := 10;
    n2 NUMBER := 3;
    n3 NUMBER;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('n1 = ' || n1 || ', n2 = ' || n2);
    DBMS_OUTPUT.PUT_LINE('n1 + n2 = ' || (n1 + n2));
    DBMS_OUTPUT.PUT_LINE('n1 - n2 = ' || (n1 - n2));
    DBMS_OUTPUT.PUT_LINE('n1 * n2 = ' || (n1 * n2));
    DBMS_OUTPUT.PUT_LINE('n1 / n2 = ' || (n1 / n2));
    DBMS_OUTPUT.PUT_LINE('MOD(n1, n2) = ' || MOD(n1, n2));
  END;

  DECLARE
    f1 NUMBER(10,2) := 123.45;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('f1 = ' || TO_CHAR(f1));
  END;

  DECLARE
    r1 NUMBER(6,-1) := 12345;
    r2 NUMBER(6,-2) := 12345;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('r1 (scale -1) = ' || TO_CHAR(r1));
    DBMS_OUTPUT.PUT_LINE('r2 (scale -2) = ' || TO_CHAR(r2));
  END;

  DECLARE
    bf BINARY_FLOAT := 1.2345;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('bf = ' || TO_CHAR(bf));
  END;

  DECLARE
    bd BINARY_DOUBLE := 1.23456789012345;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('bd = ' || TO_CHAR(bd));
  END;

  DECLARE
    e1 NUMBER := 1.23E3;
    e2 NUMBER := 4.56E-2;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('e1 = ' || TO_CHAR(e1));
    DBMS_OUTPUT.PUT_LINE('e2 = ' || TO_CHAR(e2));
  END;

  DECLARE
    b_true BOOLEAN := TRUE;
    b_false BOOLEAN := FALSE;
    b_null BOOLEAN := NULL;
  BEGIN
    IF b_true THEN
      DBMS_OUTPUT.PUT_LINE('b_true == TRUE');
    END IF;
    
    IF b_null IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('b_null == NULL');
    END IF;
  END;
END;


-- 18 
BEGIN
  DECLARE
    c1 CONSTANT VARCHAR2(20) := 'Hello';
    c2 CONSTANT CHAR(6) := 'Hi';
    c3 CONSTANT NUMBER := 100;
    c4 CONSTANT NUMBER := 3;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('c1 || '' World'' = ' || c1 || ' World');
    DBMS_OUTPUT.PUT_LINE('LPAD(c2,6,''*'') = ' || LPAD(c2,6,'*'));
    DBMS_OUTPUT.PUT_LINE('c3 + c4 = ' || (c3 + c4));
  END;
END;


-- 19
CREATE TABLE DEMO (
  id NUMBER,
  name VARCHAR2(50)
);

BEGIN
  DECLARE
    id DEMO.id%TYPE;
    name DEMO.name%TYPE;
  BEGIN
    id := 1;
    name := 'Artem';
    DBMS_OUTPUT.PUT_LINE('id='||id||', name='||name);
  END;
END;

DROP TABLE DEMO;


-- 20
BEGIN
  DECLARE
    r DEMO%ROWTYPE;
  BEGIN
    r.id := 2;
    r.name := 'Artur';
    DBMS_OUTPUT.PUT_LINE('r.id=' || r.id || ', r.name=' || r.name);
  END;
END;


-- 21 - 22
BEGIN
  DECLARE
    x NUMBER := 5;
  BEGIN
    IF x > 0 THEN
      DBMS_OUTPUT.PUT_LINE('x > 0');
    END IF;

    IF x < 0 THEN
      DBMS_OUTPUT.PUT_LINE('x < 0');
    ELSE
      DBMS_OUTPUT.PUT_LINE('x >= 0');
    END IF;

    IF x = 0 THEN
      DBMS_OUTPUT.PUT_LINE('x = 0');
    ELSIF x = 1 THEN
      DBMS_OUTPUT.PUT_LINE('x = 1');
    ELSE
      DBMS_OUTPUT.PUT_LINE('x равен другому числу');
    END IF;

    IF x > 0 THEN
      IF x > 10 THEN
        DBMS_OUTPUT.PUT_LINE('x > 10');
      ELSE
        DBMS_OUTPUT.PUT_LINE('0 < x <= 10');
      END IF;
    END IF;
  END;
END;


-- 23
BEGIN
  DECLARE
    v NUMBER := 2;
    v_text VARCHAR2(20);
  BEGIN
    CASE v
      WHEN 1 THEN v_text := 'One';
      WHEN 2 THEN v_text := 'Two';
      ELSE v_text := 'Other';
    END CASE;
    DBMS_OUTPUT.PUT_LINE('Первый CASE: ' || v_text);

    CASE
      WHEN v < 0 THEN v_text := 'Neg';
      WHEN v = 0 THEN v_text := 'Zero';
      WHEN v > 0 THEN v_text := 'Pos';
      ELSE v_text := 'Unknown';
    END CASE;
    DBMS_OUTPUT.PUT_LINE('Второй CASE: ' || v_text);
  END;
END;


-- 24
BEGIN
  DECLARE
    i NUMBER := 0;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Loop:');
    LOOP
      i := i + 1;
      DBMS_OUTPUT.PUT_LINE('i: ' || i);
      EXIT WHEN i >= 3;
    END LOOP;
  END;
END;


-- 25
BEGIN
  DECLARE
    i NUMBER := 1;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('WHILE:');
    WHILE i <= 3 LOOP
      DBMS_OUTPUT.PUT_LINE('i = ' || i);
      i := i + 1;
    END LOOP;
  END;
END;


-- 26
BEGIN
  DECLARE
  BEGIN
    DBMS_OUTPUT.PUT_LINE('FOR:');
    FOR i IN 1..3 LOOP
      DBMS_OUTPUT.PUT_LINE('i = ' || i);
    END LOOP;
  END;
END;
