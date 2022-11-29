--NOTE TO THE READER - THIS CODE WAS WRITTEN IN MICROSOFT SQL SERVER MANAGEMENT STUDIO, UTILIZING DATA TAKEN FROM https://ourworldindata.org/covid-deaths

--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Selecting our data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases VS Total Deaths, Calculate risk of death after contracting by country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Total Cases VS Population - What percentage of population is infected
SELECT location, date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Countries with highest infection rate:population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopInfected DESC

--Countries with Highest Mortality Rate/Population
SELECT location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Breaking down by reported continent
SELECT location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with highest death rate
SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT date, SUM(new_cases)AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--BRINGING IN THE CovidVaccinations TABLE
--Total Population VS Number of Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location
	and dea.date = vacc.date
	WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (TotalVaccinations/Population)*100 AS PercentVaccinated
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
TotalVaccinations NUMERIC,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location
	and dea.date = vacc.date
WHERE dea.continent IS NOT NULL

SELECT *, (TotalVaccinations/Population)*100
FROM #PercentPopulationVaccinated

--Creating a View for viz
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
	ON dea.location = vacc.location
	and dea.date = vacc.date
WHERE dea.continent IS NOT NULL
