DO $$
DECLARE
  file RECORD;
  column_list TEXT;
  first_row TEXT;
  file_path TEXT;
  table_name TEXT;
BEGIN
  -- loop over CSV files in the /data directory
  FOR file IN
    SELECT filename
    FROM (
        SELECT pg_ls_dir('/data/subject/customer') AS filename
    ) AS files
    WHERE RIGHT(filename, 4) = '.csv'
  LOOP
    --prepare table name without .csv extention
    table_name := regexp_replace(file.filename, '\.csv$', '', 'i');
    --set file path
    file_path := '/data/subject/customer/' || file.filename;
    -- Create table if not exists
    EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I (
        event_time TIMESTAMPTZ NOT NULL,
        event_type TEXT,
        product_id INTEGER,
        price NUMERIC(10,2),
        user_id BIGINT,
        user_session UUID
    )', table_name);
    -- Import data into the table (skip header)
    EXECUTE format(
        'COPY %I FROM %L WITH (FORMAT csv, HEADER true)', 
        table_name, 
        file_path
        );

        RAISE NOTICE 'Imported CSV: %', file.filename;
  END LOOP;
END;
$$ LANGUAGE plpgsql;