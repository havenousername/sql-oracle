
SELECT deptno, COUNT(job) from (select distinct job, deptno  from   nikovits.emp) group by deptno;

select * from  nikovits.emp ;

select distinct job, deptno  from  nikovits.emp;


CREATE OR REPLACE FUNCTION get_sal_range(p_salcat integer) RETURN 	INTEGER IS
    CURSOR category_curs IS SELECT category, lowest_sal as l ,  highest_sal as h from paltamas.sal_cat;
    sal_range INTEGER := 0;
    changed INTEGER := 0;
    E_CAT_NOT_FOUND EXCEPTION;
BEGIN
    FOR curs_row in (SELECT category, lowest_sal as l ,  highest_sal as h from paltamas.sal_cat) LOOP
        IF p_salcat = curs_row.category THEN
            sal_range := curs_row.h - curs_row.l;
            changed := 1;
        END IF;
    END LOOP;
    
    IF changed = 0 THEN
        RAISE E_CAT_NOT_FOUND;
    END IF;
    
    return sal_range;
    
    EXCEPTION 
        WHEN E_CAT_NOT_FOUND THEN
           return 0;
END;
 /
 
select get_sal_range(1) from dual;  
 
select * from paltamas.sal_cat;

-- SQL recursion / hierarchical query
CREATE OR REPLACE FUNCTION find_dist(A VARCHAR2, B VARCHAR2) RETURN INTEGER	IS 
    CURSOR parentchild IS SELECT * from ( WITH reaches( name, parent, depth) AS 
        (
            SELECT name, parent , 1 as depth FROM nikovits.parentof
            UNION ALL
            SELECT nikovits.parentof.name, reaches.parent, depth + 1 as depth from nikovits.parentof  
            JOIN reaches ON  nikovits.parentof.name = reaches.parent
        )
        CYCLE name, parent SET cycle_yes  TO 'Y' DEFAULT 'N'
        SELECT  distinct name, parent, depth FROM reaches
        WHERE name=A AND parent=B);
    curs_row parentchild%ROWTYPE;
    distance INTEGER;
BEGIN 
    FOR curs_row IN parentchild LOOP
         distance := curs_row.depth;
    END LOOP;
    
    return distance;
END;
/

select find_dist('GEDEON', 'ADAM') from dual; 
select * from nikovits.parentof;



-----------------------------------------------------
CREATE OR REPLACE FUNCTION find_dist1(A VARCHAR2, B VARCHAR2) RETURN INTEGER	IS 
 l INTEGER;
BEGIN
  SELECT level into l  FROM nikovits.parentof 
  WHERE name = B
  START WITH name = A CONNECT BY PRIOR name = parent;
  
  return l;
END;
/


select find_dist1('GEDEON', 'ADAM') from dual;

set serveroutput on;
call rich_descendant();


select * from nikovits.parentof;


--- 2 
SELECT ename, job, deptno from   nikovits.emp WHERE deptno = (SELECT deptno from ( SELECT deptno, COUNT(job) from (select distinct job, deptno  from   nikovits.emp) group by deptno) where ROWNUM = 1);



CREATE OR REPLACE PROCEDURE people_of_dept IS  
    CURSOR emp_dept IS (SELECT ename, job, deptno from   nikovits.emp WHERE deptno = (SELECT deptno from ( SELECT deptno, COUNT(job) from (select distinct job, deptno  from   nikovits.emp) group by deptno) where ROWNUM = 1));
    emp_row emp_dept%ROWTYPE;
BEGIN
    OPEN emp_dept;
    LOOP
        FETCH emp_dept  INTO emp_row;
        EXIT WHEN emp_dept%NOTFOUND;
        dbms_output.put_line(emp_row.ename || ' ' || emp_row.job || ' ' || emp_row.deptno);
    END LOOP;
END;
/

set serveroutput on;
execute people_of_dept();

-- 3
CREATE OR REPLACE FUNCTION vname (n varchar2) return integer IS 
cnt Integer:= 0;

begin 
      FOR i IN 1..length(n) LOOP 

            IF upper(substr(n,i,1)) IN ('A','E','I','O','U') THEN 

                cnt := cnt + 1; 

            END IF; 

        END LOOP; 
      return cnt;
       
end;
/

CREATE OR REPLACE PROCEDURE upd_sal IS  
    CURSOR cur IS 
    SELECT ename, sal FROM emp FOR UPDATE; 
    rec cur%ROWTYPE; 
    newsal INTEGER; 
BEGIN 

    FOR rec IN cur LOOP 
        update emp set emp.sal = emp.sal + 100*vname(emp.sal); 
        select emp.sal into newsal from emp where emp.ename = rec.ename; 
        dbms_output.put_line(rec.ename || ' ' || newsal); 

    END LOOP; 

    rollback; 

END;

select * from emp;
set serveroutput on;
execute upd_sal();

SELECT vname('AIPERI') from  dual;