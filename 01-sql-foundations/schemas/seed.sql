INSERT INTO customers (name, email) VALUES
('Pedro', 'pedro@email.com'),
('Lucia', 'lucia@email.com'),
('Jessica', 'jessica@email.com');

INSERT INTO products (name, price) VALUES
('Notebook', 3500.00),
('Mouse', 120.00),
('Keyboard', 250.00);

INSERT INTO orders (customer_id, product_id, quantity, order_date) VALUES
-- Pedro
(1, 1, 1, '2025-01-10'),
(1, 2, 2, '2025-01-11'),
(1, 3, 1, '2025-01-20'),

-- Lucia
(2, 3, 1, '2025-01-12'),
(2, 2, 1, '2025-01-18'),

-- Jessica
(3, 2, 5, '2025-01-15'),
(3, 2, 5, '2025-01-22');
