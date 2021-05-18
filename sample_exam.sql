-- Ordinary PL/SQL program  + Associative array/Record:

CREATE OR REPLACE FUNCTION greatest_non_trivial_divisor(n INTEGER) RETURN INTEGER IS 
    iter INTEGER(3) := 0;
BEGIN
    iter := n;
    while n % iter <> 0 LOOP
        n := n -1;
    END LOOP;
    
    return iter;
END;
/

SELECT greatest_non_trivial_divisor(6) from dual;

-- CREATE OR REPLACE PROCEDURE num_highdiv(n integer) IS