USE [Portfolio Database]
--Select location, date, total_cases, new_cases,total_deaths, population, (total_deaths/total_cases)*100 AS 'Death Percentage' From CovidDeaths
Where location like '%Nigeria%'
order by 1,2 desc

-- looking at total cases versus total deaths

--looking at total cases vs the population

Select location, date, total_cases, population, (total_deaths/population)*100 AS 'Population Infected' From CovidDeaths
--Where location like '%Nigeria%'
order by 1,2 desc

-- Looking at Countries with highest infection rate	compared to population


USE [Portfolio Database]
Select location, population, MAX(total_cases) AS 'Highest Infection Count', MAX((total_cases/population))*100 AS 'Percent of Population Infected' 
 From CovidDeaths
 Group by location, population
 order by 'Percent of Population Infected' desc

 --showing countries with highest death count per population

 USE [Portfolio Database]
 SELECT location, MAX(cast(total_deaths as int)) AS 'Total Death Count'
 FROM CovidDeaths
 WHERE continent is not null
 group by location
 order by 'Total Death Count' desc


 --BREAKING IT DOWN BY CONTINENT

 SELECT location, MAX(cast(total_deaths as int)) AS 'Total Death Count'
 FROM CovidDeaths
 WHERE continent is null
 group by location
 order by 'Total Death Count' desc

 --Showing continents with the highest death count per population

 USE [Portfolio Database]

 SELECT continent, MAX(cast(total_deaths as int)) AS 'Total Death Count'
 FROM CovidDeaths
 Where continent is not null
 GROUP BY continent
 ORDER BY 'Total Death Count' desc
 
 SELECT continent, location, date, population, weekly_icu_admissions from CovidDeaths 
WHERE weekly_icu_admissions is not  null and location  like '%Estonia%'

USE [Portfolio Database]

--SELECT * FROM CovidDeaths
SELECT date, SUM(new_cases) as 'total cases' , SUM(cast(new_deaths as int)) as 'total deaths',
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS 'Death Percentage'
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 


--Looking at Total Population versus Vaccination

USE [Portfolio Database]
SELECT death.continent, death.date, death.location, death.population, vac.new_vaccinations FROM CovidVaccinations vac
JOIN CovidDeaths death
ON vac.location = death.location
AND vac.date = death.date
WHERE death.continent is not null and vac.new_vaccinations is not null
ORDER BY 1,2,3


-- Cumulative Vaccinations

SELECT death.continent, death.location,death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as 'Cumulative Vaccination'
FROM CovidVaccinations vac
JOIN CovidDeaths death
ON vac.location = death.location
AND vac.date = death.date
WHERE death.continent is not null and vac.new_vaccinations is not null 
ORDER BY 2,3


--Cumulative Vaccinations by Location

SELECT death.continent, death.location,death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as 'Cumulative Vaccination'
FROM CovidVaccinations vac
JOIN CovidDeaths death
ON vac.location = death.location9
AND vac.date = death.date
WHERE death.continent is not null and vac.new_vaccinations is not null and vac.location = 'Nigeria'
ORDER BY 2,3


-- USE CTE


With populationvsvac (continent, location, date, population, new_vaccinations, CumulativeVaccination)
AS 
( 

SELECT death.continent, death.location,death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as CumulativeVaccination
FROM CovidDeaths death
JOIN CovidVaccinations vac
ON vac.location = death.location
AND vac.date = death.date
WHERE death.continent is not null and new_vaccinations is not null
--('Cumulative Vaccination)/population) AS 
--ORDER BY 2,3 
)

SELECT *, (CumulativeVaccination/population)*100
FROM populationvsvac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumulativeVaccination numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location,death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as CumulativeVaccination
FROM CovidDeaths death
JOIN CovidVaccinations vac
ON vac.location = death.location
AND vac.date = death.date
WHERE death.continent is not null and new_vaccinations is not null
--('Cumulative Vaccination)/population) AS 
--ORDER BY 2,3 

SELECT *, (CumulativeVaccination/population)*100
FROM #PercentPopulationVaccinated




--Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location,death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as CumulativeVaccination
FROM CovidDeaths death
JOIN CovidVaccinations vac
ON vac.location = death.location
AND vac.date = death.date
WHERE death.continent is not null and new_vaccinations is not null
--('Cumulative Vaccination)/population) AS 
--ORDER BY 2,3


SELECT *
FROM #PercentPopulationVaccinated