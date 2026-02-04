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


-- =========================================================
-- Recursive CTE — Hierarchical category expansion
-- =========================================================
-- Context:
-- Hierarchical data where depth is not fixed and relationships
-- are naturally recursive (parent-child).
--
-- Design notes:
-- Anchor defines the hierarchy root.
-- Recursive step expands the tree until no further children exist.
-- UNION ALL is required to avoid unnecessary deduplication.
-- =========================================================

WITH RECURSIVE category_tree AS (
    -- Anchor: top-level categories
    SELECT
        category_id,
        category_name,
        parent_category_id,
        1 AS level
    FROM categories
    WHERE parent_category_id IS NULL

    UNION ALL

    -- Recursive step: walk down the hierarchy
    SELECT
        c.category_id,
        c.category_name,
        c.parent_category_id,
        ct.level + 1 AS level
    FROM categories c
    JOIN category_tree ct
        ON c.parent_category_id = ct.category_id
)
SELECT *
FROM category_tree
ORDER BY level, category_name;
