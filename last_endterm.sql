-- Ordinary PL/SQL program  + Associative array/Record:
CREATE OR REPLACE TYPE split_tb1 as TABLE OF VARCHAR2(32767);
/

CREATE OR REPLACE FUNCTION SPLIT1(p_list varchar2, p_del varchar2 := ' ')
RETURN split_tb1 pipelined
IS
   l_idx pls_integer;
   l_list varchar2(32767) := p_list;
   l_value varchar2(32767);
BEGIN
    LOOP
        l_idx := instr(l_list, p_del);
        IF l_idx > 0 THEN
            pipe row(substr(l_list, 1, l_idx - 1));
            l_list := substr(l_list, l_idx + length(p_del));
        ELSE
            pipe row(l_list);
            exit;
        END IF;
    END LOOP;
    return;
END split1;
/
show errors;

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
SHOW ERRORS;

--select split('foo,bar,zoo') from dual;
--select * from table(split('foo bar zoo', ' '));

CREATE OR REPLACE function safe_to_number(p varchar2) return INTEGER is
    v INTEGER := 0;
  begin
    v := to_number(p);
    return v;
  exception when others then return null;
end;
/
SHOW ERRORS;

CREATE OR REPLACE PROCEDURE num_collector(p VARCHAR2) IS
    TYPE number_array IS TABLE OF INTEGER
    INDEX BY PLS_INTEGER;
    num_arr number_array;
    parsed_array split_tb1;
    s INTEGER := 0;
    n INTEGER := 0;
BEGIN
    n := 0;
    parsed_array := split2(p);
    FOR i in parsed_array.first..parsed_array.last LOOP
        IF safe_to_number(parsed_array(i)) is not NULL THEN
            num_arr(i) := safe_to_number(parsed_array(i));
            s := s + num_arr(i);
            n := n + 1;
        END IF;
    END LOOP;
    dbms_output.put_line('sum: ' || s || ', count: ' || n);
END;
/
show ERRORS;


set serveroutput on;
execute num_collector('2 days ago I bought 21 eggs from  the market');


-- Cursors
CREATE OR REPLACE PROCEDURE cur_salcat IS
    CURSOR emp_calcs IS select 
        COUNT(empno) as emp_num, category, ROUND(AVG(sal), 2) as sal_avg, ROUND(STDDEV(sal)) as sal_dev 
        from paltamas.sal_cat a1 
        JOIN paltamas.emp a2 on a2.sal > a1.lowest_sal AND a2.sal < a1.highest_sal 
        group by category;
    emp_row emp_calcs%ROWTYPE;    
BEGIN
    OPEN emp_calcs;
    LOOP
        FETCH emp_calcs INTO emp_row;
        EXIT WHEN emp_calcs%NOTFOUND;
        
        dbms_output.put_line(emp_row.emp_num || ' ' || emp_row.category || ' ' || emp_row.sal_avg || ' ' || emp_row.sal_dev);
    END LOOP;
END;
/
show ERRORS;


set serveroutput on;
execute cur_salcat();


-- DML in PL/SQL (where current of)


CREATE OR REPLACE FUNCTION product_of_digits(sal INTEGER) RETURN INTEGER IS 
    sum_digits INTEGER := 1;
    init INTEGER;
    mod_v INTEGER;
BEGIN 
    init := sal;
    WHILE init <> 0 LOOP
        IF MOD(init, 10) <> 0 THEN
            sum_digits := sum_digits * MOD(init, 10);
        END IF;
        init := trunc(init / 10);
    END LOOP;
    RETURN sum_digits;
END;
/

CREATE OR REPLACE PROCEDURE upd_comm IS 
    CURSOR emp_curs IS SELECT comm, sal FROM emp FOR UPDATE;
    curs_row emp_curs%ROWTYPE;
BEGIN
    FOR curs_row IN emp_curs LOOP
        UPDATE emp set comm =  product_of_digits(curs_row.sal) * 25 WHERE CURRENT OF emp_curs;
    END LOOP;
END;
/
show ERRORS;

select * from emp;

set serveroutput on;
execute upd_comm();

SELECT product_of_digits(1550) from dual;


-- Cursor/Select Into + Exception Handling:
CREATE OR REPLACE FUNCTION get_subs(p_empno integer) RETURN VARCHAR IS
     CURSOR emp_curs IS SELECT sal, empno, ename FROM emp;
     curs_row emp_curs%ROWTYPE;
     E_MGR_NOT_FOUND EXCEPTION;
     found VARCHAR(255);
     i INTEGER := 0;
