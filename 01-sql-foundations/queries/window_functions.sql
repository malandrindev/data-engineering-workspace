/* ============================================================
   WINDOW FUNCTIONS — AGGREGATION WITHOUT COLLAPSING ROWS
   ============================================================ */

-- Aggregate metrics at the customer level while preserving row-level detail
-- Common pattern for analytical queries where granularity must be retained
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

-- Generate an ordered sequence of events per customer
-- Useful for lifecycle analysis and event-based processing
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
-- Applied after aggregation to avoid row multiplication
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


-- Dense ranking variant for top-N style analytics
-- Preserves continuous ranking when ties exist
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

-- Compare each event with the previous one in the sequence
-- Avoids self-joins while enabling temporal analysis
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


-- Forward-looking comparison using LEAD
-- Commonly used for churn and behavior modeling
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


-- Calculate delta between consecutive events
-- Enables trend detection across a customer timeline
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


-- Classify events based on purchase recurrence
-- NULL from LAG indicates the first observed event
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


-- Measure time gaps between consecutive events
-- Useful for frequency and engagement analysis
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

-- Compute running totals using an explicit window frame
-- Preferred for cumulative metrics in analytical workloads
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
