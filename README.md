# Learning SQL Server

Hands-on T-SQL practice for Microsoft SQL Server. Each script is a lesson
or an exercise set, written and run against a local SQL Server instance.
Comments in the scripts record the results, errors and measurements from
each run.

## Contents

| File | Topic |
|---|---|
| [`employees.sql`](employees.sql) | Sample `Employees` table for the window-function lessons |
| [`01-window-basics.sql`](01-window-basics.sql) | `OVER()`: aggregates that keep every row |
| [`02-ranking.sql`](02-ranking.sql) | `ROW_NUMBER`, `RANK`, `DENSE_RANK` and tie-breakers |
| [`03-partition-by.sql`](03-partition-by.sql) | `PARTITION BY`: calculations per group, top N per group |
| [`04-running-totals.sql`](04-running-totals.sql) | Running totals, and the tie trap with `ORDER BY` |
| [`05-frames.sql`](05-frames.sql) | Window frames: `ROWS BETWEEN … AND …`, moving averages (exercises in progress) |
| [`SqlPractice.sql`](SqlPractice.sql) | Exercise sets on DDL/DML, views, procedures, transactions, functions and indexes |

## What's covered

### Window functions (`01`–`05`)
- `OVER()` adds an aggregate to every row without collapsing rows like `GROUP BY`.
- `ROW_NUMBER` never ties; `RANK` ties and skips (1, 1, 3); `DENSE_RANK` ties without skipping (1, 1, 2).
- Add a tie-breaker column (for example `ORDER BY Salary DESC, Id`) so the numbering is the same on every run.
- `PARTITION BY` restarts the calculation for each group. `DENSE_RANK` + a CTE answers "top N per group".
- `SUM(...) OVER (ORDER BY ...)` is a running total. Without a `ROWS` frame it defaults to `RANGE`, which gives tied rows the same total.
- Frames such as `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` give moving averages and look-back calculations.

### Tables and data changes (`SqlPractice.sql`, Part 1)
- `CREATE TABLE` with `IDENTITY`, `PRIMARY KEY` (including a composite key), `UNIQUE`, `CHECK`, `DEFAULT` and `FOREIGN KEY`.
- Name your constraints (`CK_Project_Budget`). Generated names make error messages hard to read.
- A failed or rolled-back insert still uses up an `IDENTITY` value, so IDs have gaps.
- An `UPDATE` or `DELETE` without a `WHERE` changes every row. Write the `WHERE` first and check the row count.
- A parent row can't be deleted while child rows reference it. Delete the children first, in one transaction.
- `SELECT ... INTO` copies data and the `IDENTITY` property, but no keys, constraints or indexes.
- `ALTER TABLE ... ADD` has no `COLUMN` keyword in T-SQL. Use `GO` before code that uses the new column.

### Views and stored procedures (Part 2)
- A view is one stored `SELECT`, with no `BEGIN … END`. Every computed column needs an alias.
- Joining two one-to-many tables multiplies rows. Aggregate each side separately (for example in CTEs), then join.
- You can update through a view only when the column maps to one column of one base table. Aggregated columns can't be updated.
- Procedures take parameters, can return `OUTPUT` values (`SCOPE_IDENTITY()`), and raise errors with `THROW`.
- Test with values different from the ones you wrote the code with. Hard-coded values pass a test that reuses them.
- Saving the `.sql` file doesn't change the database. Run `CREATE OR ALTER` again after every edit.

### Transactions (Part 3)
- `COMMIT` or `ROLLBACK` ends a transaction. There's no `END TRANSACTION`.
- By default, most errors cancel only the failing statement; the following `COMMIT` still saves the rest.
- A transaction left open holds locks and blocks other sessions (`LCK_M_S` waits). Check `@@TRANCOUNT`.
- `SET XACT_ABORT ON` rolls back the whole transaction on any error, including client timeouts. `TRY … CATCH` adds control over what happens next.
- Put `SET NOCOUNT ON` and `SET XACT_ABORT ON` **inside** each procedure, so it behaves the same for every caller.

