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


-- Rank customers by total spend
-- RANK skips positions when there are ties
-- Useful when relative position matters more than sequence
WITH customer_spend AS (
  SELECT
    o.customer_id,
    SUM(o.quantity * p.price) AS total_spent
  FROM orders o
  JOIN products p ON o.product_id = p.product_id
  GROUP BY o.customer_id
)
SELECT
  c.name AS customer_name,
  cs.total_spent,
  RANK() OVER (
    ORDER BY cs.total_spent DESC
  ) AS spend_rank
FROM customer_spend cs
JOIN customers c ON cs.customer_id = c.customer_id;


-- Dense ranking of customers by total spend
-- Keeps ranking continuous even when there are ties
-- Preferred for top-N analytics
WITH customer_spend AS (
  SELECT
    o.customer_id,
    SUM(o.quantity * p.price) AS total_spent
  FROM orders o
  JOIN products p ON o.product_id = p.product_id
  GROUP BY o.customer_id
)
SELECT
  c.name AS customer_name,
  cs.total_spent,
  DENSE_RANK() OVER (
    ORDER BY cs.total_spent DESC
  ) AS spend_rank
FROM customer_spend cs
JOIN customers c ON cs.customer_id = c.customer_id;


-- Compare current order value with the previous order
-- LAG allows temporal comparison without self-joins
-- Common in behavior and trend analysis
SELECT
  c.name AS customer_name,
  o.order_id,
  o.order_date,
  o.quantity * p.price AS order_value,
  LAG(o.quantity * p.price) OVER (
    PARTITION BY c.customer_id
    ORDER BY o.order_date
  ) AS previous_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;


-- Compare current order with the next one
-- LEAD enables forward-looking analysis
-- Useful for churn and lifecycle modeling
SELECT
  c.name AS customer_name,
  o.order_id,
  o.order_date,
  o.quantity * p.price AS order_value,
  LEAD(o.quantity * p.price) OVER (
    PARTITION BY c.customer_id
    ORDER BY o.order_date
  ) AS next_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;
