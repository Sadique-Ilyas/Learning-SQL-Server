USE SqlPractice;

/* 1.1
CREATE TABLE Project (
    ProjectId   INT             IDENTITY (1, 1) PRIMARY KEY,
    ProjectName NVARCHAR (100)  NOT NULL UNIQUE,
    DeptId      INT            ,
    Budget      DECIMAL (12, 2) CHECK (Budget >= 0),
    StartDate   DATE            DEFAULT GETDATE(),
    Status      NVARCHAR (20)   DEFAULT 'Active' CONSTRAINT FK_ProjectDepartment FOREIGN KEY (DeptId) REFERENCES Department (Id)
);
*/

/* 1.2
CREATE TABLE EmployeeProject (
    EmployeeId   INT             ,
    CONSTRAINT FK_ProjectEmployeeId FOREIGN KEY (EmployeeId) REFERENCES Employee (Id),
    ProjectId INT,
    CONSTRAINT FK_EMployeeProjectId FOREIGN KEY (ProjectId) REFERENCES Project (ProjectId),
    HoursPerWeek INT CHECK (HoursPerWeek BETWEEN 1 AND 40)
);


ALTER TABLE EmployeeProject ALTER COLUMN EmployeeId INT NOT NULL;
ALTER TABLE EmployeeProject ALTER COLUMN ProjectId  INT NOT NULL;
GO
ALTER TABLE EmployeeProject
    ADD CONSTRAINT PK_EmployeeProject PRIMARY KEY (EmployeeId, ProjectId);
*/

/* 1.3
INSERT INTO Project(ProjectName, DeptId, Budget) VALUES
('Website Revamp', 1, 50000),
('Payroll System', 1, 120000),
('Hiring Drive', 2, 15000),
('Q4 Campaign', 3, 30000);


INSERT INTO EmployeeProject VALUES
(1, 11, 20),
(2, 11, 25),
(1, 12, 30),
(6, 13, 35),
(4, 14, 37),
(5, 14, 39);
*/

/* 1.4
INSERT INTO Project(ProjectName, DeptId, Budget) VALUES
('Website Revamp', 1, 50000);

ERROR: Violation of UNIQUE KEY constraint 'UQ__Project__BCBE781C59EADF3D'. Cannot insert duplicate key in object 'dbo.Project'. The duplicate key value is (Website Revamp).

INSERT INTO Project(ProjectName, DeptId, Budget) VALUES
('Website Revamp2', 1, -100);

ERROR: The INSERT statement conflicted with the CHECK constraint "CK__Project__Budget__3C69FB99". The conflict occurred in database "SqlPractice", table "dbo.Project", column 'Budget'.

INSERT INTO Project(ProjectName, DeptId, Budget) VALUES
('Website Revamp2', 99, 100);

ERROR: The INSERT statement conflicted with the FOREIGN KEY constraint "FK_ProjectDepartment". The conflict occurred in database "SqlPractice", table "dbo.Department", column 'Id'.

INSERT INTO EmployeeProject VALUES
(1, 11, 20);

ERROR: Violation of PRIMARY KEY constraint 'PK_EmployeeProject'. Cannot insert duplicate key in object 'dbo.EmployeeProject'. The duplicate key value is (1, 11).

INSERT INTO EmployeeProject VALUES
(1, 13, 50)

ERROR: The INSERT statement conflicted with the CHECK constraint "CK__EmployeeP__Hours__4316F928". The conflict occurred in database "SqlPractice", table "dbo.EmployeeProject", column 'HoursPerWeek'.
*/

/*1.5
UPDATE Project SET Budget = Budget + 0.15 * Budget WHERE DeptId = 1;

UPDATE Project SET [Status] = 'Completed' WHERE ProjectName = 'Hiring Drive';

UPDATE Employee SET Salary = Salary + 0.05 * Salary
WHERE Id IN (
    SELECT EmployeeId FROM EmployeeProject
    GROUP BY EmployeeId
    HAVING COUNT(EmployeeId) > 1
);
*/

/*1.6
DELETE FROM EmployeeProject
WHERE EmployeeId = 5 AND ProjectId = 14;

BEGIN TRANSACTION
DELETE FROM EmployeeProject
WHERE ProjectId = 14;
DELETE FROM Project
WHERE ProjectId = 14;

COMMIT;

SELECT * INTO ProjectArchive FROM Project WHERE [Status] = 'Completed'

*/
-- BEGIN TRANSACTION
-- DECLARE @Id INT;
-- SELECT @Id = ProjectId FROM Project WHERE [Status] = 'Completed'
-- DELETE FROM EmployeeProject
-- WHERE ProjectId = @Id;
-- DELETE FROM Project
-- WHERE ProjectId = @Id;

