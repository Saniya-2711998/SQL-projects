-- Covid 19 Data Exploration

SELECT *
FROM 
public. "CovidDeaths"

--Selecting the data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM public. "CovidDeaths"
WHERE location = 'India'
ORDER BY 1,2

/* Total Cases vs Total Deaths
Shows the likelihood of dying if you contract covid in your country*/

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM public. "CovidDeaths"
WHERE location = 'India'
ORDER BY 1,2

/* Total Cases vs Population
Shows percentage of population infected with covid */

SELECT location, date, total_cases, population, (total_cases/population)*100 as percent_infected
FROM public. "CovidDeaths"
--WHERE location = 'India'
ORDER BY 1,2

--Countries with highest infection rate when compared to population

SELECT location, population, MAX(total_cases) as highest_infection, MAX((total_cases/population))*100 as highest_infected_percent
FROM public. "CovidDeaths"
WHERE total_cases is not null and population is not null
GROUP BY location, population
ORDER BY highest_infected_percent DESC

--Countries with highest death count per population

SELECT location, population, MAX(total_deaths) as highest_deaths
FROM public. "CovidDeaths"
WHERE total_deaths is not null and continent is not null
GROUP BY location, population
ORDER BY highest_deaths DESC

--Breaking things down by continent
--Continents with highest death count

SELECT continent, MAX(total_deaths) as highest_deaths
FROM public. "CovidDeaths"
WHERE continent is not null
GROUP BY continent
ORDER BY highest_deaths DESC

--Global numbers

SELECT SUM(total_cases) as total_cases, SUM(total_deaths) as total_deaths, SUM(total_deaths)/SUM(total_cases)*100 as death_percent_globally
FROM public. "CovidDeaths"
WHERE continent is not null

/* Total Population vs Vaccinations
Shows percentage of population that has recieved atleast one covid vaccination*/

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location ,dea.date ) as total_people_vaccinated
FROM public. "CovidDeaths" dea
	JOIN public. "CovidVaccinations" vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE vac.new_vaccinations is not null and dea.continent is not null
ORDER BY 2,3

--Using CTE to perform Calculation on Partition By in previous query
WITH pop_vs_vac (continent, location, date, population, people_vaccinated, total_people_vaccinated)
as
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated,
SUM(vac.people_vaccinated) OVER (PARTITION BY dea.location ORDER BY dea.location ,dea.date ) as total_people_vaccinated
FROM public. "CovidDeaths" dea
	JOIN public. "CovidVaccinations" vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE vac.people_vaccinated is not null and dea.continent is not null
)
SELECT *, (people_vaccinated/population) *100 as percent_vaccinated
FROM pop_vs_vac

--Creating view to store data for later visualizations
--People vaccinated

CREATE VIEW percentage_people_vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated,
SUM(vac.people_vaccinated) OVER (PARTITION BY dea.location ORDER BY dea.location ,dea.date ) as total_people_vaccinated
FROM public. "CovidDeaths" dea
	JOIN public. "CovidVaccinations" vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE vac.people_vaccinated is not null and dea.continent is not null

--Global Death Percent

CREATE VIEW global_death_percent as
SELECT SUM(total_cases) as total_cases, SUM(total_deaths) as total_deaths, SUM(total_deaths)/SUM(total_cases)*100 as death_percent_globally
FROM public. "CovidDeaths"
WHERE continent is not null

--Continents with highest death percent

CREATE VIEW continents_highest_death as
SELECT continent, MAX(total_deaths) as highest_deaths
FROM public. "CovidDeaths"
WHERE continent is not null
GROUP BY continent
ORDER BY highest_deaths DESC

--Countries with highest death count per population

CREATE VIEW highest_deaths as
SELECT location, population, MAX(total_deaths) as highest_deaths
FROM public. "CovidDeaths"
WHERE total_deaths is not null and continent is not null
GROUP BY location, population
ORDER BY highest_deaths DESC

--Countries with highest infected rate per population

CREATE VIEW highest_infected_rate as
SELECT location, population, MAX(total_cases) as highest_infection, MAX((total_cases/population))*100 as highest_infected_percent
FROM public. "CovidDeaths"
WHERE total_cases is not null and population is not null
GROUP BY location, population
ORDER BY highest_infected_percent DESC

--Population infected with covid

CREATE VIEW population_infected as
SELECT location, date, total_cases, population, (total_cases/population)*100 as percent_infected
FROM public. "CovidDeaths"
ORDER BY 1,2

-- Total cases vs Death

CREATE VIEW percent_death as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM public. "CovidDeaths"
ORDER BY 1,2





