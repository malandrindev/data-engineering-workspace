-- Pre-aggregate customer spend using a CTE
-- Makes the query easier to read and maintain
-- Preferred over nested subqueries in production
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
