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

-- Overview of data --
---- Take a look at data we are going to use ----
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM [PortfolioDB].[dbo].[owid-covid-data]
ORDER BY new_cases DESC

---- Look at the death rates, reverse ordered by date ----
SELECT location, date, total_cases, new_cases, total_deaths, population, (total_deaths / total_cases)*100 as DeathRates 
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE location like '%Taiwan%'
ORDER BY 1,2 DESC

---- Look at total cases vs population (infection rate)  ----
SELECT location, date, total_cases, new_cases, total_deaths, population, (total_cases / population)*100 as InfectionhRates 
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE location like '%Taiwan%'
ORDER BY 1,2 DESC

---- Look at infection rate vs population among countries  ----
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases / population)*100) as InfectionRates
FROM [PortfolioDB].[dbo].[owid-covid-data]
-- WHERE location like '%Taiwan%' --
GROUP BY location, population
ORDER BY InfectionRates DESC

---- Look at Global death count vs cases (DeathRates)  ----
SELECT SUM(new_deaths) as total_deaths, SUM(new_cases) as total_cases, SUM(new_deaths) / SUM(new_cases) as DeathRates
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE continent is not NULL

-- Check data by continent --
---- Look at highest death count vs cases (DeathRates) among continents----
SELECT location, MAX(total_deaths) as highestDeathCount, MAX(total_cases) as highestCaseCount, MAX(population) as population, MAX(total_deaths/total_cases)*100 as DeathRates, continent
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE continent is NULL AND 
    (location NOT LIKE '%income%' AND location != 'International' AND location != 'World' AND location NOT LIKE '%Union%')
GROUP BY location, continent, population
ORDER BY DeathRates DESC

-- Check data by country --
---- Look at highest death count among countries  ----
SELECT location, MAX(total_deaths) as HighestDeathCount, population
FROM [PortfolioDB].[dbo].[owid-covid-data]
-- WHERE location like '%Taiwan%' --
GROUP BY location, population
ORDER BY HighestDeathCount DESC

---- Look at highest death count vs cases (DeathRates) among countries  ----
SELECT location, MAX(total_deaths) as HighestDeathCount, MAX(total_cases) as highestCaseCount, MAX(population) as population, MAX(total_deaths / total_cases)*100 as DeathRates
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE continent IS NOT Null
-- WHERE location like '%Taiwan%' --
GROUP BY location, population
ORDER BY DeathRates DESC

SELECT location, date, total_deaths, total_cases, new_cases, new_deaths, population, continent
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE continent IS NOT Null AND location = 'North Korea'
ORDER by new_deaths DESC



