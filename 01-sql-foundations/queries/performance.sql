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
