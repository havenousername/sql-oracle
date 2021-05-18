CREATE OR REPLACE FUNCTION prim_2(n INTEGER) RETURN NUMBER IS
BEGIN
    FOR i in 2..n/2 LOOP
        IF (MOD(n, i)) = 0 THEN
            RETURN 0;
        END IF;
    END LOOP;
    RETURN 1;
END;
/

CREATE OR REPLACE FUNCTION take_prelast_div(n INTEGER) RETURN NUMBER IS
i NUMBER;
BEGIN
    i := n - 1;
    WHILE i <> 0
    LOOP
        IF MOD(n, i) = 0 THEN
            RETURN i;
        END IF;    
        i := i - 1;
    END LOOP;
    RETURN 1;
END;
/

select take_prelast_div(6) from dual;

CREATE OR REPLACE PROCEDURE num_highdiv(n integer) IS
    TYPE num_array
        IS TABLE OF INTEGER
        INDEX BY INTEGER;
    non_prime num_array;    
    num INTEGER;
    it INTEGER;
BEGIN
    num := 4;
    it := 0;
    WHILE n <> it
    LOOP
        IF prim_2(num) = 1 THEN
            num_array(num) := take_prelast_div(num);
            it := it + 1;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(num_array.LAST));
END;
/