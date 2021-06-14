SELECT * from emp3 e1 JOIN (SELECT hiredate, COUNT(hiredate) from emp3 
group by hiredate 
HAVING COUNT(hiredate) > 1) e2
ON e1.hiredate = e2.hiredate;


select * from emp3;

DELETE FROM emp3 WHERE empno IN (SELECT mgr from
((SELECT e1.mgr, e1.hireday, e2.empno from (SELECT hireday, mgr, COUNT(hireday) as cnt from (
SELECT mgr, TO_CHAR(hiredate, 'DAY') 
as hireday from emp3 
order by mgr)
GROUP BY hireday, mgr) e1 JOIN
(SELECT * from emp3) e2 
ON  e1.mgr =  e2.mgr and e1.cnt >= 2  ORDER by mgr))
GROUP BY mgr);

select ROUND(avg(sal)) from emp3;



select * from nikovits.edge;

SELECT CONCAT(CONCAT(CONCAT(CONCAT(orig, ', '), dest), ', '), weight)  from (SELECT * from (SELECT weight, orig, dest  from ( WITH reaches(orig, dest, weight, route) AS 
        (
            SELECT orig, dest, weight , 1 as route FROM nikovits.edge
            UNION ALL
            SELECT nikovits.edge.orig, reaches.dest, nikovits.edge.weight + reaches.weight, route + 1 as route   from nikovits.edge  
            JOIN reaches ON  nikovits.edge.DEST = reaches.ORIG
        )
        CYCLE orig, dest SET cycle_yes  TO 'Y' DEFAULT 'N'
        SELECT  distinct orig, dest, weight, route FROM reaches
        WHERE dest = 'E')) order by weight) where ROWNUM = 1;
        
        
-- 6th
CREATE TABLE Bookings (
    fRow NUMBER(4),
    seat VARCHAR(20),
    PRIMARY KEY(frow),
    SSno VARCHAR(255),
    fNumber NUMBER(5),
    FOREIGN KEY (SSno) references CUSTOMERS(SSno),
    FOREIGN KEY (fNumber) references FLIGHTS(fNumber)
);

DROP TABLE CUSTOMERS;

CREATE TABLE CUSTOMERS (
    SSNo VARCHAR(255),
    name VARCHAR(40),
    addr VARCHAR(40),
    phone NUMBER(20),
    CONSTRAINT ss PRIMARY KEY(SSno)
);

CREATE TABLE FLIGHTS (
    fNumber NUMBER(5),
    aircraft VARCHAR(30),
    day VARCHAR(10),
    PRIMARY KEY(fNUMBER)
);


SELECT a.mgr, b.ename, to_char(a.hiredate, 'Day')  from (nikovits.emp  a JOIN nikovits.emp b ON a.mgr = b.empno) group by a.mgr,b.ename, to_char(a.hiredate, 'Day') having count(*) >= 2;
DROP TABLE emp2;
DROP TABLE emp3;

-- 3
CREATE TABLE emp2 AS (select * from nikovits.emp);
(select deptno, AVG(sal) as sal, category from
(select * from emp2 JOIN nikovits.sal_cat 
ON emp2.sal >= nikovits.sal_cat.lowest_sal and emp2.sal <= nikovits.sal_cat.highest_sal) 
GROUP BY deptno, category having category = 2);

UPDATE emp2 
set sal = sal + ((select sal
from (select deptno, AVG(sal) as sal, category from
(select * from emp2 JOIN nikovits.sal_cat 
ON emp2.sal >= nikovits.sal_cat.lowest_sal and emp2.sal <= nikovits.sal_cat.highest_sal) 
GROUP BY deptno, category having category = 2) where deptno = emp2.deptno));


update emp2 a
 set sal = sal + (select avg(sal) 
 from emp2 
 where a.deptno = deptno)
 where (sal, 2) in (select sal, category  from nikovits.emp join nikovits.sal_cat on (sal between lowest_sal and highest_sal)); 


(select sal
from (select deptno, AVG(sal) as sal, category from
(select * from emp2 JOIN nikovits.sal_cat 
ON emp2.sal >= nikovits.sal_cat.lowest_sal and emp2.sal <= nikovits.sal_cat.highest_sal) 
GROUP BY deptno, category having category = 2) where deptno = 10);

select avg(sal) from emp2;


CREATE OR REPLACE PROCEDURE printEmp IS 
CURSOR cur is SELECT * from nikovits.emp ORDER BY DEPTNO, SAL DESC;
EMP2_REC EMP2%ROWTYPE;
CUR_DEP INTEGER := 0;
i INTEGER := 0;
TEMP_VAL INTEGER := 0;
BEGIN
    OPEN CUR;
    LOOP
        IF i = 0 THEN
            FETCH cur INTO emp2_rec;
            i := 1;
            exit when cur%NOTFOUND;
        END IF;
        TEMP_VAL := emp2_rec.sal;
        FETCH CUR INTO emp2_rec;
        EXIT WHEN CUR%NOTFOUND;
        IF (emp2_rec.sal = TEMP_VAL) THEN
            FETCH CUR INTO emp2_rec;
            EXIT WHEN CUR%NOTFOUND;
        END IF;
        dbms_output.put_line(emp2_rec.ename || '' || emp2_rec.sal || '' || emp2_rec.deptno);
        cur_dep := emp2_rec.deptno;
        while cur_dep = emp2_rec.deptno LOOP
            FETCH cur INTO emp2_rec;
            EXIT WHEN CUR%NOTFOUND;
        END LOOP;
    END LOOP;
    CLOSE CUR;
END;
/

set SERVEROUT ON;
execute printEmp;


