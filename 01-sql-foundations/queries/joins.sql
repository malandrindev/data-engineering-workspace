-- =========================================================
-- INNER JOIN
-- Returns only records with matching keys on both sides
-- Typically used when analyzing confirmed transactional activity
-- =========================================================
SELECT
    o.order_id,
    c.name AS customer_name,
    p.name AS product_name,
    o.quantity,
    o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN products p ON o.product_id = p.product_id;

-- =========================================================
-- LEFT JOIN
-- Preserves all records from the left table regardless of matches
-- Useful to identify missing relationships or incomplete activity
-- =========================================================
SELECT
    c.name,
    o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- =========================================================
-- AGGREGATION WITH JOIN
-- Changes data grain from order-level to customer-level
-- Common pattern for analytical and reporting workloads
-- =========================================================
SELECT
    c.name,
    SUM(o.quantity * p.price) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN products p
    ON o.product_id = p.product_id
GROUP BY c.name;