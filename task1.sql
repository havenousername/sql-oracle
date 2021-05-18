CREATE TABLE countries (
    id NUMBER NOT NULL,
    name VARCHAR(40),
    iso VARCHAR(3),
    CONSTRAINT table_id PRIMARY KEY (id)
);

CREATE TABLE users (
    id NUMBER NOT NULL UNIQUE,
    email VARCHAR(255),
    citizenship_country_id NUMBER,
    CONSTRAINT country_id FOREIGN KEY (citizenship_country_id)
                   references countries(id),
    CONSTRAINT country_unique UNIQUE (citizenship_country_id, id)
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
    country := 'country-number:';
    country := country + TO_CHAR(i);
    country_iso := dbms_random.string('L', 3);
    INSERT INTO countries(id, name, iso) VALUES (i, country, country_iso);
    j := 0;
    LOOP
        user_email := dbms_random.string('L', 20);
        INSERT INTO users(id, email, citizenship_country_id) VALUES (j, user_email, i);
        EXIT WHEN (j >  dbms_random.value(1, 300));
    END LOOP;
    EXIT WHEN (i > 10);
  END LOOP;
END;

EXEC populate_tables;

-- DROP TABLE users;
-- DROP TABLE countries;