-- COMMIT;

-- 1.7
-- ALTER TABLE Project ADD EndDate DATE NULL;

-- BEGIN TRANSACTION
-- UPDATE Project SET EndDate = DATEADD(MONTH, 6, StartDate)
-- WHERE [Status] = 'Active';

-- COMMIT;

-- 2.1
-- GO
-- CREATE VIEW vEmployeeProjects AS
--     SELECT e.Name, d.DeptName, p.ProjectName, ep.HoursPerWeek FROM Employee AS e
--     LEFT JOIN Department AS d
--     ON e.DeptId = d.Id
--     LEFT JOIN EmployeeProject AS ep
--     ON e.Id = ep.EmployeeId
--     LEFT JOIN Project AS p
--     ON ep.ProjectId = p.ProjectId;
-- GO

-- SELECT * FROM vEmployeeProjects;

-- 2.2
-- GO
-- CREATE VIEW vDepartmentSummary AS
--     WITH
--     cteEmployee AS (
--         SELECT
--             d.Id AS DeptId,
--             d.DeptName AS DeptName,
--             COUNT(e.Id) AS EmpCount,
--             ISNULL(SUM(e.Salary), 0) AS TotalSalary
--         FROM Department AS d
--         LEFT JOIN Employee as e
--         ON d.Id = e.DeptId
--         GROUP BY d.Id, d.DeptName
--     ),
--     cteProject AS (
--         SELECT
--             d.Id AS DeptId,
--             d.DeptName AS DeptName,
--             COUNT(p.ProjectId) AS ProjectCount,
--             SUM(p.Budget) AS TotalBudget
--         FROM Department AS d
--         LEFT JOIN Project as p
--         ON d.Id = p.DeptId
--         GROUP BY d.Id, d.DeptName
--     )
--     SELECT
--         ce.DeptName AS DeptName,
--         ce.EmpCount AS EmpCount,
--         ce.TotalSalary AS TotalSalary,
--         cp.ProjectCount AS ProjectCount,
--         ISNULL(cp.TotalBudget, 0) AS TotalBudget
--     FROM cteEmployee AS ce
--     JOIN cteProject as cp
--     ON ce.DeptId = cp.DeptId;
--     GO
-- SELECT * FROM vDepartmentSummary;

-- 2.3
-- SELECT * FROM vEmployeeProjects
-- WHERE HoursPerWeek > 20;

-- BEGIN TRANSACTION;
-- UPDATE vEmployeeProjects SET HoursPerWeek = 30 WHERE Name = 'Bob';
-- SELECT * FROM EmployeeProject;   -- did the base table change? Yes it changed
-- ROLLBACK;

-- UPDATE vDepartmentSummary SET EmpCount = 5 WHERE DeptName = 'IT';

-- ERROR: Update or insert of view or function 'vDepartmentSummary' failed because it contains a derived or constant field.
-- EmpCount is result of aggregate function, not a actual column in the table

-- 2.4
-- GO
-- CREATE PROCEDURE uspGetEmployeesByDept
--     @DeptName NVARCHAR(50)
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     SELECT  e.Name, e.Salary, e.City FROM Employee AS e
--     JOIN Department AS d
--     ON e.DeptId = d.Id
--     WHERE d.DeptName = @DeptName
--     ORDER BY e.Salary DESC
-- END;
-- GO
-- EXEC uspGetEmployeesByDept @DeptName = 'IT';
-- EXEC uspGetEmployeesByDept @DeptName = 'Legal';

-- 2.5
-- GO
-- CREATE OR ALTER PROCEDURE uspAddProject
--     @ProjectName NVARCHAR(100),
--     @DeptName NVARCHAR(50),
--     @Budget DECIMAL(12,2),
--     @NewProjectId INT OUTPUT
-- AS
-- BEGIN
--     DECLARE @DeptId INT;
--     SELECT @DeptId = Id FROM Department WHERE DeptName = @DeptName;
--     IF @DeptId IS NULL
--         THROW 50001, 'Department not found', 1;

