
Select *
From [Portofolio Project]..CovidDeaths
where continent not like ''
order by 3,4

--Select *
--From [Portofolio Project]..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases,total_deaths,population
From [Portofolio Project]..CovidDeaths
order by 1,2


alter table [Portofolio Project]..CovidDeaths
alter column total_cases decimal (18,0)

alter table [Portofolio Project]..CovidDeaths
alter column total_deaths decimal(18,0)

-- Total Cases vs Total Deaths
Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as PersentasiKematian
From [Portofolio Project]..CovidDeaths 
where location like '%states%'
order by 1,2

--Total Cases vs Population
Select Location, date,population, total_cases,(total_cases/population)*100 as PersenPopulasiTerinfeksi
From [Portofolio Project]..CovidDeaths 
--where location like '%states%'
order by 1,2

-- Looking Countries with Highest Infection
Select Location,population, max(total_cases) as InfeksiTertinggi, max((total_cases/population))*100 as PersenPopulasiTerinfeksiTertinggi
From [Portofolio Project]..CovidDeaths 
--where location like '%states%'
group by location, population
order by PersenPopulasiTerinfeksiTertinggi desc

--Break by continent
Select continent, max(cast(total_deaths as int)) as TotalKematian
From [Portofolio Project]..CovidDeaths 
--where location like '%states%'
where continent not like ''
group by continent
order by TotalKematian desc

--Looking Countries with Highest Death Count per Population
Select Location, max(cast(total_deaths as int)) as TotalKematian
From [Portofolio Project]..CovidDeaths 
--where location like '%states%'
where continent not like ''
group by location
order by TotalKematian desc

--Showing continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalKematian
From [Portofolio Project]..CovidDeaths 
--where location like '%states%'
where continent not like ''
group by continent
order by TotalKematian desc

--GLOBAL NUMBERS
Select sum(new_cases)as TotalKasus,
	sum(cast(new_deaths as int)) as TotalKematian,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as PersentasiKematian
	--,total_deaths,(total_deaths/total_cases)*100 as PersentasiKematian
From [Portofolio Project]..CovidDeaths 
--location like '%states%'
where continent not like ''
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(try_cast(vac.new_vaccinations as decimal(18,0))) 
over (partition by dea.location order by dea.location, dea.date) as RolingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
From [Portofolio Project]..CovidDeaths dea
Join [Portofolio Project]..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent not like ''
order by 2,3

--USE CTE
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(try_cast(vac.new_vaccinations as decimal(18,0))) 
over (partition by dea.location order by dea.location, dea.date) as RolingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
From [Portofolio Project]..CovidDeaths dea
Join [Portofolio Project]..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent not like ''
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population decimal(18,0),
New_Vaccination decimal(18,0),
RollingPeopleVaccinated decimal(18,0))

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(try_cast(vac.new_vaccinations as decimal(18,0))) 
over (partition by dea.location order by dea.location, dea.date) as RolingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
From [Portofolio Project]..CovidDeaths dea
Join [Portofolio Project]..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent not like ''
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View To Store Data
Create View PersentasiPopulasiVaksin as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(try_cast(vac.new_vaccinations as decimal(18,0))) 
over (partition by dea.location order by dea.location, dea.date) as RolingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
From [Portofolio Project]..CovidDeaths dea
Join [Portofolio Project]..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent not like ''
--order by 2,3