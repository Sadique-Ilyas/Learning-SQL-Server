-- Lesson 1: What is a window function? The OVER() clause
-- Run each query on its own: select it, then press Ctrl+Shift+E

USE EmployeesDB;

-- Query A: GROUP BY collapses all rows into ONE row.
--          You get the average, but you lose the names.
SELECT AVG(Salary) AS AvgSalary
FROM Employees;

-- Query B: This FAILS. You can't mix row detail (Name) with an aggregate
--          unless you GROUP BY Name, which then averages each person alone.
-- SELECT Name, Salary, AVG(Salary) AS AvgSalary
-- FROM Employees;

-- Query C: A window function. OVER() turns AVG into a window function.
--          Every row is kept, and each row also sees the overall average.
SELECT Name,
       Salary,
       AVG(Salary) OVER () AS AvgSalary
FROM Employees;

-- Query D: Because each row sees the aggregate, you can do maths with it.
SELECT Name,
       Salary,
       AVG(Salary) OVER ()          AS AvgSalary,
       Salary - AVG(Salary) OVER () AS DiffFromAvg,
       COUNT(*)    OVER ()          AS TotalEmployees,
       MAX(Salary) OVER ()          AS HighestSalary
FROM Employees;

-- Exercise: write a query showing Name, Salary, the total payroll
-- (SUM of all salaries), and each employee's percentage of the payroll.
-- Hint: 100.0 * Salary / SUM(Salary) OVER ()
SELECT Name,
       Salary,
       SUM(Salary) OVER ()          AS TotalPayroll,
       CAST(100.0 * Salary / SUM(Salary) OVER() AS DECIMAL(4, 3)) AS EmployeesPercentage
FROM Employees;