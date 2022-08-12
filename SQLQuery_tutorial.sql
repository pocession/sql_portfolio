IF NOT EXISTS (
 SELECT name
 FROM sys.databases
 WHERE name = N'TutorialDB'
)
CREATE DATABASE [TutorialDB]
GO
ALTER DATABASE [TutorialDB] SET QUERY_STORE=ON
GO

-- Create a new table called 'Customers' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL
DROP TABLE dbo.Customers
GO
-- Create the table in the specified schema
CREATE TABLE dbo.Customers
(
 CustomerId INT NOT NULL PRIMARY KEY, -- primary key column
 Name [NVARCHAR](50) NOT NULL,
 Location [NVARCHAR](50) NOT NULL,
 Email [NVARCHAR](50) NOT NULL
);
GO

-- Insert rows into table 'Customers'
INSERT INTO dbo.Customers
 ([CustomerId],[Name],[Location],[Email])
VALUES
 ( 1, N'Ojash', N'Nepal', N'ojashshrestha1@gmail.com'),
 ( 2, N'Shiva', N'India', N'shiva0@csharpcorner.com'),
 ( 3, N'Mahesh', N'United States', N'mahesh@csharpcorner.com'),
 ( 4, N'John', N'United Kingdom', N'john@google.com')
GO

-- Check the first 1000 rows --
SELECT TOP (1000) [CustomerId]
      ,[Name]
      ,[Location]
      ,[Email]
  FROM [TutorialDB].[dbo].[Customers]

-- Check all rows --
-- Select rows from table 'Customers'
SELECT * FROM dbo.Customers;