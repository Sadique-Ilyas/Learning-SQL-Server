-- Lesson 4: Running totals - ORDER BY inside an aggregate's OVER()
-- Run each query on its own: select it, then press Ctrl+Shift+E

USE EmployeesDB;

-- Query A: adding ORDER BY to SUM() turns it into a running total.
--          Each row adds its salary to the total of the rows before it.
SELECT Id, Name, Salary,
       SUM(Salary) OVER (ORDER BY Id) AS RunningTotal
FROM Employees;

-- Query B: works with other aggregates too.
SELECT Id, Name, Salary,
       COUNT(*)    OVER (ORDER BY Id) AS RunningCount,
       AVG(Salary) OVER (ORDER BY Id) AS RunningAvg,
       MAX(Salary) OVER (ORDER BY Id) AS HighestSoFar
FROM Employees;

-- Query C: PARTITION BY + ORDER BY: the running total restarts per department.
SELECT Id, Name, Department, Salary,
       SUM(Salary) OVER (PARTITION BY Department ORDER BY Id) AS DeptRunningTotal
FROM Employees
ORDER BY Department, Id;

-- Query D: THE TIE TRAP. Ordering by a column with duplicates (Salary).
--          Look at Hana/Kevin, Diana/Lina, Chen/Mike, Alice/Nora:
--          tied rows get the SAME running total in the "Default" column.
--          WithRows: ties get separate totals, but which tied row comes
--                    first is NOT guaranteed (can change between runs).
--          WithTieBreaker: the lower Id always comes first (repeatable).
--          Best practice: use both -> ORDER BY Salary DESC, Id ROWS BETWEEN ...
SELECT Name, Salary,
       SUM(Salary) OVER (ORDER BY Salary DESC)                     AS [Default],
       SUM(Salary) OVER (ORDER BY Salary DESC
                         ROWS BETWEEN UNBOUNDED PRECEDING
                                  AND CURRENT ROW)                 AS WithRows,
       SUM(Salary) OVER (ORDER BY Salary DESC, Id)                 AS WithTieBreaker
FROM Employees;

-- Exercise 1: running total of salary within each department,
--             highest salary first. Make sure tied salaries don't
--             share a running total.
SELECT Name, Salary, Department,
       SUM(Salary) OVER (PARTITION BY Department ORDER BY Salary DESC, Id) AS RunningTotal
FROM Employees;
-- Exercise 2: sorted from highest salary to lowest, show each employee's
--             running total as a PERCENTAGE of the whole payroll.
--             Hint: running SUM / SUM(Salary) OVER ()
SELECT Name, Salary, Department,
       SUM(Salary) OVER (ORDER BY Salary DESC, Id) * 100/ SUM(Salary) OVER() AS RunningTotalPercentage
FROM Employees;