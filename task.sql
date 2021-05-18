CREATE TABLE countries (
    id NUMBER NOT NULL,
    name VARCHAR(40),
    iso VARCHAR(3),
    CONSTRAINT table_id PRIMARY KEY (id)
);

CREATE TABLE users (
    id NUMBER NOT NULL,
    email VARCHAR(255),
    citizenship_country_id NUMBER,
    CONSTRAINT country_id FOREIGN KEY (citizenship_country_id)
                   references countries(id)
);


create or replace PROCEDURE populate_tables IS
    id_countries NUMBER;
    id_users NUMBER;
    country varchar(40);
    country_iso varchar(3);
    user_email varchar(255);
    i NUMBER;
    j NUMBER;
BEGIN
  i := 0;
  LOOP
    i := i + 1;
    --country := 'country-number:';
    country := CONCAT('country-number:', i);
    country_iso := dbms_random.string('L', 3);
    INSERT INTO countries(id, name, iso) VALUES (i, country, country_iso);
    j := 0;
    LOOP
        j := j + 1;
        user_email := dbms_random.string('L', 20);
        INSERT INTO users(id, email, citizenship_country_id) VALUES (j, user_email, i);
        EXIT WHEN (j >  dbms_random.value(999, 1500));
    END LOOP;
    EXIT WHEN (i > 10);
  END LOOP;
END;
/
EXECUTE populate_tables;

WITH 
countries_join as (select countries.name, users.citizenship_country_id, users.email from countries JOIN users ON users.citizenship_country_id = countries.id)
select name, COUNT(citizenship_country_id) from countries_join group by citizenship_country_id, name having COUNT(citizenship_country_id) > 1000 order by COUNT(citizenship_country_id) 
;



-- DROP TABLE users;
--DROP TABLE countries;