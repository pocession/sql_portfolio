-- Create a new data base --

IF NOT EXISTS (
 SELECT name
 FROM sys.databases
 WHERE name = N'PortfolioDB'
)
CREATE DATABASE [PortfolioDB]
GO
ALTER DATABASE [PortfolioDB] SET QUERY_STORE=ON
GO

-- Import CovidVaccinations & CovidDeaths csv files to data base --
---- Use Import wizard ----
---- Change the table name ----
-- Check top 1000 rows of CovidVaccinations --
SELECT TOP (1000) * FROM [PortfolioDB].[dbo].[owid-covid-data]

-- The analysis begins from here --
---- Take a look at data we are going to use ----
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM [PortfolioDB].[dbo].[owid-covid-data]
ORDER BY new_cases DESC

---- Order by date ----
SELECT location, date, total_cases, new_cases, total_deaths, population, (total_deaths / total_cases) as DeathRates 
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE location like '%Taiwan%'
ORDER BY 1,2 DESC

DROP TABLE PortfolioDB.dbo.CovidDeaths, PortfolioDB.dbo.CovidVaccinations