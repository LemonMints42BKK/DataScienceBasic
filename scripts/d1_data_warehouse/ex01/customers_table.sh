CREATE OR REPLACE FUNCTION create_table(tablename TEXT)
RETURNS void AS $$
BEGIN
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I (
        event_time TIMESTAMPTZ NOT NULL,
        event_type TEXT,
        product_id INTEGER,
        price NUMERIC(10,2),
        user_id BIGINT,
        user_session UUID
    )
  ', tablename);
END;
$$ LANGUAGE plpgsql;

DO
$$
DECLARE
    tbl RECORD;
    first_table_name TEXT;
    customers_created BOOLEAN := false;
BEGIN
    -- Drop customers table if it already exists and create new one
    EXECUTE 'DROP TABLE IF EXISTS customers';
    PERFORM create_table('customers');
    IF EXISTS (
        SELECT 1
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename = 'customers') 
    THEN
        RAISE NOTICE 'Creating customers table';
        customers_created := true;
    END IF;
    -- Find all tables thatmatch pattern data_202*_*
    RAISE NOTICE 'Starting table merge...';

    FOR tbl IN 
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
          AND tablename LIKE 'data_202%'
        ORDER BY tablename
    LOOP
        RAISE NOTICE 'Inserting data from %', tbl.tablename;
        EXECUTE format('INSERT INTO customers SELECT * FROM %I', tbl.tablename);
    END LOOP;

    RAISE NOTICE 'Done merging tables.';
    
    IF NOT customers_created THEN
        RAISE NOTICE 'No matching tables found to merge!';
    END IF;
END
$$ LANGUAGE plpgsql;

