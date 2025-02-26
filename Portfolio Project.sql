SELECT * FROM coviddeaths
ORDER BY STR_TO_DATE(3, '%m/%d/%Y') ASC;

-- Selecting data that I want to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY STR_TO_DATE(3, '%m/%d/%Y') ASC;

-- Looking at Total Cases vs Total Deaths
-- This shows the likelihood of dying if you contract Covid in the United States

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location like '%states%'
ORDER BY STR_TO_DATE(3, '%m/%d/%Y') ASC;

-- Looking at Total Cases vs Population within the United States
-- Show the percentage of population within the United States got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM coviddeaths
WHERE location like '%states%'
ORDER BY STR_TO_DATE(3, '%m/%d/%Y') ASC;

-- Looking at Countries with Highest Infection Rate compared to the population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- Looking at Countries with Highest Death Count per the population

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent not like ''
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Looking at each continent and their death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent not like ''
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM coviddeaths
WHERE continent not like ''
ORDER BY 1, 2;

-- Join the two tables together
-- Looking at Total Population vs Vaccinations

SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, 
STR_TO_DATE(death.date, '%m/%d/%Y') ASC) as RollingPeopleVaccinated
FROM coviddeaths death
Join covidvaccinations vac
	ON death.location = vac.location
    and death.date = vac.date
WHERE death.continent not like ''
ORDER BY STR_TO_DATE(3, '%m/%d/%Y') ASC;

-- Use CTE to get Percent of Population Vaccinated

With PerPopVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, 
STR_TO_DATE(death.date, '%m/%d/%Y') ASC) as RollingPeopleVaccinated
FROM coviddeaths death
Join covidvaccinations vac
	ON death.location = vac.location
    and death.date = vac.date
WHERE death.continent not like ''
)
SELECT *, (RollingPeopleVaccinated/Population)*100
From PerPopVac;

-- OR create a temp table for Percent of Population Vaccinated

DROP TABLE if exists PercentOfPopulationVaccinated;

CREATE TABLE PercentOfPopulationVaccinated
(
Continent text,
Location text,
Date text,
Population bigint,
New_Vaccinations bigint,
RollingPeopleVaccinated bigint
);

Insert into PercentOfPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, 
STR_TO_DATE(death.date, '%m/%d/%Y') ASC) as RollingPeopleVaccinated
FROM coviddeaths death
Join covidvaccinations vac
	ON death.location = vac.location
    and death.date = vac.date
WHERE death.continent not like '';

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPopVaccinated
FROM PercentOfPopulationVaccinated;

-- Creating a view to store date for later visualizations

CREATE VIEW PercentPopulationVaccinated as

SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, 
STR_TO_DATE(death.date, '%m/%d/%Y') ASC) as RollingPeopleVaccinated
FROM coviddeaths death
Join covidvaccinations vac
	ON death.location = vac.location
    and death.date = vac.date
WHERE death.continent not like '';

SELECT *
FROM PercentPopulationVaccinated;


