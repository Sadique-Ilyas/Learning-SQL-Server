-- Lesson 2: ORDER BY inside OVER() - ranking functions
-- Run each query on its own: select it, then press Ctrl+Shift+E

USE EmployeesDB;

-- Query A: ROW_NUMBER gives every row a unique number, in the order you choose.
SELECT Name, Salary,
       ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNum
FROM Employees;

-- Query B: The three ranking functions side by side. Look at the tied salaries.
SELECT Name, Salary,
       ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNum,    -- 1,2,3,4,5  never ties
       RANK()       OVER (ORDER BY Salary DESC) AS Rnk,       -- 1,1,3,3,5  ties share, then skip
       DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRnk   -- 1,1,2,2,3  ties share, no skip
FROM Employees;

-- Query C: ORDER BY inside OVER only controls the numbering.
--          The ORDER BY at the end controls how the rows are displayed.
SELECT Name, Salary,
       ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNum
FROM Employees
ORDER BY Name;          -- rows sorted by name, but RowNum still follows salary

-- Query D: Ties make ROW_NUMBER unpredictable (Hana or Kevin could be 1).
--          Add a tie-breaker column so the result is always the same.
SELECT Name, Salary,
       ROW_NUMBER() OVER (ORDER BY Salary DESC, Name ASC) AS RowNum
FROM Employees;

-- Query E: Ranking functions REQUIRE ORDER BY in OVER(). This fails:
-- SELECT Name, ROW_NUMBER() OVER () AS RowNum FROM Employees;

-- Exercise 1: rank employees from LOWEST to highest salary,
--             so tied salaries share a rank and no numbers are skipped.
SELECT Name, Salary,
       DENSE_RANK() OVER (ORDER BY Salary) AS Rank
FROM Employees;
-- Exercise 2: find the employee(s) with the 2nd highest salary.
--             Hint: use a CTE and filter on the rank.
WITH SortedSalary AS (
    SELECT Name, Salary,
    DENSE_RANK() OVER(ORDER BY Salary DESC) AS SalaryRank
    FROM Employees
)

SELECT * FROM SortedSalary
WHERE SalaryRank = 2