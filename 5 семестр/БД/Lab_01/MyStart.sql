CREATE TABLE ZAI_t( x number(3), s varchar2(50));

INSERT INTO zai_t (x, s) VALUES (10, 'Nike');
INSERT INTO zai_t (x, s) VALUES (15, 'Puma');
INSERT INTO zai_t (x, s) VALUES (20, 'Adidas');
INSERT INTO zai_t (x, s) VALUES (5, 'Crocs');

COMMIT;

UPDATE zai_t
SET s = 'Gucci'
WHERE x = 10;

UPDATE zai_t
SET s = 'Acics'
WHERE x = 20;

COMMIT;

SELECT SUM(x)
FROM zai_t
WHERE x < 20;

DELETE FROM zai_t
WHERE s = 'Puma';

COMMIT;

ALTER TABLE ZAI_t
ADD CONSTRAINT pk_brend
PRIMARY KEY (s);

CREATE TABLE ZAI_t1( i number(3), x number(3), s varchar2(50),
CONSTRAINT fk_brend FOREIGN KEY (s) REFERENCES ZAI_t(s));

INSERT INTO zai_t1 (i, x, s) VALUES (1, 300, 'Gucci');
INSERT INTO zai_t1 (i, x, s) VALUES (3, 250, 'Acics');
INSERT INTO zai_t1 (i, x, s) VALUES (4, 250, 'Crocs');

SELECT zai_t1.x, zai_t.s
FROM zai_t INNER JOIN zai_t1
on zai_t.s = zai_t1.s
WHERE zai_t.x > 10;

SELECT zai_t1.x, zai_t.s
FROM zai_t LEFT JOIN zai_t1
on zai_t.s = zai_t1.s
WHERE zai_t.x < 10;

SELECT zai_t1.x, zai_t.s
FROM zai_t RIGHT JOIN zai_t1
on zai_t.s = zai_t1.s
WHERE zai_t.x = 10;

DROP TABLE ZAI_t1;
DROP TABLE ZAI_t;

