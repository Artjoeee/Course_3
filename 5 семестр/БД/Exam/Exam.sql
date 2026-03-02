create or replace procedure products_and_amount (
    p_company in customers.company%type
) is
    v_found boolean := false;
BEGIN
    for r in (
        select distinct p.description, p.price
        from orders o
        join customers c
        on o.cust = c.cust_num
        join products p
        on o.mfr = p.mfr_id and o.product = p.product_id
        where p.price < (select (sum(p.price) / count(p.MFR_ID)) 
            from orders o
            join customers c
            on o.cust = c.cust_num
            join products p
            on o.mfr = p.mfr_id and o.product = p.product_id
            where c.company = p_company)
        order by p.price desc
    ) loop
        v_found := true;
        
        dbms_output.put_line(r.description || ' ' || r.price);
    end loop;
    
    if not v_found then
        dbms_output.put_line('Данные товары не существуют');
    end if;
    
EXCEPTION
    when OTHERS then
        dbms_output.put_line('Ошибка: ' || SQLERRM);
END;

BEGIN
    products_and_amount('Ace International');
END;

select (sum(p.price) / count(p.MFR_ID)) 
from orders o
join customers c
on o.cust = c.cust_num
join products p
on o.mfr = p.mfr_id and o.product = p.product_id
where c.company = 'Peter Brothers';