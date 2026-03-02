USE ZAI;
GO

-- Удаление таблиц (если нужно удалить в правильном порядке из-за foreign keys)
IF OBJECT_ID('TEACHER', 'U') IS NOT NULL DROP TABLE TEACHER;
IF OBJECT_ID('SUBJECT', 'U') IS NOT NULL DROP TABLE SUBJECT;
IF OBJECT_ID('AUDITORIUM', 'U') IS NOT NULL DROP TABLE AUDITORIUM;
IF OBJECT_ID('AUDITORIUM_TYPE', 'U') IS NOT NULL DROP TABLE AUDITORIUM_TYPE;
IF OBJECT_ID('PULPIT', 'U') IS NOT NULL DROP TABLE PULPIT;
IF OBJECT_ID('FACULTY', 'U') IS NOT NULL DROP TABLE FACULTY;

----------------------------------------------------------------------------------------------------------
-- Создание таблицы FACULTY
CREATE TABLE FACULTY
(
   FACULTY      NVARCHAR(20) NOT NULL,
   FACULTY_NAME NVARCHAR(100), 
   CONSTRAINT PK_FACULTY PRIMARY KEY(FACULTY) 
);

-- Очистка и вставка данных в FACULTY
DELETE FROM FACULTY;

INSERT INTO FACULTY (FACULTY, FACULTY_NAME) VALUES (N'ИДиП', N'Издательское дело и полиграфия');
INSERT INTO FACULTY (FACULTY, FACULTY_NAME) VALUES (N'ХТиТ', N'Химическая технология и техника');
INSERT INTO FACULTY (FACULTY, FACULTY_NAME) VALUES (N'ЛХФ', N'Лесохозяйственный факультет');
INSERT INTO FACULTY (FACULTY, FACULTY_NAME) VALUES (N'ИЭФ', N'Инженерно-экономический факультет');
INSERT INTO FACULTY (FACULTY, FACULTY_NAME) VALUES (N'ТТЛП', N'Технология и техника лесной промышленности');
INSERT INTO FACULTY (FACULTY, FACULTY_NAME) VALUES (N'ТОВ', N'Технология органических веществ');
INSERT INTO FACULTY (FACULTY, FACULTY_NAME) VALUES (N'ИТ', N'Информационных технологий');

----------------------------------------------------------------------------------------------------------
-- Создание таблицы PULPIT
CREATE TABLE PULPIT 
(
	PULPIT       NVARCHAR(20) NOT NULL,
	PULPIT_NAME  NVARCHAR(150), 
	FACULTY      NVARCHAR(20) NOT NULL,
	CONSTRAINT FK_PULPIT_FACULTY FOREIGN KEY(FACULTY) REFERENCES FACULTY(FACULTY), 
	CONSTRAINT PK_PULPIT PRIMARY KEY(PULPIT) 
);

-- Очистка и вставка данных в PULPIT
DELETE FROM PULPIT;

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ПОиТ', N'Программного обеспечения и технологий', N'ИТ');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ИСиТ', N'Информационных систем и технологий', N'ИДиП');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ПОиСОИ', N'Полиграфического оборудования и систем обработки информации', N'ИДиП');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ЛВ', N'Лесоводства', N'ЛХФ');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ОВ', N'Охотоведения', N'ЛХФ');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ЛУ', N'Лесоустройства', N'ЛХФ');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ЛЗиДВ', N'Лесозащиты и древесиноведения', N'ЛХФ');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ЛПиСПС', N'Ландшафтного проектирования и садово-паркового строительства', N'ЛХФ');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ТЛ', N'Транспорта леса', N'ТТЛП');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ЛМиЛЗ', N'Лесных машин и технологии лесозаготовок', N'ТТЛП');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ОХ', N'Органической химии', N'ТОВ');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ТНХСиППМ', N'Технологии нефтехимического синтеза и переработки полимерных материалов', N'ТОВ');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ТНВиОХТ', N'Технологии неорганических веществ и общей химической технологии', N'ХТиТ');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ХТЭПиМЭЕ', N'Химии, технологии электрохимических производств и материалов электронной техники', N'ХТиТ');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'ЭТиМ', N'Экономической теории и маркетинга', N'ИЭФ');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) 
VALUES (N'МиЭП', N'Менеджмента и экономики природопользования', N'ИЭФ');

