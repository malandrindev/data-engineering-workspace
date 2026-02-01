-- =========================================================
-- Performance Analysis — Baseline aggregation with join
-- =========================================================
-- Context:
-- Analytical aggregation over orders joined with products to compute
-- monetary values. The dataset is intentionally small, but the access
-- pattern reflects a typical fact-dimension join.
--
-- Planner behavior:
-- Most rows are processed, which explains the use of sequential scans
-- and a hash join. Index usage would not reduce I/O in this case.
--
-- Notes:
-- This query serves as a baseline for later comparisons when introducing
-- selective predicates and index-based access paths.
-- =========================================================

EXPLAIN ANALYZE
SELECT
    SUM(o.quantity * p.price) AS total_amount
FROM orders o
JOIN products p
    ON o.product_id = p.product_id;


-- =========================================================
-- Performance Analysis — Selective date filter without index
-- =========================================================
-- Context:
-- Analytical aggregation with a highly selective date predicate.
-- Only a small subset of rows is expected to match.
--
-- Planner behavior:
-- Despite the selective filter, the planner may still choose a
-- sequential scan due to the small table size and low absolute cost.
--
-- Notes:
-- Selectivity alone does not justify index creation. Table size
-- and query frequency must also be considered.
-- =========================================================

EXPLAIN ANALYZE
SELECT
    SUM(o.quantity * p.price) AS total_amount
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
WHERE o.order_date = DATE '2025-01-10';


-- =========================================================
-- Performance Analysis — Selective date filter with index
-- =========================================================
-- Context:
-- Same analytical query with a selective date predicate,
-- now supported by an index on orders(order_date).
--
-- Planner behavior:
-- With a selective predicate, the planner reduces the number of rows early
-- and switches to a Nested Loop join, using index lookups on the dimension
-- table. Index usage on the fact table may still be avoided in small datasets.
--
-- Notes:
-- Index usefulness depends not only on selectivity, but also on
-- table size, data distribution, and query frequency.
-- =========================================================

EXPLAIN ANALYZE
SELECT
    SUM(o.quantity * p.price) AS total_amount
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
WHERE o.order_date = DATE '2025-01-10';


-- =========================================================
-- Performance Analysis — Index on join key with low selectivity
-- =========================================================
-- Context:
-- Aggregation grouped by product, requiring most rows from the orders table.
-- An index on the join key is often considered for join operations.
--
-- Planner behavior:
-- Due to low selectivity and high row coverage, the planner may ignore
-- the index or choose a bitmap/seq scan instead.
--
-- Notes:
-- Indexes on join keys do not automatically improve analytical queries.
-- Full scans are often cheaper when most rows are required.
-- =========================================================

EXPLAIN ANALYZE
SELECT
    p.name,
    SUM(o.quantity * p.price) AS total_amount
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.name;


-- =========================================================
-- Performance Analysis — Index on low-cardinality column
-- =========================================================
-- Context:
-- Aggregation on a low-cardinality column (status),
-- where most rows share the same values.
--
-- Planner behavior:
-- Despite the presence of an index, the planner prefers
-- a sequential scan due to low selectivity and full row coverage.
--
-- Notes:
-- Indexes on low-cardinality columns are rarely beneficial
-- for analytical aggregations and may add unnecessary overhead.
-- =========================================================

EXPLAIN ANALYZE
SELECT
    status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY status;