### User-defined functions (Part A)
- Scalar functions return one value and must be called with the schema: `dbo.fnSalaryBand(...)`.
- Inline table-valued functions return a table, work like a view with parameters, and are fast.
- `CROSS APPLY` runs a table function per row like an inner join; `OUTER APPLY` keeps rows with no match.
- Functions can't change data. An `UPDATE` inside one fails with error 443.

### Indexes (Part B)
Measured with `SET STATISTICS IO ON` on a 200,000-row `Orders` table:

| Query | Index | Logical reads |
|---|---|---|
| `SELECT * … WHERE CustomerId = 42` | None (heap scan) | 717 |
| Same | Nonclustered on `CustomerId` (seek + 177 lookups) | 181 |
| `SELECT CustomerId, Amount …` | Covering: `(CustomerId) INCLUDE (Amount)` | 4 |
| `COUNT(*) … WHERE YEAR(OrderDate) = 2025` | On `OrderDate`, but not usable | 454 |
| Same, as a date range | On `OrderDate` (seek) | 170 |

- Compare **logical reads**. Physical and read-ahead reads mostly show what was already cached.
- A covering index avoids lookups, so its cost doesn't grow with the number of matching rows.
- Wrapping a column in a function (`YEAR(OrderDate)`) prevents an index seek. Use `>= start AND < end` instead, which also works for `DATETIME` values with a time of day.
- An index whose key starts with the same column makes a narrower one redundant.
- Indexes speed up reads but slow down every insert, update and delete.

## Set up a development environment

You need a SQL Server instance and a tool to run queries against it. All the
options below are free.

### 1. Install SQL Server

**Option A: Windows (native install)**