----------------------------------------------------------------------------------------------------------
-- Создание таблицы TEACHER
CREATE TABLE TEACHER
( 
	TEACHER       NVARCHAR(20) NOT NULL,
	TEACHER_NAME  NVARCHAR(100), 
	PULPIT        NVARCHAR(20) NOT NULL, 
	CONSTRAINT PK_TEACHER  PRIMARY KEY(TEACHER), 
	CONSTRAINT FK_TEACHER_PULPIT FOREIGN KEY(PULPIT) REFERENCES PULPIT(PULPIT)
);

-- Очистка и вставка данных в TEACHER
DELETE FROM TEACHER;

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'СМЛВ', N'Смелов Владимир Владиславович', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'АКНВЧ', N'Акунович Станислав Иванович', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'КЛСНВ', N'Колесников Леонид Валерьевич', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ГРМН', N'Герман Олег Витольдович', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ЛЩНК', N'Лащенко Анатолий Павлович', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'БРКВЧ', N'Бракович Андрей Игорьевич', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ДДК', N'Дедко Александр Аркадьевич', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'КБЛ', N'Кабайло Александр Серафимович', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'УРБ', N'Урбанович Павел Павлович', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'РМНК', N'Романенко Дмитрий Михайлович', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ПСТВЛВ', N'Пустовалова Наталия Николаевна', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ГРН', N'Гурин Николай Иванович', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ЖЛК', N'Жиляк Надежда Александровна', N'ИСиТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'БРТШВЧ', N'Барташевич Святослав Александрович', N'ПОиСОИ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ЮДНКВ', N'Юденков Виктор Степанович', N'ПОиСОИ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'БРНВСК', N'Барановский Станислав Иванович', N'ЭТиМ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'НВРВ', N'Неверов Александр Васильевич', N'МиЭП');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'РВКЧ', N'Ровкач Андрей Иванович', N'ОВ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ДМДК', N'Демидко Марина Николаевна', N'ЛПиСПС');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'МШКВСК', N'Машковский Владимир Петрович', N'ЛУ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ЛБХ', N'Лабоха Константин Валентинович', N'ЛВ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ЗВГЦВ', N'Звягинцев Вячеслав Борисович', N'ЛЗиДВ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'БЗБРДВ', N'Безбородов Владимир Степанович', N'ОХ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ПРКПЧК', N'Прокопчук Николай Романович', N'ТНХСиППМ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'НСКВЦ', N'Насковец Михаил Трофимович', N'ТЛ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'МХВ', N'Мохов Сергей Петрович', N'ЛМиЛЗ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ЕЩНК', N'Ещенко Людмила Семеновна', N'ТНВиОХТ');

INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) 
VALUES (N'ЖРСК', N'Жарский Иван Михайлович', N'ХТЭПиМЭЕ');

----------------------------------------------------------------------------------------------------------
-- Создание таблицы SUBJECT
CREATE TABLE SUBJECT
(
	SUBJECT      NVARCHAR(20) NOT NULL, 
	SUBJECT_NAME NVARCHAR(100) NOT NULL,
	PULPIT       NVARCHAR(20) NOT NULL,  
	CONSTRAINT PK_SUBJECT PRIMARY KEY(SUBJECT),
	CONSTRAINT FK_SUBJECT_PULPIT FOREIGN KEY(PULPIT) REFERENCES PULPIT(PULPIT)
);

-- Очистка и вставка данных в SUBJECT
DELETE FROM SUBJECT;

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ПСКП', N'Программирование сетевых кроссплатформенных приложений', N'ПОиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'СУБД', N'Системы управления базами данных', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'БД', N'Базы данных', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ИНФ', N'Информационные технологии', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ОАиП', N'Основы алгоритмизации и программирования', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ПЗ', N'Представление знаний в компьютерных системах', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ПСП', N'Программирование сетевых приложений', N'ПОиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'МСОИ', N'Моделирование систем обработки информации', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ПИС', N'Проектирование информационных систем', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'КГ', N'Компьютерная геометрия', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ПМАПЛ', N'Полиграфические машины, автоматы и поточные линии', N'ПОиСОИ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'КМС', N'Компьютерные мультимедийные системы', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ОПП', N'Организация полиграфического производства', N'ПОиСОИ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ДМ', N'Дискретная математика', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'МП', N'Математическое программирование', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ЛЭВМ', N'Логические основы ЭВМ', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ООП', N'Объектно-ориентированное программирование', N'ИСиТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ЭП', N'Экономика природопользования', N'МиЭП');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ЭТ', N'Экономическая теория', N'ЭТиМ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'БЛЗиПсOO', N'Биология лесных зверей и птиц с основами охотоведения', N'ОВ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ОСПиЛПХ', N'Основы садово-паркового и лесопаркового хозяйства', N'ЛПиСПС');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ИГ', N'Инженерная геодезия', N'ЛУ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ЛВ', N'Лесоводство', N'ЛЗиДВ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ОХ', N'Органическая химия', N'ОХ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ТРИ', N'Технология резиновых изделий', N'ТНХСиППМ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ВТЛ', N'Водный транспорт леса', N'ТЛ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ТиОЛ', N'Технология и оборудование лесозаготовок', N'ЛМиЛЗ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ТОПИ', N'Технология обогащения полезных ископаемых', N'ТНВиОХТ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES (N'ПЭХ', N'Прикладная электрохимия', N'ХТЭПиМЭЕ');

