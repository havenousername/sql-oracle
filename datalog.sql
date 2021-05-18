
CREATE OR REPLACE FUNCTION day_name(d varchar2) RETURN varchar2 IS
BEGIN
    return to_date(d, 'yyyy.mm.dd');
    EXCEPTION
        WHEN VALUE_ERROR THEN 
        BEGIN 
            return to_date(d, 'dd.mm.yyyy');
        END;
        EXCEPTION 
            WHEN OTHERS  THEN
            return 'wrong  format';
END;
/

-- SELECT day_name('2017.05.01'), day_name('02.05.2017'), day_name('abc') from dual;

