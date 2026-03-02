-- 1
create or replace procedure list_orders_from_customer (
    p_company in CUSTOMERS.COMPANY%TYPE
) IS 
    v_found BOOLEAN := false;
    v_sum number := 0;
BEGIN
    for r in (
        select o.order_num, o.amount
        from orders o
        join customers c
        on o.cust = c.cust_num
        where c.company = p_company
        order by o.order_num
    ) loop
        v_found := true;
        v_sum := v_sum + r.amount;
        
        dbms_output.put_line(
            'Заказ: ' || r.order_num || 
            ' Стоимость: ' || r.amount);
    end loop;
    
    if not v_found then
        dbms_output.put_line('Заказы не найдены');
    else
        dbms_output.put_line('Итоговая стоимость: ' || v_sum);
    end if;
    
EXCEPTION 
    when others then
        dbms_output.put_line('Ошибка: ' || SQLERRM);
END;

BEGIN
    list_orders_from_customer('Ace International');
END;

drop procedure list_orders_from_customer;


-- 2
create or replace function count_orders_in_period (
    p_company in customers.company%type,
    start_date in orders.order_date%type,
    end_date in orders.order_date%type
) return number is
    v_count number;
BEGIN
    select count(*) into v_count
    from orders o
    join customers c
    on o.cust = c.cust_num
    where c.company = p_company and
        o.order_date between start_date and end_date;
        
    return v_count;
    
EXCEPTION
    when OTHERS then
        return -1;
END;

declare
    v_count number;
begin
    v_count := count_orders_in_period(
        'Ace International', date '2007-01-01', date '2008-12-31');
        
    dbms_output.put_line('Количество заказов: ' || v_count);
end;

drop function count_orders_in_period;


-- 3
create or replace procedure list_products_with_sum (
    p_company in customers.company%type
) is
    v_found boolean := false;
BEGIN
    for r in (
        select p.DESCRIPTION, 
                sum(o.amount) as total_sum
        from orders o
        join customers c
        on o.cust = c.cust_num
        join products p
        on o.mfr = p.mfr_id 
            and o.product = p.product_id
        where c.company = p_company
        group by p.DESCRIPTION
        order by total_sum
    ) loop
        v_found := true;
        
        dbms_output.put_line(
        'Продукт: ' || r.DESCRIPTION 
        || ' Сумма: ' || r.total_sum);
    end loop;
    
    if not v_found then
        dbms_output.put_line('Продукты не найдены');
    end if;
    
EXCEPTION
    when OTHERS then
        dbms_output.put_line('Ошибка: ' || SQLERRM);
    
END;

BEGIN
    list_products_with_sum('Ace International');
END;

drop procedure list_products_with_sum;


-- 4
create SEQUENCE code start with 1000;

create or replace function add_customer (
    p_company in customers.COMPANY%type,
    p_rep in customers.CUST_REP%type,
    p_limit in customers.CREDIT_LIMIT%type
) return INTEGER is
    v_id INTEGER;
BEGIN
    v_id := code.nextval;
    
    insert into customers values (v_id, p_company, p_rep, p_limit);
    
    return v_id;
    
EXCEPTION
    when OTHERS then
        return -1;
END;

DECLARE
    v_id INTEGER;
BEGIN
    v_id := add_customer ('NewCustom Corp.', 107, 50000.00);
    
    if v_id = -1 then
        dbms_output.put_line('Не удалось добавить покупателя');
    else
        dbms_output.put_line('Код нового покупателя: ' || v_id);
    end if;
END;

drop function add_customer;
drop SEQUENCE code;


-- 5
create or replace procedure customers_list (
    start_date in DATE,
    end_date in DATE
) is
    v_found boolean := false;
BEGIN
    for r in (
        select c.company, sum(o.amount) as total_amount
        from orders o
        join customers c
        on o.cust = c.cust_num
        where o.order_date between start_date and end_date
        group by c.company
        order by total_amount DESC
    ) loop
        v_found := true;
        
        dbms_output.put_line(r.company || ' ' || r.total_amount);
    end loop;
    
    if not v_found then
        dbms_output.put_line('Покупатели не найдены');
    end if;
    
EXCEPTION
    when OTHERS then
        dbms_output.put_line('Ошибка: ' || SQLERRM);
END;

BEGIN
    customers_list(date '2007-01-01', date '2008-12-31');
END;

drop procedure customers_list;


-- 6
create or replace function count_orders_in_period (
    start_date in date,
    end_date in date
) return number is
    v_count number;
BEGIN
    select sum(qty)
    into v_count
    from orders
    where end_date between start_date and end_date;
    
    return NVL(v_count, 0);
    
EXCEPTION
    when OTHERS then
        return -1;
END;

DECLARE
    v_count number;
BEGIN
    v_count := count_orders_in_period(DATE '2007-01-01', DATE '2008-12-31');
    
    dbms_output.put_line('Количество заказанных товаров: ' || v_count);
END;

drop function count_orders_in_period;


-- 7
create or replace procedure customers_in_period (
    start_date in date,
    end_date in date
) is
    v_found boolean := false;
BEGIN
    for r in (
        select p.company 
        from orders o
        join customers p
        on o.cust = p.cust_num
        where o.order_date between start_date and end_date
    ) loop
        v_found := true;
        dbms_output.put_line(r.company);
    end loop;
    
    if not v_found then
        dbms_output.put_line('Покупатели не найдены');
    end if;
    
EXCEPTION
    when OTHERS then
        dbms_output.put_line('Ошибка' || SQLERRM);
END;

BEGIN
    customers_in_period(date '2007-01-01', date '2008-12-31');
END;

drop procedure customers_in_period;


-- 8
create or replace function count_of_product (
    p_description in PRODUCTS.DESCRIPTION%type
) return number is
    v_count number;
BEGIN
    select count(c.company) into v_count
    from orders o
    join customers c
    on o.cust = c.cust_num
    join products p
    on o.mfr = p.mfr_id and o.product = p.product_id
    where p.description = p_description;
    
    return NVL(v_count, 0);
END;

DECLARE
    v_count number;
BEGIN
    v_count := count_of_product('Ratchet Link');
    
    dbms_output.put_line('Количество покупателей: ' || v_count);
END;

drop function count_of_product;


-- 9
create or replace procedure update_amount (
    p_description in products.description%type
) is
    v_rows number;
BEGIN
    update products
    set price = price * 1.10
    where description = p_description;
    
    v_rows := sql%rowcount;
    
    if v_rows = 0 then
        dbms_output.put_line('Товар не найден');
    else
        dbms_output.put_line('Цена увеличена для ' || v_rows || ' продукта');
    end if;
    
EXCEPTION
    when OTHERS then
        dbms_output.put_line('Ошибка: ' || SQLERRM);
END;

BEGIN
    update_amount('Ratchet Link');
END;

select price from products where description = 'Ratchet Link';

drop procedure update_amount;


-- 10
create or replace function orders_in_year (
    p_company in customers.company%type,
    p_year in number
) return number is
    v_count number;
BEGIN
    select count(*) into v_count
    from orders o
    join customers c
    on o.cust = c.cust_num
    where c.company = p_company and
        extract(year from o.order_date) = p_year;
    
    return NVL(v_count, 0);
END;

DECLARE
    v_count number;
BEGIN
    v_count := orders_in_year('Ace International', 2008);
    
    dbms_output.put_line('Количество заказов: ' || v_count);
END;

drop function orders_in_year;