CREATE DATABASE Customers;
use Customers;
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    name TEXT,
    created_at TIMESTAMP,
    country TEXT
);

INSERT INTO users (user_id, name, created_at, country) VALUES
(1, 'Alice', '2024-08-01', 'USA'),
(2, 'Bob', '2024-08-15', 'USA'),
(3, 'Carlos', '2024-07-10', 'Canada'),
(4, 'Diana', '2024-07-25', 'UK'),
(5, 'Eva', '2024-09-05', 'Australia');

CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    amount DECIMAL,
    transaction_date TIMESTAMP,
    transaction_type TEXT
);

INSERT INTO transactions (transaction_id, user_id, amount, transaction_date, transaction_type) VALUES
(1, 1, 100.00, '2024-08-02', 'deposit'),
(2, 2, 50.00, '2024-08-16', 'withdrawal'),
(3, 3, 200.00, '2024-07-12', 'deposit'),
(4, 4, 150.00, '2024-07-26', 'deposit'),
(5, 5, 75.00, '2024-09-06', 'withdrawal');

CREATE TABLE sessions (
    session_id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    session_start TIMESTAMP,
    session_end TIMESTAMP,
    device_type TEXT
);

INSERT INTO sessions (session_id, user_id, session_start, session_end, device_type) VALUES
(1, 1, '2024-08-01 10:00', '2024-08-01 11:00', 'mobile'),
(2, 2, '2024-08-16 09:00', '2024-08-16 10:30', 'desktop'),
(3, 3, '2024-07-10 14:00', '2024-07-10 15:00', 'mobile'),
(4, 4, '2024-07-25 08:30', '2024-07-25 09:15', 'desktop'),
(5, 5, '2024-09-05 12:00', '2024-09-05 12:30', 'mobile');

## Task 1: new user transaction rate

SELECT 
    ROUND(
        (COUNT(DISTINCT t.user_id) * 100.0) / NULLIF(COUNT(DISTINCT u.user_id), 0), 2
    ) AS new_user_transaction_rate
FROM 
    users u
LEFT JOIN 
    transactions t ON u.user_id = t.user_id 
                  AND t.transaction_date BETWEEN u.created_at AND u.created_at + INTERVAL 7 DAY
WHERE 
    u.created_at >= NOW() - INTERVAL 1 MONTH;
    
SELECT 
    COUNT(DISTINCT t.user_id) AS users_with_transactions
FROM 
    users u
JOIN 
    transactions t 
    ON u.user_id = t.user_id 
    AND t.transaction_date BETWEEN u.created_at AND u.created_at + INTERVAL 7 DAY
WHERE 
    u.created_at >= NOW() - INTERVAL 1 MONTH;
    
    
### Task 2: Average Deposit Amount by Country

SELECT 
    u.country, 
    ROUND(AVG(t.amount), 2) AS average_deposit_amount
FROM 
    users u
JOIN 
    transactions t ON u.user_id = t.user_id
WHERE 
    t.transaction_type = 'deposit' 
    AND t.transaction_date >= NOW() - INTERVAL 3 MONTH
GROUP BY 
    u.country
HAVING 
    COUNT(DISTINCT u.user_id) >= 5;
    
    
SELECT 
    u.country, 
    ROUND(AVG(t.amount), 2) AS average_deposit_amount
FROM 
    users u
JOIN 
    transactions t ON u.user_id = t.user_id
WHERE 
    t.transaction_type = 'deposit' 
    AND t.transaction_date >= NOW() - INTERVAL 6 MONTH
GROUP BY 
    u.country
HAVING 
    COUNT(DISTINCT u.user_id) >= 5;
    

###  Task 3: Daily Active Users 

SELECT 
    DATE(session_start) AS date, 
    COUNT(DISTINCT user_id) AS daily_active_users
FROM 
    sessions
WHERE 
    session_start >= NOW() - INTERVAL 30 DAY
GROUP BY 
    DATE(session_start)
ORDER BY 
    date;
    
####  Task 4: Top Users by Session Duration

SELECT 
    u.user_id, 
    u.name,
    s.device_type,
    ROUND(SUM(TIMESTAMPDIFF(SECOND, s.session_start, s.session_end)) / 60, 2) AS total_session_duration
FROM 
    sessions s
JOIN 
    users u ON u.user_id = s.user_id
WHERE 
    s.session_start >= NOW() - INTERVAL 1 MONTH
GROUP BY 
    u.user_id, s.device_type
ORDER BY 
    s.device_type,
    total_session_duration DESC
LIMIT 5;


#### Task 5: Transaction Frequency by User

SELECT 
    ROUND(AVG(transaction_count), 2) AS average_transactions_per_user
FROM (
    SELECT 
        t.user_id,
        COUNT(t.transaction_id) AS transaction_count
    FROM 
        transactions t
    WHERE 
        t.transaction_date >= NOW() - INTERVAL 6 MONTH
    GROUP BY 
        t.user_id
) AS user_transactions;

#### Task 6: Transaction Frequency by User

SELECT 
    ROUND(AVG(transaction_count), 2) AS average_transactions_per_user
FROM (
    SELECT 
        t.user_id,
        COUNT(t.transaction_id) AS transaction_count
    FROM 
        transactions t
    WHERE 
        t.transaction_date >= NOW() - INTERVAL 6 MONTH
    GROUP BY 
        t.user_id
) AS user_transactions;


###  Top Spending Users by Country

SELECT 
    t.user_id, 
    u.name, 
    SUM(t.amount) AS total_amount,
    u.country
FROM 
    transactions t
JOIN 
    users u ON t.user_id = u.user_id
WHERE 
    t.transaction_type = 'deposit'
    AND t.transaction_date >= NOW() - INTERVAL 6 MONTH
GROUP BY 
    t.user_id, u.country
ORDER BY 
    u.country, total_amount DESC
LIMIT 3;

