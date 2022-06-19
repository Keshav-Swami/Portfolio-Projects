select *
from Portfolio..DeathData
where continent is not null
order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from Portfolio..DeathData
where continent is not null
order by 1,2

--Total cases vs Total deaths
--likelihood of dying if you contract covid in India
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from Portfolio..DeathData
where location = 'india'
and continent is not null
order by 1,2

--Total cases vs population of India
--what % of population got covid in India
select location,date, total_cases, population, (total_cases/population)*100 as CovidPercent
from Portfolio..DeathData
where location = 'india' and continent is not null
order by 1,2

--Countries with highest infection rate compared to Population
select location, population,  max(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as CovidPercent
from Portfolio..DeathData
where continent is not null
group by location, population
order by CovidPercent desc

-- Countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..DeathData
where continent is not null
group by location
order by TotalDeathCount desc


--Showing the continents with highest death count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..DeathData
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Stats
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from Portfolio..DeathData
where continent is not null
group by date
order by 1,2

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from Portfolio..DeathData
where continent is not null
order by 1,2

--Total population vs Vaccinations 
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint )) OVER (Partition by dea.location order by dea.location, dea.date) AS CummulativeNumb
from Portfolio..DeathData as Dea
join Portfolio..VaccineData as Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Percent of people vaccinated in a country using CTE
With PeoVacc (Continent, location, date, population, new_vaccinations, CummulativeNumb)
as
(
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint )) OVER (Partition by dea.location order by dea.location, dea.date) AS CummulativeNumb
from Portfolio..DeathData as Dea
join Portfolio..VaccineData as Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *,(CummulativeNumb/population)*100 as PercentPop
from PeoVacc

--Percent of people vaccinated in a country using temp table
DROP Table if exists #Peovaccinated
Create table #PeoVaccinated 
(
Continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
CummulativeNumb numeric)

insert into #PeoVaccinated
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint )) OVER (Partition by dea.location order by dea.location, dea.date) AS CummulativeNumb
from Portfolio..DeathData as Dea
join Portfolio..VaccineData as Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *,(CummulativeNumb/population)*100 as PercentPop
from #PeoVaccinated

--Creating view to store data for later visualization

Create view PeoVaccinated as
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint )) OVER (Partition by dea.location order by dea.location, dea.date) AS CummulativeNumb
from Portfolio..DeathData as Dea
join Portfolio..VaccineData as Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PeoVaccinated