1. Download **SQL Server 2025 Developer** from the [SQL Server downloads page](https://www.microsoft.com/en-us/sql-server/sql-server-downloads). Developer edition is free for development and testing.
2. Run the installer and choose **Basic**. This installs a default instance that you connect to as `localhost` with Windows Authentication.

**Option B: Docker (Windows, macOS or Linux)**

```bash
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=<YourStrong!Passw0rd>" \
  -p 1433:1433 --name sql2025 -d mcr.microsoft.com/mssql/server:2025-latest
```

Connect to `localhost,1433` with SQL login `sa` and the password above. The
password must be at least 8 characters and include three of: uppercase,
lowercase, digits and symbols. See the
[Docker quickstart](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker)
for details.

**Option C: No install**

[db<>fiddle](https://dbfiddle.uk/) runs SQL Server in the browser. It's good
for single queries, but the multi-session exercises (blocking, open
transactions) need a real instance.

### 2. Install a query tool

Pick one:

- **VS Code + [SQL Server (mssql) extension](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql)**: run a selected query with **Ctrl+Shift+E**. It also shows execution plans.
- **[SQL Server Management Studio (SSMS) 22](https://learn.microsoft.com/en-us/ssms/install/install)** (Windows only): the full Microsoft tool. Execute with **F5**, show the actual execution plan with **Ctrl+M**.
- **`sqlcmd`** (command line), for running whole files:
  ```bash
  sqlcmd -S localhost -E -C -i employees.sql     # Windows Authentication
  sqlcmd -S localhost,1433 -U sa -C -i file.sql  # SQL login (prompts for the password)
  ```
  `-C` trusts the server's self-signed certificate, which a local install uses.

When connecting from VS Code or SSMS to a local instance, enable **Trust server certificate** for the same reason.

### 3. Create the practice databases

**For the window-function lessons (`01`–`05`):**

```sql
CREATE DATABASE EmployeesDB;
GO
```

Then run [`employees.sql`](employees.sql) to create and fill the `Employees`
table. Run `03-partition-by.sql`'s setup block once before lessons 3–5; it
adds the `Department` column.

**For `SqlPractice.sql`:**

```sql
CREATE DATABASE SqlPractice;
GO
USE SqlPractice;
GO

CREATE TABLE Department (
    Id       INT PRIMARY KEY,
    DeptName NVARCHAR(50)
);

CREATE TABLE Employee (
    Id       INT PRIMARY KEY,
    Name     NVARCHAR(50),
    Salary   INT,
    DeptId   INT,
    HireDate DATE,
    City     NVARCHAR(50)
);

INSERT INTO Department VALUES (1, 'IT'), (2, 'HR'), (3, 'Sales'), (4, 'Legal');

INSERT INTO Employee VALUES
(1, 'Alice',   90000, 1, '2019-03-15', 'Toronto'),
(2, 'Bob',     75000, 1, '2021-07-01', 'Ottawa'),
(3, 'Charlie', 60000, 2, '2018-11-20', 'Toronto'),
(4, 'Diana',   95000, 3, '2020-01-10', 'Montreal'),
(5, 'Ethan',   60000, 3, '2022-05-05', NULL),
(6, 'Fiona',   82000, 2, '2017-09-30', 'Ottawa'),
(7, 'George',  NULL,  NULL, '2023-02-14', 'Toronto');
GO
```

### 4. Run the exercises

- Run one query at a time: select it, then execute (**Ctrl+Shift+E** in VS Code, **F5** in SSMS).
- Most of `SqlPractice.sql` is commented out, so running the whole file doesn't repeat completed steps. Uncomment one exercise at a time.
- The exercises build on each other (1.1 creates `Project`, 1.3 fills it, and so on), so run them in order.
- Before Part B, run its setup block to create the 200,000-row `Orders` table, and turn on `SET STATISTICS IO ON;` to see logical reads in the Messages tab.

## Resources

### Official documentation
- [Transact-SQL reference](https://learn.microsoft.com/en-us/sql/t-sql/language-reference): every statement and function, with examples.
- [OVER clause](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql): window functions, frames and supporting indexes.
- [Index architecture and design guide](https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide): how clustered, nonclustered and covering indexes are stored and when to use them.
- [Execution plan overview](https://learn.microsoft.com/en-us/sql/relational-databases/performance/execution-plans): how the query optimizer chooses a plan.
- [SET XACT_ABORT](https://learn.microsoft.com/en-us/sql/t-sql/statements/set-xact-abort-transact-sql): how errors affect transactions, with a runnable example.

### Free courses
- [Microsoft Learn: Query and modify data with Transact-SQL](https://learn.microsoft.com/en-us/training/paths/get-started-querying-with-transact-sql/): a beginner learning path covering `SELECT`, joins, subqueries, built-in functions and data changes.
- [CMU 15-445/645: Intro to Database Systems](https://15445.courses.cs.cmu.edu/): Carnegie Mellon's database internals course (storage, indexes, query execution, concurrency, recovery). Lectures are on the [CMU Database Group YouTube channel](https://www.youtube.com/@CMUDatabaseGroup).
- [How to Think Like the SQL Server Engine](https://www.brentozar.com/training/think-like-sql-server-engine/) by Brent Ozar: a free 2-hour video course on clustered, nonclustered and covering indexes and reading execution plans. A follow-on to Part B of this repo.

### Websites and blogs
- [Use The Index, Luke](https://use-the-index-luke.com/) by Markus Winand: a free book on SQL indexing and performance for developers.
- [Error and Transaction Handling in SQL Server](https://www.sommarskog.se/error_handling/Part1.html) by Erland Sommarskog: the standard reference on `TRY … CATCH`, `XACT_ABORT` and error-handling patterns.
- [Paul Randal's blog (SQLskills)](https://www.sqlskills.com/blogs/paul/): SQL Server internals, transaction logs and indexing, including the beginner-friendly "SQL101" series.
- [SQLServerCentral Stairways](https://www.sqlservercentral.com/stairways): step-by-step tutorial series on SQL Server topics.

### Books
- *Database System Concepts* by Silberschatz, Korth and Sudarshan: the classic DBMS textbook (relational model, normalization, indexing, transactions). See the [book's website](https://www.db-book.com/).
- *T-SQL Fundamentals* by Itzik Ben-Gan (Microsoft Press): a thorough introduction to T-SQL and set-based thinking.

### Practice
- [LeetCode SQL 50](https://leetcode.com/studyplan/top-sql-50/): 50 interview-style problems from basic to intermediate.
- [SQLBolt](https://sqlbolt.com/): short interactive lessons that run in the browser.
- [db<>fiddle](https://dbfiddle.uk/): run and share SQL Server snippets online.
