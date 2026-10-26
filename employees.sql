USE EmployeesDB;

CREATE TABLE Employees(
    Id     INT IDENTITY(1,1) PRIMARY KEY,
    Name   NVARCHAR(100)     NOT NULL,
    Salary DECIMAL(10, 2)    NOT NULL
);

INSERT INTO Employees(Name, Salary)
VALUES ('Alice', 75000.00),
       ('Bob',   62000.50),
       ('Chen',  88000.00),
       ('Diana',  91000.00),
       ('Ethan',  54000.00),
       ('Fatima', 67500.00),
       ('George', 72000.25),
       ('Hana',   98000.00),
       ('Ivan',   59000.00),
       ('Julia',  81000.75);

-- Employees with salaries that duplicate existing ones
INSERT INTO Employees(Name, Salary)
VALUES ('Kevin', 98000.00),   -- same as Hana
       ('Lina',  91000.00),   -- same as Diana
       ('Mike',  88000.00),   -- same as Chen
       ('Nora',  75000.00);   -- same as Alice

WITH HighestSalary AS (
    SELECT
    *,
    ROW_NUMBER() OVER(ORDER BY Salary DESC) as ROW_NUMBER_Salary,
    RANK() OVER(ORDER BY Salary DESC) as RANK_Salary,
    DENSE_RANK() OVER(ORDER BY Salary DESC) as DENSE_RANK_Salary,
    PERCENT_RANK() OVER(ORDER BY Salary DESC) as PERCENT_RANK_Salary
    FROM Employees
)

SELECT * FROM HighestSalary;