--     IF EXISTS (SELECT 1 FROM Project WHERE ProjectName = @ProjectName)
--         THROW 50002, 'Project already exists', 1;
    
--     INSERT INTO Project(ProjectName, DeptId, Budget) VALUES
--     (@ProjectName, @DeptId, @Budget)

--     SET @NewProjectId = SCOPE_IDENTITY()
-- END;
-- GO

-- DECLARE @Id INT;
-- EXEC uspAddProject 
--     @ProjectName = 'Data Warehouse',
--     @DeptName = 'IT',
--     @Budget = 80000,
--     @NewProjectId = @Id OUTPUT;

-- SELECT @Id AS NewProjectId;     -- expect 19 (identity gaps from 1.4)

-- EXEC uspAddProject 'X', 'Marketing', 100, @Id OUTPUT;            -- error 50001
-- EXEC uspAddProject 'Data Warehouse', 'IT', 100, @Id OUTPUT;      -- error 50002

-- DECLARE @Id INT;
-- EXEC uspAddProject 'Mobile App', 'Sales', 40000, @Id OUTPUT;
-- SELECT @Id AS NewProjectId;   -- expect 20
-- SELECT * FROM Project;        -- Mobile App, DeptId 3, 40000

-- 3.4

-- SET XACT_ABORT OFF;

-- BEGIN TRY
--     BEGIN TRANSACTION;
--         UPDATE Employee SET Name = 'Alice2' WHERE Id = 1;
--         INSERT INTO Project (ProjectName, Budget) VALUES ('Bad', -5);   -- fails the CHECK
--     COMMIT;
-- END TRY
-- BEGIN CATCH
--     IF @@TRANCOUNT > 0 ROLLBACK;   -- undo everything
--     THROW;                          -- pass the error on to the caller
-- END CATCH

-- SELECT @@TRANCOUNT;

-- 1. Alice name is changed to Alice2
-- 2. UPDATE Employee SET Name = 'Alice' WHERE Id = 1
-- 3. Alice didnt update to Alice2. @@TRANCOUNT was 0.
-- 4. Alice didnt update to Alice2. @@TRANCOUNT was 0.

-- 3.3
-- GO
-- CREATE OR ALTER PROCEDURE uspTransferBudget @FromProjectId INT, @ToProjectId INT, @Amount DECIMAL(12,2) AS
-- BEGIN
--     SET NOCOUNT ON;
--     SET XACT_ABORT ON;
    
--     BEGIN TRANSACTION
--         UPDATE Project SET Budget = Budget - @Amount
--         WHERE ProjectId = @FromProjectId;

--         IF @@ROWCOUNT = 0
--             THROW 50010, 'Source project not found', 1;

--         UPDATE Project SET Budget = Budget + @Amount
--         WHERE ProjectId = @ToProjectId;

--         IF @@ROWCOUNT = 0
--             THROW 50020, 'Target project not found', 1;
--     COMMIT
-- END
-- GO
--EXEC uspTransferBudget 14, 11, 7500;     -- works: 11 = 27,500 and 14 = 60,000
--EXEC uspTransferBudget 11, 14, 999999;   -- fails: both budgets unchanged
--EXEC uspTransferBudget 11, 999, 100;     -- fails: 11 must NOT lose 100
-- SELECT ProjectId, Budget FROM Project;

--3.5
-- GO
-- CREATE OR ALTER PROCEDURE uspOnboardEmployee @Id INT, @Name NVARCHAR(50), @Salary INT, @DeptId INT, @ProjectName NVARCHAR(100), @HoursPerWeek INT AS
-- BEGIN
--     SET NOCOUNT ON;
--     SET XACT_ABORT ON;

--     BEGIN TRANSACTION
--         DECLARE @PID INT;
--         SELECT @PID = ProjectId FROM Project
--         WHERE ProjectName = @ProjectName;

--         IF @PID IS NULL
--             THROW 50030, 'Project not found', 1;

--         INSERT INTO Employee(Id, Name, Salary, DeptId) VALUES
--         (@Id, @Name, @Salary, @DeptId);

--         INSERT INTO EmployeeProject(EmployeeId, ProjectId, HoursPerWeek) VALUES
--         (@Id, @PID, @HoursPerWeek);