----------------------------------------------------------------------------------------------------------
-- Создание таблицы AUDITORIUM_TYPE
CREATE TABLE AUDITORIUM_TYPE 
(
	AUDITORIUM_TYPE   NVARCHAR(20) PRIMARY KEY,  
	AUDITORIUM_TYPENAME  NVARCHAR(100) NOT NULL         
);

-- Очистка и вставка данных в AUDITORIUM_TYPE
DELETE FROM AUDITORIUM_TYPE;

INSERT INTO AUDITORIUM_TYPE (AUDITORIUM_TYPE, AUDITORIUM_TYPENAME) 
VALUES (N'ЛК', N'Лекционная');

INSERT INTO AUDITORIUM_TYPE (AUDITORIUM_TYPE, AUDITORIUM_TYPENAME) 
VALUES (N'ЛБ-К', N'Компьютерный класс');

INSERT INTO AUDITORIUM_TYPE (AUDITORIUM_TYPE, AUDITORIUM_TYPENAME) 
VALUES (N'ЛК-К', N'Лекционная с установленными компьютерами');

INSERT INTO AUDITORIUM_TYPE (AUDITORIUM_TYPE, AUDITORIUM_TYPENAME) 
VALUES (N'ЛБ-X', N'Химическая лаборатория');

INSERT INTO AUDITORIUM_TYPE (AUDITORIUM_TYPE, AUDITORIUM_TYPENAME) 
VALUES (N'ЛБ-СК', N'Специализированный компьютерный класс');

----------------------------------------------------------------------------------------------------------
-- Создание таблицы AUDITORIUM
CREATE TABLE AUDITORIUM 
(
	AUDITORIUM           NVARCHAR(20) PRIMARY KEY,
	AUDITORIUM_NAME      NVARCHAR(100),
	AUDITORIUM_CAPACITY  INT,
	AUDITORIUM_TYPE      NVARCHAR(20) NOT NULL,
	CONSTRAINT FK_AUDITORIUM_TYPE FOREIGN KEY(AUDITORIUM_TYPE) REFERENCES AUDITORIUM_TYPE(AUDITORIUM_TYPE)  
);

-- Очистка и вставка данных в AUDITORIUM
DELETE FROM AUDITORIUM;

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'206-1', N'206-1', N'ЛБ-К', 15);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'301-1', N'301-1', N'ЛБ-К', 15);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'236-1', N'236-1', N'ЛК', 60);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'313-1', N'313-1', N'ЛК', 60);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'324-1', N'324-1', N'ЛК', 50);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'413-1', N'413-1', N'ЛБ-К', 15);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'423-1', N'423-1', N'ЛБ-К', 90);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'408-2', '408-2', N'ЛК', 90);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'103-4', N'103-4', N'ЛК', 90);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'105-4', N'105-4', N'ЛК', 90);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'107-4', N'107-4', N'ЛК', 90);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'110-4', N'110-4', N'ЛК', 30);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'111-4', N'111-4', N'ЛК', 30);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'114-4', N'114-4', N'ЛК-К', 90);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'132-4', N'132-4', N'ЛК', 90);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'229-4', N'229-4', N'ЛК', 90);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'304-4', N'304-4', N'ЛБ-К', 90);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'314-4', N'314-4', N'ЛК', 90);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'320-4', N'320-4', N'ЛК', 90);

INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY) 
VALUES (N'429-4', N'429-4', N'ЛК', 90);

-----------------------------------------------------------------------------------------------------------
-- Проверка данных
SELECT * FROM AUDITORIUM;
SELECT * FROM AUDITORIUM_TYPE;
SELECT * FROM FACULTY;
SELECT * FROM PULPIT;
SELECT * FROM SUBJECT;
SELECT * FROM TEACHER;

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME='AUDITORIUM'

SELECT DB_NAME() AS CurrentDB
