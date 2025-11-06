-- Drop tables if they exist
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;

-- Create orders table
CREATE TABLE orders (
                        order_id SERIAL PRIMARY KEY,
                        user_id INTEGER NOT NULL,
                        order_date DATE NOT NULL,
                        total_amount DECIMAL(10, 2) NOT NULL,
                        status VARCHAR(50) NOT NULL
);

-- Create order_items table
CREATE TABLE order_items (
                             item_id SERIAL PRIMARY KEY,
                             order_id INTEGER NOT NULL REFERENCES orders(order_id),
                             product_id INTEGER NOT NULL,
                             quantity INTEGER NOT NULL,
                             price DECIMAL(10, 2) NOT NULL
);

-- Insert sample data into orders
-- Mix of users with varying order patterns
INSERT INTO orders (user_id, order_date, total_amount, status) VALUES
                                                                   -- User 101: 4 completed orders in last 90 days (qualifies)
                                                                   (101, CURRENT_DATE - INTERVAL '10 days', 150.00, 'completed'),
                                                                   (101, CURRENT_DATE - INTERVAL '25 days', 200.00, 'completed'),
                                                                   (101, CURRENT_DATE - INTERVAL '45 days', 75.00, 'completed'),
                                                                   (101, CURRENT_DATE - INTERVAL '60 days', 300.00, 'completed'),
                                                                   (101, CURRENT_DATE - INTERVAL '100 days', 100.00, 'completed'), -- Outside 90 days
                                                                   (101, CURRENT_DATE - INTERVAL '20 days', 50.00, 'cancelled'), -- Cancelled

                                                                   -- User 102: 3 completed orders in last 90 days (qualifies)
                                                                   (102, CURRENT_DATE - INTERVAL '15 days', 400.00, 'completed'),
                                                                   (102, CURRENT_DATE - INTERVAL '30 days', 250.00, 'completed'),
                                                                   (102, CURRENT_DATE - INTERVAL '70 days', 180.00, 'completed'),

                                                                   -- User 103: Only 2 completed orders (doesn't qualify)
                                                                   (103, CURRENT_DATE - INTERVAL '5 days', 120.00, 'completed'),
                                                                   (103, CURRENT_DATE - INTERVAL '40 days', 90.00, 'completed'),

                                                                   -- User 104: 5 completed orders in last 90 days (qualifies)
                                                                   (104, CURRENT_DATE - INTERVAL '5 days', 500.00, 'completed'),
                                                                   (104, CURRENT_DATE - INTERVAL '12 days', 350.00, 'completed'),
                                                                   (104, CURRENT_DATE - INTERVAL '20 days', 275.00, 'completed'),
                                                                   (104, CURRENT_DATE - INTERVAL '50 days', 425.00, 'completed'),
                                                                   (104, CURRENT_DATE - INTERVAL '80 days', 600.00, 'completed');

-- Insert sample data into order_items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
                                                                    -- Order 1 (user 101)
                                                                    (1, 501, 2, 75.00),
                                                                    (1, 502, 1, 75.00),

                                                                    -- Order 2 (user 101)
                                                                    (2, 501, 1, 100.00),
                                                                    (2, 503, 2, 50.00),

                                                                    -- Order 3 (user 101)
                                                                    (3, 502, 1, 75.00),

                                                                    -- Order 4 (user 101)
                                                                    (4, 501, 3, 100.00),

                                                                    -- Order 5 (user 101) - outside 90 days
                                                                    (5, 504, 2, 50.00),

                                                                    -- Order 6 (user 101) - cancelled
                                                                    (6, 501, 1, 50.00),

                                                                    -- Order 7 (user 102)
                                                                    (7, 505, 4, 100.00),

                                                                    -- Order 8 (user 102)
                                                                    (8, 501, 2, 125.00),

                                                                    -- Order 9 (user 102)
                                                                    (9, 505, 3, 60.00),

                                                                    -- Order 10 (user 103)
                                                                    (10, 506, 2, 60.00),

                                                                    -- Order 11 (user 103)
                                                                    (11, 507, 1, 90.00),

                                                                    -- Orders 12-16 (user 104)
                                                                    (12, 501, 5, 100.00),
                                                                    (13, 502, 3, 116.67),
                                                                    (14, 501, 2, 137.50),
                                                                    (15, 503, 4, 106.25),
                                                                    (16, 501, 6, 100.00);

-- Verify data
SELECT 'Orders count:' as info, COUNT(*) as count FROM orders
UNION ALL
SELECT 'Order items count:', COUNT(*) FROM order_items;

