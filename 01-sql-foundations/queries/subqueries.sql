-- Compare each order value against the global average order value
-- Inner query returns a single number (global aggregate)
-- Useful when you need a benchmark or threshold for comparison
SELECT DISTINCT c.name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id = p.product_id
WHERE (o.quantity * p.price) >
      (
        SELECT AVG(o2.quantity * p2.price)
        FROM orders o2
        JOIN products p2 ON o2.product_id = p2.product_id
      );


-- Calculate total spent per customer
-- Correlated subquery runs once per customer
-- Clear to read, but can be slow on large tables
SELECT
  c.name,
  (
    SELECT SUM(o.quantity * p.price)
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    WHERE o.customer_id = c.customer_id
  ) AS total_spent
FROM customers c;


-- Pre-aggregate customer spend
-- Subquery works like a temp table (derived table)
-- Makes it easier to filter after aggregation
SELECT
  t.customer_id,
  t.total_spent
FROM (
  SELECT
    o.customer_id,
    SUM(o.quantity * p.price) AS total_spent
  FROM orders o
  JOIN products p ON o.product_id = p.product_id
  GROUP BY o.customer_id
) t
WHERE t.total_spent > 3000;