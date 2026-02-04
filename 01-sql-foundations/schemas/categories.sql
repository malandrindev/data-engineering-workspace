-- =========================================================
-- Schema — Hierarchical categories
-- =========================================================
-- Purpose:
-- Base table representing hierarchical relationships,
-- used exclusively for recursive CTE patterns.
-- =========================================================

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name TEXT,
    parent_category_id INT
);

INSERT INTO categories VALUES
(1, 'Electronics', NULL),
(2, 'Computers', 1),
(3, 'Laptops', 2),
(4, 'Desktops', 2),
(5, 'Accessories', 1),
(6, 'Keyboards', 5);
