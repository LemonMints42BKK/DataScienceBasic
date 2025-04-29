ALTER TABLE customers ADD COLUMN IF NOT EXISTS category_id BIGINT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS category_code TEXT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS brand VARCHAR(255);

UPDATE customers c
SET
	category_id = i.category_id,
	category_code = i.category_code,
	brand = i.brand
FROM (
	SELECT DISTINCT ON (product_id) *
    FROM items
    ORDER BY product_id, category_id
) i
WHERE c.product_id = i.product_id;
