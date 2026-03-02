CREATE OR REPLACE PACKAGE pkg_memberships_admin IS
    PROCEDURE add_membership(p_name IN VARCHAR2, p_desc IN VARCHAR2, p_duration IN NUMBER, p_price IN NUMBER);
    PROCEDURE update_membership(p_membership_id IN NUMBER, p_price IN NUMBER);
    PROCEDURE delete_membership(p_membership_id IN NUMBER);
    PROCEDURE get_membership_info_admin(p_membership_id IN NUMBER);
END pkg_memberships_admin;


CREATE OR REPLACE PACKAGE BODY pkg_memberships_admin IS
    PROCEDURE add_membership(p_name IN VARCHAR2, p_desc IN VARCHAR2, p_duration IN NUMBER, p_price IN NUMBER) IS
    BEGIN
        pkg_security.assert_admin;
        INSERT INTO memberships(name, description, duration_months, price)
        VALUES (p_name, p_desc, p_duration, p_price);
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: такой абонемент уже существует.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка добавления абонемента: ' || SQLERRM);
    END add_membership;

    PROCEDURE update_membership(p_membership_id IN NUMBER, p_price IN NUMBER) IS
    BEGIN
        pkg_security.assert_admin;
        UPDATE memberships SET price = p_price WHERE membership_id = p_membership_id;
        IF SQL%ROWCOUNT = 0 THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: абонемент не найден.');
        END IF;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка обновления абонемента: ' || SQLERRM);
    END update_membership;

    PROCEDURE delete_membership(p_membership_id IN NUMBER) IS
    BEGIN
        pkg_security.assert_admin;
        DELETE FROM memberships WHERE membership_id = p_membership_id;
        IF SQL%ROWCOUNT = 0 THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка: абонемент не найден.');
        END IF;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Ошибка удаления абонемента: ' || SQLERRM);
    END delete_membership;

    PROCEDURE get_membership_info_admin(p_membership_id IN NUMBER) IS
        v_name memberships.name%TYPE;
        v_price memberships.price%TYPE;
    BEGIN
        pkg_security.assert_admin;
        SELECT name, price INTO v_name, v_price FROM memberships WHERE membership_id = p_membership_id;
        DBMS_OUTPUT.PUT_LINE('Membership: ' || v_name || ', Price: ' || v_price);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: абонемент не найден.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка получения информации о абонементе: ' || SQLERRM);
    END get_membership_info_admin;

END pkg_memberships_admin;


DROP PACKAGE pkg_memberships_admin;