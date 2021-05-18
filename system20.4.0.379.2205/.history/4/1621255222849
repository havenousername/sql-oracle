CREATE OR REPLACE PROCEDURE rich_descendant IS
    cnt INTEGER(4) := 0;
BEGIN
    FOR rec_row in (SELECT name, money from NIKOVITS.PARENTOF) LOOP
        SELECT count(*) 
        into cnt 
        from NIKOVITS.PARENTOF
        where money > rec_row.money
        start with name  = rec_row.name
        connect by prior name = parent
        ;
        
        if cnt > 0 then 
            dbms_output.put_line(rec_row.name || '-' || rec_row.money || '-' || cnt);
        end if;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE rich_descendant_average IS
avg_money INTEGER(6);
BEGIN
    FOR rec_row in (SELECT NAME, money from NIKOVITS.PARENTOF) LOOP
        SELECT avg(money) 
        into avg_money 
        from nikovits.parentof 
        start with name = rec_row.name
        connect by prior name = parent;
        
        if avg_money > rec_row.money then
         dbms_output.put_line(rec_row.name || '-' || rec_row.money || '-' || avg_money);
        end if;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE find_cycle(p_node VARCHAR2) IS
BEGIN
    FOR rec_row IN 
    (
        select SYS_CONNECT_BY_PATH(orig, '-') || '-' || dest as route
        from NIKOVITS.FLIGHT 
        where CONNECT_BY_ROOT orig = dest
        start with orig = p_node
        connect by NOCYCLE prior dest = orig
    ) LOOP
        dmbs_output.put_line(rec_row.route);
    END LOOP;
END;
/


CREATE OR REPLACE PROCEDURE ancestor2 IS
cnt INTEGER(4);
BEGIN
    FOR rec_row in (SELECT name, city from nikovits.parentof) LOOP
        select count(*) 
        into cnt from (
            select cities from (
                select SYS_CONNECT_BY_PATH(city, '-') as cities
                from nikovits.parentof 
                start with name = rec_row.name
                connect by prior parent = name
            ) 
            where INSTR(cities, rec_row.city, 1, 3) > 0
        );
        if cnt > 0 then 
            dbms_output.put_line(rec_row.name);
        end if;    
    END LOOP;
END;
/

set serveroutput on;
execute rich_descendant();

set serveroutput on;
execute rich_descendant_average();

select * from nikovits.parentof;
select * from NIKOVITS.FLIGHT;

set serveroutput on;
execute ancestor2();