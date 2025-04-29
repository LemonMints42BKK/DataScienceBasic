DO
$$
BEGIN
    DELETE FROM customers c1
    USING customers c2
    WHERE
        c1.ctid < c2.ctid
        AND c1.product_id = c2.product_id
        AND c1.user_id = c2.user_id
        AND c1.event_type = c2.event_type;
END
$$ LANGUAGE plpgsql;

