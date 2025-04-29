CREATE OR REPLACE PROCEDURE clean_duplicate_customers()
LANGUAGE plpgsql
AS
$$
DECLARE
  rows_deleted INTEGER;
BEGIN
  LOOP
    WITH cte AS (
      SELECT ctid,
             event_time,
             LAG(event_time) OVER (
               PARTITION BY product_id, event_type
               ORDER BY event_time
             ) AS prev_event_time
      FROM customers
    ),
    filtered AS (
      SELECT ctid
      FROM cte
      WHERE prev_event_time IS NOT NULL
        AND EXTRACT(EPOCH FROM (event_time - prev_event_time)) <= 1
    )
    DELETE FROM customers
    WHERE ctid IN (SELECT ctid FROM filtered);

    GET DIAGNOSTICS rows_deleted = ROW_COUNT;
    EXIT WHEN rows_deleted = 0;
  END LOOP;
END;
$$;


CALL clean_duplicate_customers();

