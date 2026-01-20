
/* ============================================================
   WINDOW FUNCTIONS — AGGREGATION WITHOUT COLLAPSING ROWS
   ============================================================ */

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


/* ============================================================
   WINDOW FUNCTIONS — ORDERING & SEQUENCING
   ============================================================ */

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


/* ============================================================
   WINDOW FUNCTIONS — RANKING
   ============================================================ */

-- Rank customers by total spend
-- Ranking is applied after aggregation to avoid row duplication
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


/* ============================================================
   WINDOW FUNCTIONS — TEMPORAL ANALYSIS (LAG / LEAD)
   ============================================================ */

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


-- Compare current order value with the previous order of the same customer
-- This pattern is used to detect growth or decline between consecutive events
-- A positive delta means the customer increased spending
-- A NULL previous value indicates the first purchase
SELECT
  c.name AS customer_name,
  o.order_date,
  o.quantity * p.price AS order_value,
  LAG(o.quantity * p.price) OVER (
    PARTITION BY c.customer_id
    ORDER BY o.order_date
  ) AS previous_order_value,
  (o.quantity * p.price) -
  LAG(o.quantity * p.price) OVER (
    PARTITION BY c.customer_id
    ORDER BY o.order_date
  ) AS order_delta
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;


-- Classify each order as first or repeat purchase
-- LAG returns NULL when there is no previous order for the customer
-- This is commonly used in lifecycle and churn analysis
SELECT
  c.name,
  o.order_date,
  o.quantity * p.price AS order_value,
  CASE
    WHEN LAG(o.order_date) OVER (
      PARTITION BY c.customer_id
      ORDER BY o.order_date
    ) IS NULL
    THEN 'first_purchase'
    ELSE 'repeat_purchase'
  END AS purchase_type
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;


-- Calculate the number of days between consecutive orders per customer
-- Useful to understand purchase frequency and customer engagement
SELECT
  c.name,
  o.order_date,
  o.order_date -
  LAG(o.order_date) OVER (
    PARTITION BY c.customer_id
    ORDER BY o.order_date
  ) AS days_since_last_order
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;



/* ============================================================
   WINDOW FUNCTIONS — CUMULATIVE METRICS
   ============================================================ */

-- Calculate cumulative spend per customer over time
-- Keeps row-level detail while building a running total
-- Preferred over subqueries or self-joins for analytical workloads
SELECT
  c.name,
  o.order_date,
  o.quantity * p.price AS order_value,
  SUM(o.quantity * p.price) OVER (
    PARTITION BY c.customer_id
    ORDER BY o.order_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;
