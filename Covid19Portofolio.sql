select * from
CovidDeaths

--select * from
--CovidVaccinations


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


--Looking for total deaths vs total cases percantage

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercantage
from CovidDeaths
where location like '%Indo%'
order by 1,2 


--Looking at total cases vs population percantage

select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercantage
from CovidDeaths
--where location like '%Indo%'
order by 1,2 


--Looking select location, date, population, total_cases, (total_cases/population)*100 as DeathPercantage

select location, population, max(total_cases) as HighestInfection, max((total_cases/population))*100 as PopulationInfectedPercantage
from CovidDeaths
group by location, population
order by PopulationInfectedPercantage desc


--Showing countries with the highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Lets breakthings by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Showing continents withthe highest death count per population

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  sum(cast(new_deaths as int))/sum (new_cases)*100 as DeathPercantage  --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercantage
from CovidDeaths
where continent is not null
--group by date
order by 1,2


--Total population vs total vaccination
--use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac




--Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store sata for visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

select *
from PercentPopulationVaccinated
