--EXPLORING COVID DATA

-- GENERAL OVERLOOK OF THE TABLE
select location,date,population,total_cases,new_cases,total_deaths from CovidD$ order by 1,2

--PERCENTAGE OF DEATHS TO TOTAL CASES
select location, (total_deaths /total_cases)*100  from CovidD$

select date,location,population, (total_cases/population)*100 as T from CovidD$ where location='India' order by T desc

--MAX OF PERCENTAGE OF DEATHS TO TOTAL CASES AND OTHER QUERIES
select location, MAX(total_cases), MAX((total_cases/population)*100) from CovidD$ group by location order by MAX(total_cases) desc

select location, MAX((total_deaths/population)*100) as T from CovidD$ group by location order by T desc


select location, MAX(CAST (total_deaths as INT)) as T from CovidD$ where continent is not null group by location order by T desc

select continent, MAX(CAST (total_deaths as INT)) as T from CovidD$ where continent is not null group by continent order by T desc

select location, MAX(CAST (total_deaths as INT)) as T from CovidD$ where continent is null group by location order by T desc

SELECT continent, MAX(CAST(total_deaths AS INT)) as T from CovidD$ where continent is not null group by continent order by T desc


--GLOBAL

SELECT  date ,SUM(CAST(new_deaths as INT))/SUM(new_cases) from CovidD$  group by date having SUM(new_cases) !=0


-- CHECKING THE VACINATION TABLE

-- Checking Population and Vacinated

SELECT D.continent,D.date,D.location, new_vaccinations , population, PercentageOfVaccinated = (new_vaccinations/total_cases)*100 FROM CovidV$ V inner join CovidD$ D on D.date = V.date and D.location = V.location where D.continent is not null order by continent,location,date



SELECT D.continent,D.date,D.location, total_vaccinations, new_vaccinations , population, PercentageOfVaccinated = (new_vaccinations/total_cases)*100 , A22VGPERLOCA = SUM(CAST(new_vaccinations AS BIGINT)) OVER(PARTITION BY D.location ORDER BY D.Date), AVGPERLOCA = SUM(CAST(new_vaccinations AS BIGINT)) OVER(PARTITION BY D.location) FROM CovidV$ V inner join CovidD$ D on D.date = V.date and D.location = V.location where D.continent is not null and V.new_vaccinations is not null order by location,date

--USING CTE TO CALCULATE RUNNING PERCENTAGE

WIth NewT as
(

SELECT D.continent,D.date,D.location, total_vaccinations,
new_vaccinations , population, PercentageOfVaccinated = (new_vaccinations/total_cases)*100 , 
RunningT = SUM(CAST(new_vaccinations AS BIGINT)) OVER(PARTITION BY D.location ORDER BY D.Date)
FROM CovidV$ V inner join CovidD$ D on D.date = V.date and D.location = V.location where D.continent is not null and V.new_vaccinations is not null

)

SELECT *, RunningP = (RunningT/population)*100 FROM NewT

-- USING TEMP TABLE
DROP TABLE #CovidTempCheck
Create Table #CovidTempCheck
(
  
  continent NVARCHAR(255),
  date DATETIME,
  location NVARCHAR(255),
  population float,
  new_vacinations NVARCHAR(255),
  RunningCheck BIGINT

)
INSERT INTO #CovidTempCheck(
  continent,
  date ,
  location, 
  population ,
  new_vacinations ,
  RunningCheck

)

SELECT D.continent,D.date,D.location,population,
new_vaccinations , 
RunningT = SUM(CAST(new_vaccinations AS BIGINT)) OVER(PARTITION BY D.location ORDER BY D.Date)
FROM CovidV$ V inner join CovidD$ D on D.date = V.date and D.location = V.location where D.continent is not null and V.new_vaccinations is not null

SELECT *,RunningT = (RunningCheck/population)*100 FROM #CovidTempCheck

-- CREATING A VIEW

CREATE VIEW PopulationVSTotalVac

AS
SELECT D.continent,D.date,D.location, total_vaccinations, new_vaccinations , population, PercentageOfVaccinated = (new_vaccinations/total_cases)*100 , A22VGPERLOCA = SUM(CAST(new_vaccinations AS BIGINT)) OVER(PARTITION BY D.location ORDER BY D.Date), AVGPERLOCA = SUM(CAST(new_vaccinations AS BIGINT)) OVER(PARTITION BY D.location) FROM CovidV$ V inner join CovidD$ D on D.date = V.date and D.location = V.location where D.continent is not null and V.new_vaccinations is not null 

SELECT * from PopulationVSTotalVac