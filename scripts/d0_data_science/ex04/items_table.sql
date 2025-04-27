DO $$
DECLARE
  file_path TEXT;
  table_name TEXT;
BEGIN
    table_name := 'items';
    -- Set file path
    file_path := '/data/subject/item/item.csv';  -- Hardcoded path

    -- Create table if not exists
    EXECUTE format('
        CREATE TABLE IF NOT EXISTS %I (
            product_id INTEGER NOT NULL,
            category_id BIGINT,
            category_code TEXT,
            brand VARCHAR(255)
        )', table_name);

    -- Import data into the table (skip header)
    EXECUTE format(
        'COPY %I FROM %L WITH (FORMAT csv, HEADER true)', 
        table_name, 
        file_path
    );

    RAISE NOTICE 'Imported CSV file: %', file_path;
END;
$$ LANGUAGE plpgsql;
