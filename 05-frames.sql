-- Lesson 5: Frames - ROWS BETWEEN <start> AND <end>
-- Run each query on its own: select it, then press Ctrl+Shift+E
--
-- Frame boundaries:
--   UNBOUNDED PRECEDING   first row of the partition
--   n PRECEDING           n rows before the current row
--   CURRENT ROW           the current row
--   n FOLLOWING           n rows after the current row
--   UNBOUNDED FOLLOWING   last row of the partition

USE EmployeesDB;

-- Query A: the same SUM with different frames, side by side.
SELECT Id, Name, Salary,
       SUM(Salary) OVER (ORDER BY Id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)         AS RunningTotal,
       SUM(Salary) OVER (ORDER BY Id ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)                 AS PrevPlusCurrent,
       SUM(Salary) OVER (ORDER BY Id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)                 AS PrevCurrentNext,
       SUM(Salary) OVER (ORDER BY Id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)         AS RemainingTotal,
       SUM(Salary) OVER (ORDER BY Id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS GrandTotal
FROM Employees
ORDER BY Id;

-- Query B: 3-row moving average (this row + the 2 before it).
--          The first two rows average fewer rows, because there's nothing before them.
SELECT Id, Name, Salary,
       AVG(Salary) OVER (ORDER BY Id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg3,
       COUNT(*)    OVER (ORDER BY Id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS RowsInFrame
FROM Employees
ORDER BY Id;

-- Query C: frames restart in each partition, just like the calculation does.
SELECT Name, Department, Salary,
       AVG(Salary) OVER (PARTITION BY Department ORDER BY Salary DESC, Id
                         ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS NeighbourAvg
FROM Employees
ORDER BY Department, Salary DESC, Id;

-- Query D: a frame that EXCLUDES the current row: the highest salary before this one.
--          The first row has nothing before it, so it gets NULL.
SELECT Id, Name, Salary,
       MAX(Salary) OVER (ORDER BY Id ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS HighestBefore
FROM Employees
ORDER BY Id;

-- Exercise 1: in Id order, show each employee's salary plus the total of
--             their salary and the NEXT 2 employees' salaries.

-- Exercise 2: within each department, ordered by Id, show the
--             average salary of all the employees who come AFTER the current one.
