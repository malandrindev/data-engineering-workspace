-- Pre-aggregate customer spend using a CTE
-- Improves query readability and logical separation of concerns
-- Commonly preferred over deeply nested subqueries in production workloads
WITH customer_spend AS (
  SELECT
    o.customer_id,
    SUM(o.quantity * p.price) AS total_spent
  FROM orders o
  JOIN products p ON o.product_id = p.product_id
  GROUP BY o.customer_id
)
SELECT
  customer_id,
  total_spent
FROM customer_spend
WHERE total_spent > 3000;