--     COMMIT
-- END
-- GO
-- --EXEC uspOnboardEmployee 8, 'Hannah', 70000, 1, 'Data Warehouse', 20;   -- works
-- EXEC uspOnboardEmployee 9, 'Ivan',   65000, 2, 'Nonexistent', 10;      -- fails
-- SELECT * FROM Employee WHERE Id IN (8, 9);   -- only Hannah
-- SELECT * FROM EmployeeProject WHERE EmployeeId IN (8, 9);


--Part A: user-defined functions
--F1:
-- GO
-- CREATE OR ALTER FUNCTION dbo.fnSalaryBand(@Salary INT)
-- RETURNS NVARCHAR(10) AS
-- BEGIN

--     IF @Salary IS NULL RETURN 'Unknown'
--     IF @Salary >= 90000 RETURN 'High'
--     IF @Salary >= 70000 RETURN 'Medium'
    
--     RETURN 'Low'
-- END
-- GO
-- SELECT Name, Salary, dbo.fnSalaryBand(Salary) AS Band FROM Employee;

--F2:
-- GO
-- CREATE OR ALTER FUNCTION dbo.fnProjectTeam(@ProjectId INT)
-- RETURNS TABLE AS
-- RETURN(
--     SELECT e.Name, ep.HoursPerWeek FROM Employee AS e
--     INNER JOIN EmployeeProject as ep
--     ON e.Id = ep.EmployeeId
--     WHERE ep.ProjectId = @ProjectId
-- );
-- GO

-- SELECT * FROM dbo.fnProjectTeam(11);

--F3:
-- OUTER APPLY keeps projects with no team (Mobile App shows NULL); CROSS APPLY would drop them.
-- SELECT * FROM Project as p OUTER APPLY dbo.fnProjectTeam(p.ProjectId)

--F4:
-- GO
-- CREATE OR ALTER FUNCTION dbo.fnUpdateEmpSalary(@EmpId INT)
-- RETURNS INT AS
-- BEGIN
--     UPDATE Employee SET Salary = Salary + 1000
--     WHERE Id = @EmpId

--     RETURN 0;
-- END
-- GO

-- ERROR: Msg 443, Level 16, State 15, Procedure fnUpdateEmpSalary, Line 4 [Batch Start Line 356]
-- Invalid use of a side-effecting operator 'UPDATE' within a function.

--Part B
-- SELECT TOP (200000)
--     IDENTITY(INT, 1, 1)                                          AS OrderId,
--     ABS(CHECKSUM(NEWID())) % 1000                                AS CustomerId,
--     DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 1000), '2026-01-01') AS OrderDate,
--     ABS(CHECKSUM(NEWID())) % 10000                               AS Amount
-- INTO Orders
-- FROM sys.all_columns a CROSS JOIN sys.all_columns b;

SET STATISTICS IO ON;

-- I1
SELECT * FROM Orders WHERE CustomerId = 42; -- Before adding idx_Orders_CustomerId, logical reads 717. After adding idx_Orders_CustomerId, logical reads 181.

-- I2
-- CREATE NONCLUSTERED INDEX idx_Orders_CustomerId ON Orders(CustomerId);

-- I3
-- SELECT CustomerId, Amount FROM Orders WHERE CustomerId = 42; --  Before adding idx_Orders_CustomerId_Amount, logical reads 181. After adding idx_Orders_CustomerId_Amount, logical reads 4.

-- CREATE NONCLUSTERED INDEX idx_Orders_CustomerId_Amount ON Orders(CustomerId) INCLUDE(Amount);
-- I4
-- ALTER TABLE Orders ADD CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (OrderId);

-- SELECT * FROM Orders
-- WHERE OrderId = 5000 -- logical reads 3
-- WHERE OrderId BETWEEN 5000 AND 5100 -- logical reads 4

-- I5
-- CREATE NONCLUSTERED INDEX idx_Orders_OrderDate ON Orders(OrderDate);

-- SELECT COUNT(*) FROM Orders WHERE YEAR(OrderDate) = 2025; -- logical reads 454

-- SELECT COUNT(*) FROM Orders WHERE OrderDate BETWEEN '2025-01-01' AND '2025-12-31'; -- logical reads 170

-- I6
-- SELECT name, type_desc FROM sys.indexes WHERE object_id = OBJECT_ID('Orders');

-- I3 index makes I2 index unnecessary because I2 adds index only on CustomerID, but I2 adds index on both CustomerID and Amount. That's why it makes I2 index redundant

-- DROP INDEX idx_Orders_CustomerId ON Orders;