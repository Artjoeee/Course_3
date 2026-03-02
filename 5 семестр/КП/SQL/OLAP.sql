CREATE MATERIALIZED VIEW mv_membership_sales
BUILD IMMEDIATE
REFRESH COMPLETE
START WITH SYSDATE
NEXT (SYSDATE + 1)
AS
SELECT
    EXTRACT(YEAR FROM mo.order_date) AS sales_year,
    EXTRACT(MONTH FROM mo.order_date) AS sales_month,
    m.name AS membership_name,
    COUNT(mo.order_id) AS total_sales,
    SUM(m.price) AS total_revenue
FROM membership_orders mo
JOIN memberships m ON mo.membership_id = m.membership_id
WHERE mo.status = 'ACTIVE'
GROUP BY EXTRACT(YEAR FROM mo.order_date),
         EXTRACT(MONTH FROM mo.order_date),
         m.name;
         
         
CREATE MATERIALIZED VIEW mv_popular_memberships
BUILD IMMEDIATE
REFRESH COMPLETE
START WITH SYSDATE
NEXT (SYSDATE + 1)
AS
SELECT
    EXTRACT(YEAR FROM mo.order_date) AS sales_year,
    EXTRACT(MONTH FROM mo.order_date) AS sales_month,
    m.membership_id,
    m.name AS membership_name,
    COUNT(mo.order_id) AS total_sales,
    DENSE_RANK() OVER (
    PARTITION BY EXTRACT(YEAR FROM mo.order_date),
                 EXTRACT(MONTH FROM mo.order_date)
    ORDER BY COUNT(mo.order_id) DESC
) AS popularity_rank
FROM membership_orders mo
JOIN memberships m ON mo.membership_id = m.membership_id
WHERE mo.status = 'ACTIVE'
GROUP BY
    EXTRACT(YEAR FROM mo.order_date),
    EXTRACT(MONTH FROM mo.order_date),
    m.membership_id,
    m.name;


SELECT
    EXTRACT(YEAR FROM mo.order_date) AS sales_year,
    EXTRACT(MONTH FROM mo.order_date) AS sales_month,
    m.name AS membership_name,
    COUNT(mo.order_id) AS total_sales,
    SUM(m.price) AS total_revenue
FROM membership_orders mo
JOIN memberships m ON mo.membership_id = m.membership_id
WHERE mo.status = 'ACTIVE'
GROUP BY CUBE (
    EXTRACT(YEAR FROM mo.order_date),
    EXTRACT(MONTH FROM mo.order_date),
    m.name
)
ORDER BY sales_year, sales_month, membership_name;


DROP MATERIALIZED VIEW mv_membership_sales;
DROP MATERIALIZED VIEW mv_popular_memberships;


CREATE OR REPLACE PACKAGE pkg_analytics IS

    -- Пересчёт всех материализованных представлений
    PROCEDURE refresh_all_mv;

    -- Отчёт по продажам абонементов с CUBE
    PROCEDURE report_membership_sales;
    
    -- Топ популярных абонементов
    PROCEDURE report_popular_memberships(p_top_n NUMBER DEFAULT 3);

END pkg_analytics;



CREATE OR REPLACE PACKAGE BODY pkg_analytics IS

    -- ===============================
    -- 1. Пересчёт всех MV
    -- ===============================
    PROCEDURE refresh_all_mv IS
    BEGIN
        pkg_security.assert_admin;
        EXECUTE IMMEDIATE 'BEGIN DBMS_MVIEW.REFRESH(''MV_MEMBERSHIP_SALES'', ''C''); END;';
        EXECUTE IMMEDIATE 'BEGIN DBMS_MVIEW.REFRESH(''MV_POPULAR_MEMBERSHIPS'', ''C''); END;';
        EXECUTE IMMEDIATE 'BEGIN DBMS_MVIEW.REFRESH(''MV_CLIENT_ATTENDANCE'', ''C''); END;';
        EXECUTE IMMEDIATE 'BEGIN DBMS_MVIEW.REFRESH(''MV_COACH_SCHEDULE_LOAD'', ''C''); END;';
        DBMS_OUTPUT.PUT_LINE('Все материализованные представления успешно обновлены.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка обновления MV: ' || SQLERRM);
    END refresh_all_mv;

    -- ===============================
    -- 2. Отчёт продаж абонементов (CUBE)
    -- ===============================
    PROCEDURE report_membership_sales IS
    BEGIN
        pkg_security.assert_admin;
    
        FOR rec IN (
            SELECT
                EXTRACT(YEAR FROM mo.order_date) AS sales_year,
                EXTRACT(MONTH FROM mo.order_date) AS sales_month,
                m.name AS membership_name,
                COUNT(mo.order_id) AS total_sales,
                SUM(m.price) AS total_revenue
            FROM membership_orders mo
            JOIN memberships m ON mo.membership_id = m.membership_id
            WHERE mo.status = 'ACTIVE'
            GROUP BY CUBE(
                EXTRACT(YEAR FROM mo.order_date),
                EXTRACT(MONTH FROM mo.order_date),
                m.name
            )
            ORDER BY sales_year, sales_month, membership_name
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Year: ' || NVL(TO_CHAR(rec.sales_year), 'ALL') ||
                ', Month: ' || NVL(TO_CHAR(rec.sales_month), 'ALL') ||
                ', Membership: ' || NVL(rec.membership_name, 'ALL') ||
                ', Sales: ' || rec.total_sales ||
                ', Revenue: ' || rec.total_revenue
            );
        END LOOP;
    
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(
                'Ошибка отчёта продаж абонементов: ' || SQLERRM
            );
    END report_membership_sales;

    
    
    -- ===============================
    -- 3. Отчёт популярных абонементов
    -- ===============================
    PROCEDURE report_popular_memberships(p_top_n NUMBER DEFAULT 3) IS
    BEGIN
        pkg_security.assert_admin;
    
        FOR rec IN (
            SELECT
                sales_year,
                sales_month,
                membership_name,
                total_sales,
                popularity_rank
            FROM mv_popular_memberships
            WHERE popularity_rank <= p_top_n
            ORDER BY sales_year, sales_month, popularity_rank
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Year: ' || rec.sales_year ||
                ', Month: ' || rec.sales_month ||
                ', Membership: ' || rec.membership_name ||
                ', Sales: ' || rec.total_sales ||
                ', Rank: ' || rec.popularity_rank
            );
        END LOOP;
    
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка отчёта популярных абонементов: ' || SQLERRM);
    END report_popular_memberships;


END pkg_analytics;


DROP PACKAGE pkg_analytics;