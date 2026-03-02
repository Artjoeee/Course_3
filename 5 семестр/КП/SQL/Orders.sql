CREATE OR REPLACE PACKAGE pkg_orders_client IS
    PROCEDURE purchase_membership_admin(p_client_id IN NUMBER, p_membership_id IN NUMBER);
    PROCEDURE get_client_orders(p_client_id IN NUMBER);
    PROCEDURE cancel_own_order_admin(p_order_id IN NUMBER, p_client_id IN NUMBER);
    PROCEDURE purchase_membership_client(p_membership_id IN NUMBER);
    PROCEDURE cancel_own_order_client(p_order_id IN NUMBER);
    
END pkg_orders_client;


CREATE OR REPLACE PACKAGE BODY pkg_orders_client IS

    PROCEDURE purchase_membership_admin(
        p_client_id      IN NUMBER,
        p_membership_id  IN NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        pkg_security.assert_admin;
    
        -- Проверка: есть ли уже активный такой же абонемент
        SELECT COUNT(*)
        INTO v_count
        FROM membership_orders
        WHERE client_id = p_client_id
          AND membership_id = p_membership_id
          AND status = 'ACTIVE';
    
        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: у клиента уже есть активный абонемент данного типа.');
        END IF;
    
        -- Оформление заказа
        INSERT INTO membership_orders (
            client_id,
            membership_id,
            order_date,
            status
        )
        VALUES (
            p_client_id,
            p_membership_id,
            SYSDATE,
            'ACTIVE'
        );
    
        COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка оформления абонемента: ' || SQLERRM);
    END purchase_membership_admin;


    PROCEDURE get_client_orders(p_client_id IN NUMBER) IS
    BEGIN
        pkg_security.assert_admin_or_client;
        FOR rec IN (SELECT order_id, membership_id, status FROM membership_orders WHERE client_id = p_client_id) LOOP
            DBMS_OUTPUT.PUT_LINE('Order: ' || rec.order_id || ', Membership: ' || rec.membership_id || ', Status: ' || rec.status);
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка получения заказов клиента: ' || SQLERRM);
    END get_client_orders;

    PROCEDURE cancel_own_order_admin(p_order_id IN NUMBER, p_client_id IN NUMBER) IS
    BEGIN
        pkg_security.assert_admin;
        UPDATE membership_orders SET status = 'CANCELLED' WHERE order_id = p_order_id AND client_id = p_client_id;
        IF SQL%ROWCOUNT = 0 THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: заказ не найден или принадлежит другому клиенту.');
        END IF;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка отмены заказа: ' || SQLERRM);
    END cancel_own_order_admin;
    
    
    PROCEDURE purchase_membership_client(
        p_membership_id IN NUMBER
    ) IS
        v_client_id NUMBER;
        v_count     NUMBER;
    BEGIN
        pkg_security.assert_client;
    
        -- Получаем client_id из контекста приложения
        v_client_id := SYS_CONTEXT('APP_CTX', 'CLIENT_ID');
    
        -- Проверяем, что клиент существует
        SELECT client_id
        INTO v_client_id
        FROM clients
        WHERE client_id = v_client_id;
    
        -- Проверка: есть ли уже активный такой же абонемент
        SELECT COUNT(*)
        INTO v_count
        FROM membership_orders
        WHERE client_id = v_client_id
          AND membership_id = p_membership_id
          AND status = 'ACTIVE';
    
        IF v_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: у вас уже есть активный абонемент данного типа.');
        END IF;
    
        -- Оформление заказа
        INSERT INTO membership_orders (
            client_id,
            membership_id,
            order_date,
            status
        )
        VALUES (
            v_client_id,
            p_membership_id,
            SYSDATE,
            'ACTIVE'
        );
    
        COMMIT;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: клиентский профиль не найден.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка оформления заказа: ' || SQLERRM);
    END purchase_membership_client;


    PROCEDURE cancel_own_order_client(p_order_id IN NUMBER) IS
        v_user_id NUMBER;
        v_client_id NUMBER;
    BEGIN
        pkg_security.assert_client;
    
        v_client_id := SYS_CONTEXT('APP_CTX', 'CLIENT_ID');
    
        UPDATE membership_orders mo
        SET status = 'CANCELLED'
        WHERE mo.order_id = p_order_id
          AND mo.client_id = (
              SELECT client_id FROM clients WHERE client_id = v_client_id
          );
    
        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: заказ не найден или не принадлежит вам.');
        END IF;
    
        COMMIT;
    END cancel_own_order_client;


END pkg_orders_client;


DROP PACKAGE pkg_orders_client;