-- Drop existing tables if they exist
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Interactions;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS SupportTickets;
DROP TABLE IF EXISTS Feedback;

-- Create Customers Table
CREATE TABLE Customers (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    company TEXT,
    industry TEXT CHECK(industry IN ('Technology', 'Finance', 'Healthcare', 'Retail', 'Education')),
    date_added DATE NOT NULL,
    loyalty_score INTEGER DEFAULT 0 CHECK(loyalty_score >= 0) -- Ratio Data
);

-- Insert Random Customers Data (with duplicates and missing data)
WITH RECURSIVE generate_series(i) AS (
    SELECT 1 UNION ALL SELECT i + 1 FROM generate_series WHERE i < 1000
)

INSERT INTO Customers (name, email, phone, company, industry, date_added, loyalty_score)
SELECT 
    CASE WHEN i % 50 = 0 THEN 'Duplicate Customer' ELSE 'Customer ' || i END, -- Duplicate names
    'customer' || i || '@email.com', -- Ensure unique emails
    CASE WHEN i % 100 = 0 THEN NULL ELSE '123-456-' || (1000 + i) END, -- Missing phone numbers
    CASE WHEN i % 3 = 0 THEN 'Company ' || (i % 10) ELSE NULL END, -- Some customers without companies
    CASE (i % 5) WHEN 0 THEN 'Technology' WHEN 1 THEN 'Finance' WHEN 2 THEN 'Healthcare' WHEN 3 THEN 'Retail' ELSE 'Education' END, -- Nominal Data
    DATE('2020-01-01', '+' || (i % 1460) || ' days'), -- Interval Data (dates over 4 years)
    ABS(RANDOM() % 100) -- Ratio Data (loyalty score)
FROM generate_series;

-- Create Employees Table
CREATE TABLE Employees (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    role TEXT CHECK(role IN ('Sales', 'Support', 'Manager')), -- Nominal Data
    experience_level TEXT CHECK(experience_level IN ('Junior', 'Mid', 'Senior')), -- Ordinal Data
    hire_date DATE NOT NULL,
    salary REAL CHECK(salary >= 0) -- Ratio Data
);

-- Insert Random Employees Data
WITH RECURSIVE generate_series(i) AS (
    SELECT 1 UNION ALL SELECT i + 1 FROM generate_series WHERE i < 100
)
INSERT INTO Employees (name, role, experience_level, hire_date, salary)
SELECT 
    'Employee ' || i,
    CASE (i % 3) WHEN 0 THEN 'Sales' WHEN 1 THEN 'Support' ELSE 'Manager' END,
    CASE (i % 3) WHEN 0 THEN 'Junior' WHEN 1 THEN 'Mid' ELSE 'Senior' END,
    DATE('2018-01-01', '+' || (i % 1460) || ' days'), -- Interval Data (dates over 4 years)
    ROUND(ABS(RANDOM() % 80000) + 40000, 2) -- Ensuring non-negative salary
FROM generate_series;

-- Create Products Table
CREATE TABLE Products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    category TEXT CHECK(category IN ('Software', 'Hardware', 'Service')), -- Nominal Data
    price REAL NOT NULL CHECK(price >= 0), -- Ratio Data
    release_date DATE NOT NULL
);

-- Insert Random Products Data
WITH RECURSIVE generate_series(i) AS (
    SELECT 1 UNION ALL SELECT i + 1 FROM generate_series WHERE i < 50
)
INSERT INTO Products (name, category, price, release_date)
SELECT 
    'Product ' || i,
    CASE (i % 3) WHEN 0 THEN 'Software' WHEN 1 THEN 'Hardware' ELSE 'Service' END,
    ROUND(ABS(RANDOM() % 500) + 50, 2), -- Ensuring non-negative price
    DATE('2020-01-01', '+' || (i % 365) || ' days') -- Interval Data (release dates)
FROM generate_series;

-- Create Interactions Table
CREATE TABLE Interactions (
    interaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    interaction_type TEXT CHECK(interaction_type IN ('Call', 'Email', 'Meeting')), 
    interaction_date DATETIME NOT NULL,
    duration INTEGER CHECK(duration > 0), 
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id) ON DELETE CASCADE
);

