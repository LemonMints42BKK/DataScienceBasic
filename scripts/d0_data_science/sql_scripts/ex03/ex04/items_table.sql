CREATE OR REPLACE FUNCTION create_items_table(tablename TEXT)
RETURNS void AS $$
BEGIN
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I (
        product_id INTEGER NOT NULL,
        category_id BIGINT,
        category_code TEXT,
        brand VARCHAR(255)
    )', tablename);
END;
$$ LANGUAGE plpgsql;

-- Call the function to create the table
SELECT create_items_table('items');
