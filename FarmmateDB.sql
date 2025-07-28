CREATE DATABASE farm_app;
USE farm_app;
CREATE TABLE farmers (
    farmer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100)
);
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    farmer_id INT,
    FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id)
);
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100)
);
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    delivery_time TIME,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    state VARCHAR(100),
    pincode VARCHAR(10),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
INSERT INTO farmers (name, phone, email) 
VALUES ('Ramesh Kumar', '9876543210', 'ramesh@farm.com');
INSERT INTO products (name, price, farmer_id)
VALUES ('Tomatoes', 20.00, 1);
INSERT INTO customers (name, phone, email)
VALUES ('Anita Sharma', '9123456780', 'anita@gmail.com');
INSERT INTO orders (customer_id, order_date, total_amount, payment_method, delivery_time)
VALUES (1, NOW(), 100.00, 'UPI', '08:00:00');
INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES (1, 1, 5, 20.00);
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT 
    o.order_id,
    c.name AS customer_name,
    p.name AS product_name,
    oi.quantity,
    oi.price,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;
SELECT 
    p.name AS product,
    SUM(oi.quantity) AS quantity_sold
FROM 
    order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE 
    DATE(o.order_date) = CURDATE()
GROUP BY 
    p.name;
-- View orders
SELECT * FROM Orders;

-- View ordered items
SELECT * FROM Order_Items;
consumers