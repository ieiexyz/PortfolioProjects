
-- Looking at all data
SELECT *
FROM portfolio.coviddeath
WHERE continent !=''
order by 3,4;

-- select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Portfolio.coviddeath
ORDER BY 1,2;

-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio.coviddeath
WHERE location like '%Taiwan%'
ORDER BY 1,2;

-- Looking at total cases vs population
-- Shows what percentage of populiation got Covid
SELECT location, date, Population, total_cases, total_deaths, (total_cases/population)*100 as PercentagePopulationInfected
FROM Portfolio.coviddeath
WHERE location like '%states%'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentagePopulationInfected
FROM portfolio.coviddeath
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc;

-- Showing countries with highest death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM portfolio.coviddeath
WHERE continent !='' -- droup those group by continent
GROUP BY location
ORDER BY TotalDeathCount desc;

-- LET's BREAK THINGS DOWN BY CONTINENT

-- Showing continent with the highest death count perpopulation
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM portfolio.coviddeath
WHERE continent !='' -- droup those group by continent
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- GLOBAL NUMBERS
SELECT SUM(new_cases)as TotalCases, SUM(new_deaths)as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio.coviddeath
WHERE continent !=''
ORDER BY 1,2;

-- GLOBAL NUMBERS BY DATE
SELECT date, SUM(new_cases)as TotalCases, SUM(new_deaths)as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio.coviddeath
WHERE continent !=''
GROUP BY date
ORDER BY 1,2;


-- Join deaths and vaccination tables

SELECT *
FROM portfolio.coviddeath dea
JOIN portfolio.covidvaccination vac
ON dea.location = vac.location
AND dea.date = vac.date;


-- Looking at Total Polulation vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio.coviddeath dea
JOIN portfolio.covidvaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null;
-- RDER BY 2,3

-- USE CTE

With PopvsVac (continet, location, data, population, new_vaccinations, RollingPeopleVaccinated )
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio.coviddeath dea
JOIN portfolio.covidvaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

-- TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations text,
RollingPeopleVaccinated numeric
);

INSERT into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio.coviddeath dea
JOIN portfolio.covidvaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null;
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated;

-- Creating view to store data for later visualizations
DROP TABLE IF EXISTS PercentPopulationVaccinated;
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolio.coviddeath dea
JOIN portfolio.covidvaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

