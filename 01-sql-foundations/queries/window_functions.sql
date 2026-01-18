-- Calculate total spend per customer without collapsing rows
-- Window function keeps row-level detail
-- Useful for analytics, reporting and dashboards
SELECT
  o.order_id,
  c.name AS customer_name,
  o.order_date,
  o.quantity * p.price AS order_value,
  SUM(o.quantity * p.price) OVER (PARTITION BY c.customer_id) AS total_spent_by_customer
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;


-- Assign a sequential number to each order per customer
-- Useful for churn analysis, lifecycle tracking, first/last events
SELECT
  c.name,
  o.order_id,
  o.order_date,
  o.quantity * p.price AS order_value,
  ROW_NUMBER() OVER (
    PARTITION BY c.customer_id
    ORDER BY o.order_date
  ) AS order_sequence
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;