-- Insert Random Interactions Data
WITH RECURSIVE generate_series(i) AS (
    SELECT 1 UNION ALL SELECT i + 1 FROM generate_series WHERE i < 2000
)
INSERT INTO Interactions (customer_id, employee_id, interaction_type, interaction_date, duration)
SELECT 
    (i % 1000) + 1, 
    (i % 100) + 1, 
    CASE (i % 3) WHEN 0 THEN 'Call' WHEN 1 THEN 'Email' ELSE 'Meeting' END,
    DATETIME('2023-01-01', '+' || (i % 365) || ' days', '+' || (i % 24) || ' hours', '+' || (i % 60) || ' minutes'),
    (i % 60) + 1 
FROM generate_series;

-- Create Sales Table
CREATE TABLE Sales (
    sale_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    sale_date DATE NOT NULL,
    quantity INTEGER CHECK(quantity > 0), 
    total_amount REAL CHECK(total_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id) ON DELETE CASCADE
);

-- Insert Random Sales Data
WITH RECURSIVE generate_series(i) AS (
    SELECT 1 UNION ALL SELECT i + 1 FROM generate_series WHERE i < 500
)
INSERT INTO Sales (customer_id, product_id, employee_id, sale_date, quantity, total_amount)
SELECT 
    (i % 1000) + 1, 
    (i % 50) + 1, 
    (i % 100) + 1, 
    DATE('2023-01-01', '+' || (i % 365) || ' days'),
    (i % 10) + 1, 
    ROUND(ABS(RANDOM() % 1000) + 50, 2) 
FROM generate_series;

-- Create SupportTickets Table
CREATE TABLE SupportTickets (
    ticket_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    issue_description TEXT NOT NULL,
    status TEXT CHECK(status IN ('Open', 'In Progress', 'Resolved')), -- Ordinal Data
    created_date DATETIME NOT NULL,
    resolved_date DATETIME,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id) ON DELETE CASCADE
);

-- Insert Random SupportTickets Data
WITH RECURSIVE generate_series(i) AS (
    SELECT 1 UNION ALL SELECT i + 1 FROM generate_series WHERE i < 300
)
INSERT INTO SupportTickets (customer_id, employee_id, issue_description, status, created_date, resolved_date)
SELECT 
    (i % 1000) + 1, 
    (i % 100) + 1, 
    'Issue ' || i,
    CASE (i % 3) WHEN 0 THEN 'Open' WHEN 1 THEN 'In Progress' ELSE 'Resolved' END,
    DATETIME('2023-01-01', '+' || (i % 365) || ' days', '+' || (i % 24) || ' hours', '+' || (i % 60) || ' minutes'),
    CASE WHEN i % 2 = 0 THEN DATETIME('2023-01-01', '+' || (i % 365 + 7) || ' days', '+' || (i % 24) || ' hours', '+' || (i % 60) || ' minutes') ELSE NULL END
FROM generate_series;

-- Create Feedback Table
CREATE TABLE Feedback (
    feedback_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    rating INTEGER CHECK(rating BETWEEN 1 AND 5), -- Ordinal Data
    comments TEXT,
    feedback_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

-- Insert Random Feedback Data
WITH RECURSIVE generate_series(i) AS (
    SELECT 1 UNION ALL SELECT i + 1 FROM generate_series WHERE i < 1000
)
INSERT INTO Feedback (customer_id, rating, comments, feedback_date)
SELECT 
    (i % 1000) + 1, 
    (i % 5) + 1, 
    CASE WHEN i % 10 = 0 THEN NULL ELSE 'Comment ' || i END, 
    DATE('2023-01-01', '+' || (i % 365) || ' days')
FROM generate_series;

-- Indexes for Optimization
CREATE INDEX idx_customers_industry ON Customers(industry);
CREATE INDEX idx_sales_customer ON Sales(customer_id);
CREATE INDEX idx_interactions_customer ON Interactions(customer_id);
CREATE INDEX idx_tickets_customer ON SupportTickets(customer_id);
CREATE INDEX idx_feedback_customer ON Feedback(customer_id);