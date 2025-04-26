\echo 'Creating table : ' :tablename

\set cmd 'DO $$ BEGIN EXECUTE format(
    ''CREATE TABLE IF NOT EXISTS %I (
        event_time TIMESTAMPTZ NOT NULL,
        event_type TEXT,
        product_id INTEGER,
        price NUMERIC(10,2),
        user_id BIGINT,
        user_session UUID
    )'', quote_ident('':tablename'')
); END $$;'

:cmd







