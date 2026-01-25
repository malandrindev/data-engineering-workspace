-- Compare each order value against a global average benchmark
-- Scalar subquery used to compute a single reference metric
-- Useful when applying relative thresholds or outlier detection
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


-- Calculate total spend per customer using a correlated subquery
-- Evaluated once per outer row, readable but potentially expensive at scale
SELECT
  c.name,
  (
    SELECT SUM(o.quantity * p.price)
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    WHERE o.customer_id = c.customer_id
  ) AS total_spent
FROM customers c;


-- Pre-aggregate customer spend using a derived table
-- Acts as an explicit intermediate result set for post-aggregation filtering
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