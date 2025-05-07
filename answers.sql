-- Database Design and Normalization Assignment
-- This file contains solutions for achieving 1NF and 2NF

-- =============================================
-- QUESTION 1: Achieving First Normal Form (1NF)
-- =============================================

-- Create original denormalized table (for demonstration)
CREATE TABLE IF NOT EXISTS ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

-- Insert sample data
INSERT INTO ProductDetail (OrderID, CustomerName, Products)
VALUES 
    (101, 'John Doe', 'Laptop, Mouse'),
    (102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
    (103, 'Emily Clark', 'Phone');

-- Create 1NF compliant table
CREATE TABLE IF NOT EXISTS ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(50)
);

-- Transform data into 1NF by splitting products into separate rows
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT 
    p.OrderID,
    p.CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p.Products, ',', n.n), ',', -1)) AS Product
FROM 
    ProductDetail p
JOIN 
    (
        SELECT 1 AS n UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4
    ) n
ON 
    n.n <= LENGTH(p.Products) - LENGTH(REPLACE(p.Products, ',', '')) + 1
WHERE 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p.Products, ',', n.n), ',', -1)) != '';

-- Display results
SELECT * FROM ProductDetail_1NF ORDER BY OrderID, Product;

-- ==============================================
-- QUESTION 2: Achieving Second Normal Form (2NF)
-- ==============================================

-- Create original 1NF table (for demonstration)
CREATE TABLE IF NOT EXISTS OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(50),
    Quantity INT
);

-- Insert sample data
INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity)
VALUES 
    (101, 'John Doe', 'Laptop', 2),
    (101, 'John Doe', 'Mouse', 1),
    (102, 'Jane Smith', 'Tablet', 3),
    (102, 'Jane Smith', 'Keyboard', 1),
    (102, 'Jane Smith', 'Mouse', 2),
    (103, 'Emily Clark', 'Phone', 1);

-- Create 2NF compliant tables
-- Orders table (removes partial dependency)
CREATE TABLE IF NOT EXISTS Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- OrderItems table (contains full dependencies)
CREATE TABLE IF NOT EXISTS OrderItems (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    Product VARCHAR(50),
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Transform data into 2NF
-- First insert into Orders table
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Then insert into OrderItems table
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- Display results
SELECT * FROM Orders ORDER BY OrderID;
SELECT * FROM OrderItems ORDER BY OrderID, Product;

