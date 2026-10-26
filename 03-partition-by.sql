-- Lesson 3: PARTITION BY - calculations per group
-- Run each query on its own: select it, then press Ctrl+Shift+E

USE EmployeesDB;
GO

-- Setup (run once): add a Department column and fill it in.
-- GO is needed: the column must exist before the UPDATE can use it.
IF COL_LENGTH('Employees', 'Department') IS NULL
    ALTER TABLE Employees ADD Department NVARCHAR(50) NULL;
GO

UPDATE Employees
SET Department = CASE
                     WHEN Name IN ('Hana', 'Chen', 'Mike', 'Ethan') THEN 'IT'
                     WHEN Name IN ('Diana', 'Bob', 'Ivan', 'Nora')  THEN 'HR'
                     ELSE 'Sales'
                 END;

SELECT Name, Department, Salary
FROM Employees
ORDER BY Department, Salary DESC;

-- Query A: OVER() = whole table.  OVER(PARTITION BY ...) = each department.
SELECT Name, Department, Salary,
       AVG(Salary) OVER ()                         AS CompanyAvg,
       AVG(Salary) OVER (PARTITION BY Department)  AS DeptAvg,
       COUNT(*)    OVER (PARTITION BY Department)  AS DeptHeadcount
FROM Employees;

-- Query B: compare each person with their own department's average.
SELECT Name, Department, Salary,
       Salary - AVG(Salary) OVER (PARTITION BY Department) AS DiffFromDeptAvg
FROM Employees;

-- Query C: PARTITION BY + ORDER BY: the ranking restarts at 1 in each department.
SELECT Name, Department, Salary,
       DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS RankInDept
FROM Employees;

-- Query D: top 2 salaries in each department (a very common interview question).
WITH Ranked AS (
    SELECT Name, Department, Salary,
           DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS RankInDept
    FROM Employees
)
SELECT *
FROM Ranked
WHERE RankInDept <= 2
ORDER BY Department, RankInDept;

-- Exercise 1: show each employee's salary as a percentage of
--             their DEPARTMENT's total payroll.

SELECT Name, Department, Salary,
    CAST(100.0 * Salary / SUM(Salary) OVER (PARTITION BY Department) AS DECIMAL(5, 2)) AS EmployeePercentagePerDept
FROM Employees;

-- Exercise 2: find the lowest-paid employee in each department.
WITH LowRanked AS (
    SELECT Name, Department, Salary,
           DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary) AS RankInDept
    FROM Employees
)
SELECT *
FROM LowRanked
WHERE RankInDept = 1;