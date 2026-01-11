INSERT INTO customers (name, email) VALUES
('Pedro', 'pedro@email.com'),
('Lucia', 'lucia@email.com'),
('Jessica', 'jessica@email.com');

INSERT INTO products (name, price) VALUES
('Notebook', 3500.00),
('Mouse', 120.00),
('Keyboard', 250.00);

INSERT INTO orders (customer_id, product_id, quantity, order_date) VALUES
(1, 1, 1, '2025-01-10'),
(1, 2, 2, '2025-01-11'),
(2, 3, 1, '2025-01-12');
