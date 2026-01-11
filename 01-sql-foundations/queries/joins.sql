-- =========================================================
-- INNER JOIN
-- Purpose: return only records where matching rows exist
-- Meaning: customers that actually placed orders
-- Typical use case: sales analysis, fact tables
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
-- Purpose: preserve all rows from the left table
-- Meaning: identify customers with or without orders
-- Typical use case: churn analysis, completeness checks
-- =========================================================
SELECT
    c.name,
    o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- =========================================================
-- AGGREGATION with JOIN
-- Purpose: calculate total spend per customer
-- Meaning: change data grain from order-level to customer-level
-- Typical use case: customer analytics, revenue reporting
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