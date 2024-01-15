CREATE OR REPLACE FUNCTION generate_random_string(length INTEGER)
    RETURNS VARCHAR(10) AS $$
    DECLARE
        characters VARCHAR(62) := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        random_string VARCHAR(10) := '';
        i INTEGER;
    BEGIN
        FOR i IN 1..length LOOP
            random_string := random_string || substr(characters, floor(random() * length(characters) + 1)::integer, 1);
        END LOOP;

        RETURN random_string;
    END;
    $$ LANGUAGE plpgsql;

UPDATE CUSTOMERS_401715 SET SecretCode = generate_random_string(10); 