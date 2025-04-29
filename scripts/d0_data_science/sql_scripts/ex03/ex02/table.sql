CREATE OR REPLACE FUNCTION create_custom_table(tablename TEXT)
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


-- SELECT create_custom_table();


