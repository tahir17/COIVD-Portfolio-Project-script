select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total cases vs total deaths
-- shows the likelihood of dying if you contract covid in respective country

Select location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Total case vs population
-- shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate 
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Country with the highest Infection Rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestInfectionRate 
from PortfolioProject..CovidDeaths
where continent is not null
group by population, location
order by HighestInfectionRate desc

-- Country with the highest Death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Breaking things down by continent with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(NULLIF(new_cases,0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- Joining the 2 tables together
-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
                                                                            as RollingPeopleVaccinated
   ,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location 
  and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac(Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
                                                                            as RollingPeopleVaccinated
   --,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location 
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,NULLIF(vac.new_vaccinations,0))) OVER (Partition by dea.location order by dea.location, dea.date) 
                                                                            as RollingPeopleVaccinated
   --,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location 
  and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualisations

USE PortfolioProject
GO
Create View PercentPopulationVaccinated1 as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,NULLIF(vac.new_vaccinations,0))) OVER (Partition by dea.location order by dea.location, dea.date) 
                                                                            as RollingPeopleVaccinated
   --,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location 
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated1