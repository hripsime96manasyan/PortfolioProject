create database Portfolio_project

--SELECTING ALL FROM CovidDeaths

select * from CovidDeaths
order by 3,4


--SELECTING ALL FROM CovidVaccinations

select * from CovidVaccinations
order by 3,4

--SELECTING location, date, total_cases, new_cases, total_deaths and population FROM CovidDeaths


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Looking at the Total cases vs Total deaths in Armenia
-- Result shows the likelihood of dying in case of infecting with Covid in Armenia

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidDeaths
where location='Armenia'
order by 1,2


-- Looking at the Total cases vs Population in Armenia
-- Shows percentage of population who got Covid in Armenia

select location, date, total_cases, population, (total_cases/population)*100 as percentage_of_infected_population
from CovidDeaths
where location='Armenia'
order by 1,2

--FINDING OUT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percentage_of_infected_population
from CovidDeaths
group by location, population
order by percentage_of_infected_population desc


-- FINDING OUT COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
-- USED CAST FUNCTION TO CONVERT TOTAL_DEATHS FROM VARCHAR TO INT IN ORDER TO BE ABLE TO USE AGGREGATE FUNCTION

select location, MAX(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is not null
group by location
order by total_death_count desc


--BREAKING DOWN THINGS BY CONTINENT
--the following query is showing continents with highest death count per population

select location, MAX(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is null
group by location
order by total_death_count desc

-- Looking at total population vs vaccination
--using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(convert(numeric, v.new_vaccinations)) over (partition by d.location order by d.location, d.date)
as Rolling_people_vaccinated
from CovidDeaths D
join CovidVaccinations V
On D.location=V.Location
and D.date=V.date
where d.continent is not null
)
select * , (Rolling_people_vaccinated/population)*100
From PopvsVac


--Looking at Vaccinations in Armenia  

select d.continent, d.location, d.date, v.new_vaccinations
from CovidDeaths d 
join CovidVaccinations v 
On d.location = v.location 
and d.date = v.date
where d.continent is not null 
and d.location = 'Armenia'
order by 2,3

--Creating a view for later visualizations


Create View PercentPopulationVaccinate_view as
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(convert(numeric, v.new_vaccinations)) over (partition by d.location order by d.location, d.date)
as Rolling_people_vaccinated
from CovidDeaths D
join CovidVaccinations V
On D.location=V.Location
and D.date=V.date
where d.continent is not null

Select *
From PercentPopulationVaccinated

--Creating view for total death count per location

Create view total_death_CNT_per_location as
select location, MAX(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is null
group by location
