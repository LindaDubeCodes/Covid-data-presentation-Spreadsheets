/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM CovidData..CovidDeaths
  order by 3,4

  --SELECT *
  --FROM CovidData..CovidVaccinations
  --order by 3,4

  --select data that we are going to be using

  SELECT Location,date,total_cases,total_deaths,population
  FROM CovidData..CovidDeaths
  where continent is not null AND total_deaths is not null
  order by 1,2


  --Lookig at total cases vs total deaths In ESwatini
   SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  FROM CovidData..CovidDeaths
  where location like '%eswatini%'
  order by 1,2

  --looking at total cases vs Population In Eswatini
  --percentage that got covid
  SELECT Location,date,population, total_cases,(total_cases/population)*100 as InfectedPopulationPercentage
  FROM CovidData..CovidDeaths
  where location like '%eswatini%'
  order by 1,2


  --Searching for countries with the highest infection rates compared to population

   SELECT Location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulationPercentage
  FROM CovidData..CovidDeaths
  where continent is not null
 group by Location,population
  order by InfectedPopulationPercentage DESC


 --Countries with Highest Death Count Per Population

 SELECT Location, MAX(cast(total_deaths as int)) as TotaldeathCount
 FROM CovidData..CovidDeaths
 where continent is not null
 group by Location
 order by TotaldeathCount DESC

 --LETS BREAK THINGS DOWN BY CONTINENT
--continents with the highest death count
  SELECT location, MAX(cast(total_deaths as int)) as TotaldeathCount
 FROM CovidData..CovidDeaths
 where continent is null
 group by location
 order by TotaldeathCount DESC



 --GLOBAL NUMBERS //death percentage
  SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
  FROM CovidData..CovidDeaths
  where continent is not null
  --group by date
  order by 1,2

  --GLOBAL OVERALL
    SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
  FROM CovidData..CovidDeaths
  where continent is not null
  --group by date
  order by 1,2


   --looking at total population vs total vaccinations
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
   FROM CovidData..CovidDeaths dea
 JOIN CovidData..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3


 --use CT
 with 

 popvsvac (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
 as

  (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
   FROM CovidData..CovidDeaths dea
 JOIN CovidData..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select *, (rolling_people_vaccinated/population)*100 
 from popvsvac



 --TEMP table
 drop table if exists #Percentage_of_population_vaccinated

 create table #Percentage_of_population_vaccinated
 (continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rolling_people_vaccinated numeric
 )

 insert into #Percentage_of_population_vaccinated
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
   FROM CovidData..CovidDeaths dea
 JOIN CovidData..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

  select *, (rolling_people_vaccinated/population)*100 as Percentage_of_population_vaccinated
 from #Percentage_of_population_vaccinated



 --Creating view for visualizations

CREATE VIEW 
perc_of_pop_vac AS
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
   FROM CovidData..CovidDeaths dea
 JOIN CovidData..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select * from perc_of_pop_vac