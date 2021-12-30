SELECT *
FROM PortfolioProject1..CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProject1..CovidVaccination
--order by 3,4 

--Select Data that going to be use
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths
order by 1,2

--Total_Cases vs Total_Deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject1..CovidDeaths
where location like '%states%'
order by 1,2

--Total_Cases vs Population
--what percentage of population got covid
select Location, date, total_cases, population, (total_cases/population)*100 as casepercentage
from PortfolioProject1..CovidDeaths
--where location like '%states%'
order by 1,2

--Countries with Highest Infection Rate compared to population
select Location,population, max(total_cases) as maxinfectionrate, max((total_cases/population))*100 as infectionratepercentage
from PortfolioProject1..CovidDeaths
--where location like '%states%'
group by location, population
order by infectionratepercentage desc

--Countries with highest death count per population
select Location, max(cast(total_deaths as int)) as Deathcount
from PortfolioProject1..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by Deathcount desc

--Grouping by Continent
select continent, max(cast(total_deaths as int)) as Deathcount
from PortfolioProject1..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by Deathcount desc

--Continents with highest death count per population
select continent, max(cast(total_deaths as int)) as Deathcount
from PortfolioProject1..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by Deathcount desc

--Global Numbers
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as
deathpercentage
From PortfolioProject1..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Joining CovidDeaths and CovidVaccination
Select * 
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date

--Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) Over
(Partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
--(RollingPeoplevaccinated/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CET
with PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) Over
(Partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
--(RollingPeoplevaccinated/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeoplevaccinated/population)*100 as RPVPercentage
from PopvsVac

--Temp table
Drop table if exists #Prcntpoulationvaccinated
Create Table #Prcntpoulationvaccinated
(
continent nvarchar(255), 
location varchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeoplevaccinated numeric
)
Insert into #Prcntpoulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) Over
(Partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
--(RollingPeoplevaccinated/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeoplevaccinated/population)*100 as RPVPercentage
from #Prcntpoulationvaccinated

--Create view to store data 

Create view Percentpoulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) Over
(Partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
--(RollingPeoplevaccinated/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 

select *
from Percentpoulationvaccinated