BEGIN
    FOR curs_row in (select sal, empno, ename from emp where mgr = p_empno) LOOP
        found := CONCAT(found, CONCAT(curs_row.ename, ','));
        i := i + 1;                      
    END LOOP;
    
    if found is null THEN
        RAISE E_MGR_NOT_FOUND;
    END IF;
    
    return found;
    
    EXCEPTION 
        WHEN E_MGR_NOT_FOUND THEN 
            found := 'no subordinates';
            return found;
END;
/

select get_subs(766) from dual;
SELECT  * from emp where emp.mgr = 7566;

SELECT * from nikovits.flight;


-- SQL recursion

CREATE OR REPLACE PROCEDURE find_all_paths(p_start VARCHAR2, p_end 	VARCHAR2) IS 
BEGIN
    FOR rec_row IN 
    (
        select SYS_CONNECT_BY_PATH(orig, '-') || '-' || dest as route, level
        FROM NIKOVITS.FLIGHT
        start with orig = p_start
        connect by NOCYCLE prior dest = orig    
    ) LOOP
        dmbs_output.put_line(rec_row.route);
    END LOOP;
END;
/

--- ALI's endterm
--- exercise 6
CREATE OR REPLACE PROCEDURE rich_avg_descendant IS
avg_money INTEGER(6);
BEGIN
    FOR rec_row IN (SELECT name, money from NIKOVITS.PARENTOF) LOOP
        SELECT AVG(money) into avg_money
        from NIKOVITS.PARENTOF 
        start with name = rec_row.name
        connect by prior name = parent;
        
        IF avg_money > rec_row.money THEN
            dbms_output.put_line(rec_row.name || ' - ' || rec_row.money || ' - ' || avg_money);
        END IF;
    END LOOP;
END;
/
show errors;


set serveroutput on;
execute rich_avg_descendant();

-- exercise 5
CREATE OR REPLACE FUNCTION sum_of2(p_char VARCHAR2) RETURN INTEGER IS 
    splitted_char split_tb1;
    s INTEGER := 0;
BEGIN
    splitted_char := split2(p_char, '+');
    FOR i in splitted_char.FIRST..splitted_char.LAST LOOP
        IF safe_to_number(splitted_char(i)) is NULL THEN
            s := s + 0;
        ELSE 
            s := s + safe_to_number(splitted_char(i));
        END IF;    
    END LOOP;
    return s;
END;
/


set serveroutput on;
execute sum_of22('1+21 + bubu + + 2 ++');
SELECT sum_of2('1+21 + bubu + + 2 ++') FROM dual;

-- exercise 4
CREATE OR REPLACE FUNCTION contains(c1 VARCHAR2, c2 VARCHAR2) RETURN INTEGER IS
BEGIN
    IF INSTR(c1, c2) = 0 THEN 
        return 0;
    ELSE 
        return 1;
    END IF;    
END;
/

CREATE OR REPLACE PROCEDURE sal_increase(p_deptno INTEGER) IS 
BEGIN
    FOR curs_row in 
    (SELECT sal, ename, category FROM emp a1 JOIN paltamas.sal_cat a2 ON a1.sal > a2.lowest_sal AND a1.sal < a2.highest_sal where deptno = p_deptno FOR UPDATE)
    LOOP
         IF contains(curs_row.ename, 'T') = 1 THEN 
            UPDATE emp SET sal = 10000 where ename = curs_row.ename;
         ELSE   
            UPDATE emp SET sal = curs_row.category * 10000 where ename = curs_row.ename;
         END IF;
    END LOOP;
END;
/

SELECT sal, ename, category FROM emp a1 JOIN paltamas.sal_cat a2 ON a1.sal > a2.lowest_sal AND a1.sal < a2.highest_sal where deptno = 20;

CREATE OR REPLACE FUNCTION HAS_IDENTICAL(ch_1 VARCHAR2, ch_2 VARCHAR2, times INTEGER default 2) RETURN INTEGER IS
    times_ INTEGER := times;
BEGIN
    FOR i in 1..LENGTH(ch_1) LOOP
        IF substr(ch_1, i , 1) = ch_2 AND times_ > 0 THEN
            times_ := times_ - 1;
        END IF;
    END LOOP;
    IF times_ = 0 THEN
        return 1;
    ELSE
        return 0;
    END IF;    
END;
/

select has_identical('hele', 'e', 3) from dual;

CREATE OR REPLACE PROCEDURE letter2 IS 
    CURSOR emp_curs IS SELECT ename FROM emp;
BEGIN
    FOR emp_row in emp_curs LOOP
        
    END LOOP;
END;
/