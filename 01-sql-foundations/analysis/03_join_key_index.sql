-- Create an index on a join key to demonstrate cases where
-- index usage does not improve analytical workloads.

CREATE INDEX idx_orders_product_id
ON orders (product_id);
