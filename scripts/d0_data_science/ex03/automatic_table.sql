-- CREATE OR REPLACE FUNCTION create_custom_table(tablename TEXT)
-- RETURNS void AS $$
-- BEGIN
--   EXECUTE format('
--     CREATE TABLE IF NOT EXISTS %I (
--         event_time TIMESTAMPTZ NOT NULL,
--         event_type TEXT,
--         product_id INTEGER,
--         price NUMERIC(10,2),
--         user_id BIGINT,
--         user_session UUID
--     )
--   ', tablename);
-- END;
-- $$ LANGUAGE plpgsql;


-- -- SELECT create_custom_table();
CREATE FUNCTION get_record (query TEXT) 
RETURNS RECORD AS $$
DECLARE
    rec RECORD;
BEGIN
    EXECUTE query INTO rec;
    RETURN rec; 
END;
$$ LANGUAGE plpgsql;


SELECT
  *
FROM
  get_record (
    'SELECT product_name, price FROM products WHERE product_id = 1'
  ) AS product_info (product_name VARCHAR, price DEC);