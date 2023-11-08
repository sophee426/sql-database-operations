use portfolio_project;

-- Looking at total cases vs total deaths (% likelihood of dying if you're contracted)
SELECT continent, location, date, (total_deaths/total_cases) *100 as percentDeath
FROM coviddeaths;

-- Looking at total case vs population
SELECT continent, sum(total_cases/population) *100 as percentInfected
FROM coviddeaths
GROUP BY continent;

-- Showing countries with the total death count per day
SELECT continent, location, date, sum(total_deaths) AS Total_deaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, date;

-- Looking at total population and vaccination
SELECT cd.continent, cd.location,  cd.date, (total_vaccinations/population)* 100 AS percentVaccinated, 
		SUM(cv.new_vaccinations) over(partition by cd.location order by cd.location, cd.date) as rollingVaccinated
FROM coviddeaths cd
LEFT JOIN covidvaccinations cv
ON cd.iso_code = cv.iso_code
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY percentVaccinated, cd.date desc;

-- Creating a CTE
WITH PopvsVac (Continent, Location, Date, percent_Vacc, rolling_Vacc) 
AS(
SELECT cd.continent, cd.location,  cd.date, (total_vaccinations/population)* 100 AS percentVaccinated, 
		SUM(cv.new_vaccinations) over(partition by cd.location order by cd.location, cd.date) as rollingVaccinated
FROM coviddeaths cd
LEFT JOIN covidvaccinations cv
ON cd.iso_code = cv.iso_code
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY percentVaccinated, cd.date desc
)
SELECT Date, rolling_Vacc FROM PopvsVac;

-- Creating Temp Table
DROP Table if exists PercentPopVacc;
CREATE temporary table PercentPopVacc(
Continent varchar(255),
Location varchar(255),
Date char(55),
percent_Vacc numeric, 
rolling_Vacc numeric
);

Insert into PercentPopVacc
SELECT cd.continent, cd.location, cd.date, (total_vaccinations/population)* 100 AS percentVaccinated, 
		SUM(cv.new_vaccinations) over(partition by cd.location order by cd.location, cd.date) as rollingVaccinated
FROM coviddeaths cd
LEFT JOIN covidvaccinations cv
ON cd.iso_code = cv.iso_code
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;
-- ORDER BY percentVaccinated, cd.date desc

select * from percentpopvacc
ORDER BY percentVaccinated, cd.date desc;

-- CREATE VIEW
CREATE VIEW PercentPopVacc AS
SELECT cd.continent, cd.location, cd.date, (total_vaccinations/population)* 100 AS percentVaccinated, 
		SUM(cv.new_vaccinations) over(partition by cd.location order by cd.location, cd.date) as rollingVaccinated
FROM coviddeaths cd
LEFT JOIN covidvaccinations cv
ON cd.iso_code = cv.iso_code
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;
