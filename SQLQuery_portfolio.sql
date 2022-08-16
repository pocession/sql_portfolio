-- Create a new data base --

IF NOT EXISTS (
 SELECT name
 FROM sys.databases
 WHERE name = N'PortfolioDB'
)
CREATE DATABASE [PortfolioDB]
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
SELECT SUM(new_deaths) as total_deaths, SUM(new_cases) as total_cases, 
    (SUM(new_deaths) / SUM(new_cases))*100 as DeathRates, 
    (SUM(new_cases) / SUM(population))*100 as InfectionRates, MAX(population) as population
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE continent is NULL

-- Check data by continent --
---- Look at highest death count vs cases (DeathRates) among continents ----
SELECT location, SUM(new_deaths) as Total_Deaths, SUM(new_cases) as Total_Cases, 
    (SUM(new_deaths) / SUM(new_cases))*100 as DeathRates, (SUM(new_cases)/MAX(population))*100 as InfectionRates,
    MAX(population) as population
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
---- Note the weird record of North Korea ----
SELECT location, SUM(new_deaths) as HighestDeathCount, SUM(new_cases) as HighestCaseCount, MAX(population) as population, (SUM(total_deaths) / SUM(total_cases))*100 as DeathRates
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE continent IS NOT Null
-- WHERE location like '%Taiwan%' --
GROUP BY location, population
ORDER BY DeathRates DESC

---- Double confirm the record of North Korea ----
SELECT location, date, total_deaths, total_cases, new_cases, new_deaths, population, continent
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE continent IS NOT Null AND location = 'North Korea'
ORDER by new_deaths DESC

---- Look at highest vaccinated count vs population (VaccinationRates) among countries  ----
---- Use CTE ----
WITH PropvsVac (continent, location, date, population, new_vaccinations, PeopleRollingVaccinated) as
(
    SELECT continent, location, date, MAX(population) as population, new_vaccinations,
        SUM(new_vaccinations) OVER(PARTITION BY location ORDER BY location, date) AS PeopleRollingVaccinated
    FROM [PortfolioDB].[dbo].[owid-covid-data]
    WHERE continent IS NOT Null
    GROUP BY continent, location, date, new_vaccinations
    -- ORDER by PeoplerRollingVaccinated DESC
)
select * -- Don't forget the final select
from PropvsVac
ORDER BY PeopleRollingVaccinated DESC


---- Temp table ----
DROP TABLE if exists #Vaccination ---- Note # marks the temp table, will not save to the database

CREATE TABLE #Vaccination 
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    PeopleRollingVaccinated numeric
)
INSERT INTO #Vaccination
SELECT continent, location, date, MAX(population) as population, new_vaccinations, 
        SUM(new_vaccinations) OVER(PARTITION BY location ORDER BY location, date) AS PeopleRollingVaccinated
    FROM [PortfolioDB].[dbo].[owid-covid-data]
    WHERE continent IS NOT Null
    GROUP BY continent, location, date, new_vaccinations
    -- ORDER by PeoplerRollingVaccinated DESC
GO

SELECT * FROM #Vaccination
ORDER BY PeopleRollingVaccinated DESC

---- Table ----
DROP TABLE if exists Vaccination

CREATE TABLE Vaccination 
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    PeopleRollingVaccinated numeric
)
INSERT INTO Vaccination
SELECT continent, location, date, MAX(population) as population, new_vaccinations, 
        SUM(new_vaccinations) OVER(PARTITION BY location ORDER BY location, date) AS PeopleRollingVaccinated
    FROM [PortfolioDB].[dbo].[owid-covid-data]
    WHERE continent IS NOT Null
    GROUP BY continent, location, date, new_vaccinations
    -- ORDER by PeoplerRollingVaccinated DESC
GO

SELECT * FROM Vaccination
ORDER BY PeopleRollingVaccinated DESC

---- Create view for storing data for visualization ----
---- A view is just a SELECT statement which has been saved in the database ----
---- The advantage of view is to save a complex SELECT statement from several tables ----
DROP VIEW IF EXISTS View_Vaccination 

CREATE VIEW View_Vaccination as
SELECT continent, location, date, MAX(population) as population, new_vaccinations, 
        SUM(new_vaccinations) OVER(PARTITION BY location ORDER BY location, date) AS PeopleRollingVaccinated
    FROM [PortfolioDB].[dbo].[owid-covid-data]
    WHERE continent IS NOT Null
    GROUP BY continent, location, date, new_vaccinations
    -- ORDER by PeoplerRollingVaccinated DESC

SELECT * FROM View_Vaccination
ORDER BY PeopleRollingVaccinated DESC

-- Tables used for Tableau --
---- Table 1, Global data ----
SELECT SUM(new_deaths) as total_deaths, SUM(new_cases) as total_cases, 
    (SUM(new_deaths) / SUM(new_cases))*100 as DeathRates, 
    (SUM(new_cases) / SUM(population))*100 as InfectionRates, MAX(population) as population
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE continent is NULL

---- Table 2, Data by continent ----
SELECT location, SUM(new_deaths) as Total_deaths, SUM(new_cases) as Total_cases, 
    (SUM(new_deaths) / SUM(new_cases))*100 as DeathRates, (SUM(new_cases)/MAX(population))*100 as InfectionRates,
    MAX(population) as population
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE continent is NULL AND 
    (location NOT LIKE '%income%' AND location != 'International' AND location != 'World' AND location NOT LIKE '%Union%')
GROUP BY location, continent, population
ORDER BY DeathRates DESC

---- Table 3, Data by contry ----
---- North Korea data has been dropped because it contains obvious error ----
SELECT location, SUM(new_deaths) as Total_deaths, SUM(new_cases) as Total_cases,
    (SUM(new_deaths) / SUM(new_cases))*100 as DeathRates, (SUM(new_cases)/MAX(population))*100 as InfectionRates,
    population
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE continent is not NULL AND location != 'North Korea'
GROUP BY location, continent, population
ORDER BY DeathRates DESC

---- Table 4, Time series data by country ----
SELECT location, date, ISNULL(total_cases, 0) as total_cases, (total_cases / population)*100 as InfectionRates, 
    population
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE continent is not NULL
ORDER BY location, date ASC

---- Test codes ----
SELECT location, continent, SUM(new_deaths) as Total_deaths, SUM(new_cases) as Total_cases, population
FROM [PortfolioDB].[dbo].[owid-covid-data]
WHERE continent is not NULL
GROUP BY location, continent, population