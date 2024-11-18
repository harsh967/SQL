create DATABASE Exam;
use exam;
-- create department table 
CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(255) NOT NULL
);
-- create employee table
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);
-- create Account Table
CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    balance DECIMAL(10, 2) NOT NULL CHECK (balance >= 0)
);
-- create Product Table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    price DECIMAL(10 , 2 ) NOT NULL CHECK (price >= 0),
    quantity INT NOT NULL CHECK (quantity >= 0)
);
-- create Order Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    order_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
-- insert data into following tables department ,employee,account,product,orders.
INSERT INTO Departments (department_id, department_name) VALUES -- insert 1
(1, 'Sales'),
(2, 'Marketing'),
(3, 'Finance'),
(4, 'HR');
INSERT INTO Employees (employee_id, first_name, last_name, department_id) VALUES -- insert 2
(1, 'Rahul', 'Gupta', 1),
(2, 'Sunil', 'Kumar', 2),
(3, 'Ravi', 'Payal', 3),
(4, 'Sonia', 'Singh', 4);

INSERT INTO Accounts (account_id, account_number, balance) VALUES -- insert 3
(1, 'ACC123456789', 5000.00),
(2, 'ACC987654321', 8000.00),
(3, 'ACC111222333', 3000.00);

INSERT INTO Products (product_id, product_name, category, price, quantity) VALUES -- insert 4
(1, 'Laptop', 'Electronics', 1200.00, 10),
(2, 'Smartphone', 'Electronics', 800.00, 15),
(3, 'Chair', 'Furniture', 100.00, 20),
(4, 'Desk', 'Furniture', 250.00, 5);

INSERT INTO Orders (order_id, product_id, quantity, order_date) VALUES -- insert 5
(1, 1, 2, '2024-04-10'),
(2, 2, 1, '2024-04-15'),
(3, 3, 4, '2024-04-20'),
(4, 4, 1, '2024-04-22');


#Transfer Funds Between Accounts
DELIMITER //

CREATE PROCEDURE TransferFunds(
    IN source_account INT,
    IN destination_account INT,
    IN amount DECIMAL(10, 2)
)
BEGIN
    DECLARE insufficient_funds CONDITION FOR SQLSTATE '45000';

    START TRANSACTION;

    -- Deduct from source account
    UPDATE Accounts
    SET balance = balance - amount
    WHERE account_id = source_account;

    -- Check if the source account has enough balance
    IF (SELECT balance FROM Accounts WHERE account_id = source_account) < 0 THEN
        SIGNAL insufficient_funds SET MESSAGE_TEXT = 'Insufficient funds in source account';
    END IF;

    -- Add to destination account
    UPDATE Accounts
    SET balance = balance + amount
    WHERE account_id = destination_account;

    COMMIT;
END //

DELIMITER ;

#Retrieve Employees with Department Names
DELIMITER //

CREATE PROCEDURE GetEmployeesByDepartment(
    IN dep_id INT
)
BEGIN
    SELECT e.employee_id, e.first_name, e.last_name, d.department_name
    FROM Employees e
    INNER JOIN Departments d ON e.department_id = d.department_id
    WHERE e.department_id = dep_id;
END //

DELIMITER ;

#Insert a New Order
DELIMITER //

CREATE PROCEDURE InsertOrder(
    IN product_id INT,
    IN quantity INT,
    IN order_date DATE
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Handle the error and rollback
        ROLLBACK;
        SELECT 'Error occurred while inserting the order';
    END;

    START TRANSACTION;

    -- Insert the order
    INSERT INTO Orders (product_id, quantity, order_date)
    VALUES (product_id, quantity, order_date);

    COMMIT;
    SELECT 'Order inserted successfully';
END //

DELIMITER ;

