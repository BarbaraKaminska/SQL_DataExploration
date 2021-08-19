SELECT * 
FROM PortfolioProject..covidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..covidVaccinations$
--ORDER BY 3,4

--Select data that will be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths$
ORDER BY 1, 2

--Total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_percentage
FROM PortfolioProject..covidDeaths$
WHERE location like '%Poland%'
ORDER BY 1, 2


--Total cases vs population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Covid_infectected_percentage
FROM PortfolioProject..covidDeaths$
WHERE location like '%Poland%'
ORDER BY 1, 2

--Countries with the highest infection rate
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS Covid_infectected_percentage
FROM PortfolioProject..covidDeaths$
GROUP BY location, population
ORDER BY 4 DESC


--Countries with the highest death count per population
SELECT location,MAX(cast(total_deaths as int) ) AS total_death_count
FROM PortfolioProject..covidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC


--Continent with the highest death count per population // this is not proper
SELECT continent,MAX(cast(total_deaths AS INT) ) AS total_death_count
FROM PortfolioProject..covidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

--Continent with the highest death count per population // this gives proper statistics
SELECT location,MAX(cast(total_deaths AS INT) ) AS total_death_count
FROM PortfolioProject..covidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC


--Global situation
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS Death_percentage
FROM PortfolioProject..covidDeaths$
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS Death_percentage
FROM PortfolioProject..covidDeaths$
WHERE continent IS NOT NULL 
ORDER BY 1, 2


-- Total population vs vacconations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..covidDeaths$ dea
JOIN PortfolioProject..covidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date

--Using CTE

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..covidDeaths$ dea
JOIN PortfolioProject..covidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM pop_vs_vac


--TEMP TABLE
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
Rolling_people_vaccinated numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..covidDeaths$ dea
JOIN PortfolioProject..covidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_people_vaccinated/population)*100
FROM #percent_population_vaccinated

-- Creating view

CREATE VIEW percent_population_vaccinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..covidDeaths$ dea
JOIN PortfolioProject..covidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM percent_population_vaccinated