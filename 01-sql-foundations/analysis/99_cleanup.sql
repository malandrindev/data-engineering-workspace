-- Remove experimental indexes used only for performance analysis.
-- In production environments, such cleanup is mandatory.

DROP INDEX IF EXISTS idx_orders_status;
DROP INDEX IF EXISTS idx_orders_product_id;
