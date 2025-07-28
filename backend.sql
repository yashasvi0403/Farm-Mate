-- Drop existing database and recreate to ensure a clean setup
DROP DATABASE IF EXISTS FarmConnect;
CREATE DATABASE FarmConnect;
USE FarmConnect;

-- Farmers Table
CREATE TABLE farmers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(15) UNIQUE NOT NULL,
    password VARCHAR(100),
    city VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Consumers Table
CREATE TABLE consumers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(15) UNIQUE NOT NULL,
    password VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products Table
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id INT,
    name VARCHAR(100),
    price DECIMAL(10,2),
    description TEXT,
    image VARCHAR(255),
    stock INT NOT NULL DEFAULT 0, -- Renamed from quantity
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (farmer_id) REFERENCES farmers(id)
);

-- Cart Table (Added)
CREATE TABLE cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    consumer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (consumer_id) REFERENCES consumers(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Orders Table
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    consumer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    delivery_address TEXT,
    delivery_time_slot VARCHAR(20),
    payment_mode VARCHAR(20),
    status VARCHAR(50) DEFAULT 'Pending',
    delivery_date DATE,
    FOREIGN KEY (consumer_id) REFERENCES consumers(id)
);

-- Order Items Table
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- OTPs Table (Added)
CREATE TABLE otps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone VARCHAR(15) NOT NULL,
    otp VARCHAR(6) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL
);

-- Grant privileges to root user
SELECT * FROM mysql.user WHERE user = 'root' AND host = 'localhost';
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY 'chinnyu2005';
GRANT ALL PRIVILEGES ON FarmConnect.* TO 'root'@'localhost';
FLUSH PRIVILEGES;

-- Insert test data (updated to match new schema)
INSERT INTO consumers (name, email, phone, password) VALUES ('John Doe', 'john@example.com', '9876543210', 'password123');
INSERT INTO farmers (name, email, phone, password, city) VALUES ('Farmer Jane', 'jane@example.com', '9876543211', 'password123', 'Delhi');
INSERT INTO products (farmer_id, name, price, description, image, stock) VALUES (1, 'Apples', 50.00, 'Fresh red apples', NULL, 100);