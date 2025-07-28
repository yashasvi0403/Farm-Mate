const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const jwt = require('jsonwebtoken');

require('dotenv').config(); // Optional

// Initialize Express app
const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());

// JWT Secret (for simplicity, hardcoded; in production, use environment variables)
const JWT_SECRET = 'your_jwt_secret_key'; // Change this to a secure value

// MySQL Database Configuration
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'chinnyu2005', // Use your own MySQL password
    database: 'FarmConnect' // Already exists
});

// Connect to MySQL
db.connect((err) => {
    if (err) {
        console.error('✖ Database connection failed: ', err.message);
    } else {
        console.log('✔ Connected to the MySQL database: FarmConnect');
    }
});

// Middleware to verify JWT token
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Expected format: "Bearer <token>"

    if (!token) {
        return res.status(401).json({ error: 'Access denied. No token provided.' });
    }

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Invalid token.' });
        }
        req.user = user;
        next();
    });
};

// Route to handle admin login
app.post('/api/admin/login', (req, res) => {
    const { username, password } = req.body;

    const query = 'SELECT * FROM admins WHERE username = ? AND password = ?';
    db.query(query, [username, password], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (results.length === 0) {
            return res.status(401).json({ error: 'Invalid username or password' });
        }

        // Generate JWT token
        const user = { id: results[0].id, username: results[0].username };
        const token = jwt.sign(user, JWT_SECRET, { expiresIn: '1h' });

        res.status(200).json({ message: 'Login successful', token });
    });
});

// Route to handle order submission (unchanged from previous response)
app.post('/api/orders', (req, res) => {
    const { consumer_id, total_amount, delivery_address, delivery_time_slot, payment_mode, items } = req.body;

    db.beginTransaction((err) => {
        if (err) {
            return res.status(500).json({ error: 'Transaction failed' });
        }

        const orderQuery = `
            INSERT INTO orders (consumer_id, total_amount, delivery_address, delivery_time_slot, payment_mode)
            VALUES (?, ?, ?, ?, ?)
        `;
        db.query(orderQuery, [consumer_id, total_amount, delivery_address, delivery_time_slot, payment_mode], (err, orderResult) => {
            if (err) {
                return db.rollback(() => {
                    res.status(500).json({ error: 'Failed to create order' });
                });
            }

            const orderId = orderResult.insertId;
            const itemQuery = 'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES ?';
            const itemValues = items.map(item => [orderId, item.product_id, item.quantity, item.price]);

            db.query(itemQuery, [itemValues], (err) => {
                if (err) {
                    return db.rollback(() => {
                        res.status(500).json({ error: 'Failed to add order items' });
                    });
                }

                db.commit((err) => {
                    if (err) {
                        return db.rollback(() => {
                            res.status(500).json({ error: 'Failed to commit transaction' });
                        });
                    }
                    res.status(200).json({ message: 'Order placed successfully', orderId });
                });
            });
        });
    });
});

// Route to get sales summary (protected with authentication)
app.get('/api/sales-summary', authenticateToken, (req, res) => {
    const queries = {
        daily: `
            SELECT DATE(order_date) as period, SUM(total_amount) as total_sales
            FROM orders
            WHERE DATE(order_date) = CURDATE()
            GROUP BY DATE(order_date)
        `,
        weekly: `
            SELECT YEARWEEK(order_date) as period, SUM(total_amount) as total_sales
            FROM orders
            WHERE YEARWEEK(order_date) = YEARWEEK(CURDATE())
            GROUP BY YEARWEEK(order_date)
        `,
        monthly: `
            SELECT DATE_FORMAT(order_date, '%Y-%m') as period, SUM(total_amount) as total_sales
            FROM orders
            WHERE MONTH(order_date) = MONTH(CURDATE()) AND YEAR(order_date) = YEAR(CURDATE())
            GROUP BY DATE_FORMAT(order_date, '%Y-%m')
        `,
        yearly: `
            SELECT YEAR(order_date) as period, SUM(total_amount) as total_sales
            FROM orders
            WHERE YEAR(order_date) = YEAR(CURDATE())
            GROUP BY YEAR(order_date)
        `
    };

    const results = {};
    let completedQueries = 0;
    const totalQueries = Object.keys(queries).length;

    for (const [key, query] of Object.entries(queries)) {
        db.query(query, (err, result) => {
            if (err) {
                return res.status(500).json({ error: 'Failed to fetch sales data' });
            }
            results[key] = result[0] ? result[0].total_sales : 0;
            completedQueries++;

            if (completedQueries === totalQueries) {
                res.status(200).json(results);
            }
        });
    }
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});