-- 1
CREATE OR REPLACE PROCEDURE orders_by_customer (
    p_company IN CUSTOMERS.COMPANY%TYPE
) IS
    v_found BOOLEAN := FALSE;
    v_sum INTEGER := 0;
BEGIN
    FOR r IN (
        SELECT o.order_num, o.amount
        FROM orders o
        JOIN customers c ON o.cust = c.cust_num
        WHERE c.company = p_company
        ORDER BY o.order_num
    ) LOOP
        v_found := TRUE;
        v_sum := v_sum + r.amount;
        DBMS_OUTPUT.PUT_LINE(
            'Order #' || r.order_num ||
            ', Amount: ' || r.amount
        );
    END LOOP;

    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No orders found for customer: ' || p_company);
    ELSE
        DBMS_OUTPUT.PUT_LINE('All amount: ' || v_sum);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    orders_by_customer('Ace International');
END;

DROP PROCEDURE orders_by_customer;


-- 2
CREATE OR REPLACE FUNCTION count_orders_by_customer (
    p_company   IN CUSTOMERS.COMPANY%TYPE,
    p_date_from IN DATE,
    p_date_to   IN DATE
) RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM orders o
    JOIN customers c ON o.cust = c.cust_num
    WHERE c.company = p_company
      AND o.order_date BETWEEN p_date_from AND p_date_to;

    RETURN v_count;
END;

DECLARE
    v_count NUMBER;
BEGIN
    v_count := count_orders_by_customer('Ace International', DATE '2007-12-17', DATE '2008-03-02');
    DBMS_OUTPUT.PUT_LINE('Count: ' || v_count);
END;

DROP FUNCTION count_orders_by_customer;


-- 3
CREATE OR REPLACE PROCEDURE products_by_customer (
    p_company IN CUSTOMERS.COMPANY%TYPE
) IS
    v_found BOOLEAN := FALSE;
BEGIN
    FOR r IN (
        SELECT p.description,
               SUM(o.amount) AS total_sales
        FROM orders o
        JOIN customers c ON o.cust = c.cust_num
        JOIN products p ON p.mfr_id = o.mfr
                       AND p.product_id = o.product
        WHERE c.company = p_company
        GROUP BY p.description
        ORDER BY total_sales
    ) LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE(
            r.description || ' - Total sales: ' || r.total_sales
        );
    END LOOP;

    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No products found for customer: ' || p_company);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    products_by_customer('Ace International');
END;

DROP PROCEDURE products_by_customer;


-- 4
CREATE SEQUENCE customers_seq START WITH 1000;

CREATE OR REPLACE FUNCTION add_customer (
    p_company       IN CUSTOMERS.COMPANY%TYPE,
    p_cust_rep      IN CUSTOMERS.CUST_REP%TYPE,
    p_credit_limit  IN CUSTOMERS.CREDIT_LIMIT%TYPE
) RETURN NUMBER IS
    v_cust_num NUMBER;
BEGIN
    v_cust_num := customers_seq.NEXTVAL;

    INSERT INTO customers (
        cust_num, company, cust_rep, credit_limit
    )
    VALUES (
        v_cust_num, p_company, p_cust_rep, p_credit_limit
    );

    RETURN v_cust_num;

EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END;

DECLARE
    v_id NUMBER;
BEGIN
    v_id := add_customer(
        'New Company',
        105,
        50000);

    IF v_id = -1 THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting customer');
    ELSE
        DBMS_OUTPUT.PUT_LINE('New customer ID: ' || v_id);
    END IF;
END;

DROP FUNCTION add_customer;
DROP SEQUENCE customers_seq;


-- 5
CREATE OR REPLACE PROCEDURE customers_by_sales (
    p_date_from IN DATE,
    p_date_to   IN DATE
) IS
BEGIN
    FOR r IN (
        SELECT c.company,
               SUM(o.amount) AS total_amount
        FROM customers c
        JOIN orders o ON c.cust_num = o.cust
        WHERE o.order_date BETWEEN p_date_from AND p_date_to
        GROUP BY c.company
        ORDER BY total_amount DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            r.company || ' - Total: ' || r.total_amount
        );
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
  customers_by_sales(
    DATE '2007-01-01',
    DATE '2008-12-31'
  );
END;

DROP PROCEDURE customers_by_sales;


-- 6
CREATE OR REPLACE FUNCTION count_products_ordered (
    p_date_from IN DATE,
    p_date_to   IN DATE
) RETURN NUMBER IS
    v_qty NUMBER;
BEGIN
    SELECT SUM(qty)
    INTO v_qty
    FROM orders
    WHERE order_date BETWEEN p_date_from AND p_date_to;

    RETURN NVL(v_qty, 0);
END;

DECLARE
    v_count NUMBER;
BEGIN
    v_count := count_products_ordered(DATE '2007-12-17', DATE '2008-03-02');
    DBMS_OUTPUT.PUT_LINE('Count: ' || v_count);
END;

DROP FUNCTION count_products_ordered;


-- 7
CREATE OR REPLACE PROCEDURE customers_with_orders (
    p_date_from IN DATE,
    p_date_to   IN DATE
) IS
    v_found BOOLEAN := FALSE;
BEGIN
    FOR r IN (
        SELECT DISTINCT c.company
        FROM customers c
        JOIN orders o ON c.cust_num = o.cust
        WHERE o.order_date BETWEEN p_date_from AND p_date_to
    ) LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE(r.company);
    END LOOP;

    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No customers found in this period');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
  customers_with_orders(
    DATE '2007-01-01',
    DATE '2008-12-31'
  );
END;

DROP PROCEDURE customers_with_orders;


-- 8
CREATE OR REPLACE FUNCTION count_customers_by_product (
    p_description IN PRODUCTS.DESCRIPTION%TYPE
) RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(DISTINCT o.cust)
    INTO v_count
    FROM orders o
    JOIN products p ON p.mfr_id = o.mfr
                   AND p.product_id = o.product
    WHERE p.description = p_description;

    RETURN v_count;
END;

DECLARE
    v_count NUMBER;
BEGIN
    v_count := count_customers_by_product('Ratchet Link');
    DBMS_OUTPUT.PUT_LINE('Count: ' || v_count);
END;

DROP FUNCTION count_customers_by_product;


-- 9
CREATE OR REPLACE PROCEDURE increase_product_price (
    p_description IN PRODUCTS.DESCRIPTION%TYPE
) IS
    v_rows NUMBER;
BEGIN
    UPDATE products
    SET price = price * 1.10
    WHERE description = p_description;

    v_rows := SQL%ROWCOUNT;

    IF v_rows = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Product not found: ' || p_description);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Price increased for ' || v_rows || ' product(s)');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    increase_product_price('Ratchet Link');
END;

DROP PROCEDURE increase_product_price;


-- 10
CREATE OR REPLACE FUNCTION count_orders_by_year (
    p_company IN CUSTOMERS.COMPANY%TYPE,
    p_year    IN NUMBER
) RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM orders o
    JOIN customers c ON o.cust = c.cust_num
    WHERE c.company = p_company
      AND EXTRACT(YEAR FROM o.order_date) = p_year;

    RETURN v_count;
END;

DECLARE
    v_count NUMBER;
BEGIN
    v_count := count_orders_by_year('Ace International', 2008);
    DBMS_OUTPUT.PUT_LINE('Count: ' || v_count);
END;

DROP FUNCTION count_orders_by_year;
