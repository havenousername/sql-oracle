

-- Ordinary PL/SQL program  + Associative array/Record: 
CREATE OR REPLACE TYPE split_tb1 as TABLE OF VARCHAR2(32767);
/

CREATE OR REPLACE FUNCTION SPLIT2(list in VARCHAR2, delimiter in VARCHAR2 default ' ')
RETURN split_tb1 AS
    splitted split_tb1 := split_tb1();
    i pls_integer := 0;
    list_ varchar2(32767) := list;
BEGIN
    LOOP
        i := instr(list_, delimiter);
        IF i > 0 THEN
            splitted.extend(1);
            splitted(splitted.last) := substr(list_, 1, i - 1);
            list_ := substr(list_, i + length(delimiter));
        ELSE
            splitted.extend(1);
            splitted(splitted.last) := list_;
            return splitted;
        END IF;
    END LOOP;
END;
/


CREATE OR REPLACE PROCEDURE wordlen_table(p VARCHAR2) IS
    parsed_array split_tb1;
    TYPE number_array IS TABLE OF INTEGER
    INDEX BY PLS_INTEGER;
    num_arr number_array;
    iter INTEGER;
    siz INTEGER := 0;
    s INTEGER := 0;
BEGIN
    parsed_array := split2(p);
    FOR i in parsed_array.first..parsed_array.last LOOP
        num_arr(i) := LENGTH(parsed_array(i));
    END LOOP;
    
    iter := num_arr.FIRST;
    WHILE iter IS NOT NULL LOOP
        siz := siz + 1;
        s := s + num_arr(iter);
        iter := num_arr.NEXT(iter);
    END LOOP;
    
    dbms_output.put_line('sum: ' || s || ', count: ' || siz);
END;
/

set serveroutput on;
execute wordlen_table('Hello there you monleys');


-- Cursors/Select into 

CREATE OR REPLACE PROCEDURE cur_salcat IS
    CURSOR emp_calcs IS select 
        COUNT(empno) as emp_num, category, ROUND(AVG(sal), 2) as sal_avg, ROUND(STDDEV(sal)) as sal_dev 
        from paltamas.sal_cat a1 
        JOIN paltamas.emp a2 on a2.sal > a1.lowest_sal AND a2.sal < a1.highest_sal 
        group by category;
    emp_row emp_calcs%ROWTYPE; 
    res emp_calcs%ROWTYPE;
    max_num INTEGER := 0; 
BEGIN
    OPEN emp_calcs;
    LOOP
        FETCH emp_calcs INTO emp_row;
        EXIT WHEN emp_calcs%NOTFOUND;
        
        IF emp_row.emp_num > max_num THEN
            res := emp_row;
            max_num := emp_row.emp_num;
        END IF;    
    END LOOP;
    dbms_output.put_line(res.emp_num || ' ' || res.category || ' ' || res.sal_avg || ' ' || res.sal_dev);
END;
/
 
set serveroutput on;
execute cur_salcat();


-- DML in PL/SQL (where current of): 


CREATE OR REPLACE FUNCTION number_odd_of_digits(sal INTEGER) RETURN INTEGER IS 
    sum_digits INTEGER := 0;
    init INTEGER;
    mod_v INTEGER;
BEGIN 
    init := sal;
    WHILE init <> 0 LOOP
        IF MOD(MOD(init, 10), 2)  <> 0 THEN
            sum_digits := sum_digits + 1;
        END IF;
        init := trunc(init / 10);
    END LOOP;
    RETURN sum_digits;
END;
/

-- select number_odd_of_digits(1550) from dual;
-- if you need to create local table
CREATE TABLE emp AS (SELECT * FROM paltamas.emp); 

CREATE OR REPLACE PROCEDURE upd_comm IS 
    CURSOR emp_curs IS SELECT comm, sal FROM emp FOR UPDATE;
    curs_row emp_curs%ROWTYPE;
BEGIN
    FOR curs_row IN emp_curs LOOP
        UPDATE emp set comm =  number_odd_of_digits(curs_row.sal) * 100 WHERE CURRENT OF emp_curs;
    END LOOP;
END;
/
show ERRORS;

select * from emp;
set serveroutput on;
execute upd_comm();

-- Cursor/Select Into + Exception Handling: 
CREATE OR REPLACE FUNCTION get_hires(p_deptno integer) RETURN INTEGER IS
    CURSOR emp_curs IS SELECT sal, empno, ename FROM emp;
    curs_row emp_curs%ROWTYPE;
    number_of_hired INTEGER := 0;
    E_DEPT_NOT_FOUND EXCEPTION;
BEGIN
     FOR curs_row in (select deptno, hiredate from emp where deptno = p_deptno) LOOP
        IF to_date(curs_row.hiredate, 'DD-MON-YY') > to_date('82-JAN-01', 'YY-MON-DD') THEN
            number_of_hired := number_of_hired + 1;
        END IF;
     END LOOP;
     
     IF number_of_hired = 0 THEN 
        RAISE E_DEPT_NOT_FOUND;
     END IF;
     
     return number_of_hired;
     
     EXCEPTION 
        WHEN E_DEPT_NOT_FOUND THEN
            number_of_hired := -1;
            return number_of_hired;
END;
/

select get_hires(20) from dual;

select * from emp;

-- SQL recursion (second function is correct)


CREATE OR REPLACE FUNCTION find_dist(A VARCHAR2, B VARCHAR2) RETURN INTEGER IS
    CURSOR flights IS SELECT route from ( WITH reaches(orig, dest, cost, route) AS 
        (
            SELECT orig, dest, cost , 1 as route FROM FLIGHT
            UNION ALL
            SELECT flight.orig, reaches.dest, flight.cost + reaches.cost, route + 1 as route   from FLIGHT  
            JOIN reaches ON  flight.DEST = reaches.ORIG
        )
        CYCLE orig, dest SET cycle_yes  TO 'Y' DEFAULT 'N'
        SELECT  distinct orig, dest, cost, route FROM reaches
        WHERE orig=A AND dest=B);
    min_flight INTEGER := 1000;
    curs_row flights%ROWTYPE;
BEGIN
    FOR curs_row IN flights LOOP
        IF curs_row.route < min_flight THEN
            min_flight := curs_row.route;
        END IF;    
    END LOOP;
    
    RETURN min_flight;
END; 
/

select * from PALTAMAS.flight;

select find_dist('San Francisco', 'New York') from dual;


