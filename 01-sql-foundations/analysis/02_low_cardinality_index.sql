-- Create an index on a low-cardinality column for performance analysis.
-- This index is expected to be ignored by the planner in analytical queries.

CREATE INDEX idx_orders_status
ON orders (status);
