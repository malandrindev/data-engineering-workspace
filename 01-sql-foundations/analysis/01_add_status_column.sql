-- Introduce a low-cardinality column to demonstrate index behavior
-- in analytical aggregations.

ALTER TABLE orders
ADD COLUMN status TEXT;

UPDATE orders
SET status = 'completed';

UPDATE orders
SET status = 'pending'
WHERE order_id IN (1, 2);
