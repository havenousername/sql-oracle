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

-- Cursors/ Select Into
CREATE OR REPLACE FUNCTION subord_sum(p_empno integer) RETURN INTEGER IS
    sum_mgr paltamas.emp.mgr%TYPE;
    sum_sum paltamas.emp.sal%TYPE;
    CURSOR subordinates_sum IS (SELECT mgr, SUM(sal) from paltamas.emp group by mgr);
    summation INTEGER := 0;
BEGIN
    OPEN subordinates_sum;
    LOOP
        FETCH subordinates_sum INTO  sum_mgr, sum_sum;
        EXIT WHEN subordinates_sum%NOTFOUND;
        IF sum_mgr = p_empno THEN 
            summation := sum_sum;
        END IF;
    END LOOP;
    RETURN summation;
END;
/

-- DML in PL/SQL (where current of):

CREATE OR REPLACE FUNCTION sum_of_digits(sal INTEGER) RETURN INTEGER IS 
    sum_digits INTEGER := 0;
    init INTEGER;
BEGIN 
    init := sal;
    WHILE init <> 0 LOOP
        sum_digits := sum_digits + MOD(init, 10);
        init := trunc(init / 10);
    END LOOP;
    RETURN sum_digits;
END;
/


CREATE OR REPLACE PROCEDURE upd_sal IS
    CURSOR emp_curs IS SELECT sal FROM emp FOR UPDATE;
    curs_row emp_curs%ROWTYPE;
BEGIN
    FOR curs_row IN emp_curs LOOP
        dbms_output.put_line('OLD SALARY: ' || curs_row.sal);
        UPDATE emp SET sal = sum_of_digits(sal) * 10 where CURRENT OF emp_curs;
        dbms_output.put_line('NEW SALARY: ' || curs_row.sal);
    END LOOP;
END;
/

-- Cursor/Select Into + Exception Handling:
CREATE OR REPLACE FUNCTION get_emp_info(p_empno integer) RETURN VARCHAR IS 
    CURSOR emp_curs IS SELECT sal, empno, ename FROM emp;
    curs_row emp_curs%ROWTYPE;
    found_sal emp.sal%TYPE := null;
    found_name emp.ename%TYPE := null;
    E_EMPNO_NOT_FOUND EXCEPTION;
    found_sal_name VARCHAR(255);
BEGIN
    FOR curs_row in emp_curs LOOP
        IF curs_row.empno = p_empno THEN
            found_sal := curs_row.sal;
            found_name := curs_row.ename;
        END IF;
    END LOOP;
    
    IF found_sal IS NULL OR found_name IS NULL THEN
        RAISE E_EMPNO_NOT_FOUND;
    ELSE 
        found_sal_name := CONCAT(CONCAT(TO_CHAR(found_name), ' , '),  TO_CHAR(found_sal));
    END IF;
    
    return found_sal_name;
    EXCEPTION 
        WHEN E_EMPNO_NOT_FOUND THEN 
            found_sal_name := 'wrong empno'; 
            return found_sal_name;
END;
/

select * from paltamas.emp;
set serveroutput on;
SELECT SUBORD_SUM(7566) from dual;
SELECT sum_of_digits(15) from dual;

set serveroutput on;
execute upd_sal();
ROLLBACK;
select * from emp;

select get_emp_info(90) from dual;
