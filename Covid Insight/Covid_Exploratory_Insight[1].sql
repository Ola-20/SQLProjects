select * from New_Project..covid
order by 3,4

--select * from New_Project.dbo.CovidVaccination
----order by 3,4

--1) lets count the data entry:
select count(*) from New_Project..covid
select distinct * from New_Project..covid

--2) Select important columns for data exploration

Select location, date, total_cases, new_cases, total_deaths, population
From New_Project..covid
Order by 1,2

--3) Let us see How many cases vs Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
From New_Project..covid
where location like '%canada%'
Order by 1,2
--		IT was seen that as at Aug/2022/02 the total death in canada is 42,969 and 
--		any one infected has about 15 chance of dying from the disease(compare with same period LY in Power BI)

--4) TOTAL CASES vs population (Percent of population with infection)
Select location, date, total_cases, population, (total_cases/population)*100 as infection_rate
From New_Project..covid
where location like '%canada%'
Order by 1,2
--		10% of the population has been infected

--5) Country with maximum infection rate
Select location, population, max(total_cases) as cases, max((total_cases/population))*100 as infection_rate
From New_Project..covid
group by location, population
Order by infection_rate desc
--			Faeroe Islands has the maximum infection rate ~65%

--6) Country with highest death count per population

Select location, population, max(cast(total_deaths as int)) as death, max((total_deaths/population))*100 as death_rate
From New_Project..covid
group by location, population
Order by death_rate desc
--			Peru has the highest death_rate

--7) Total death count
Select location, population, max(cast(total_deaths as int)) as death
From New_Project..covid
where continent is not null
group by location, population
Order by death desc
--			THE US has the highest as at Aug/2022/06 with death of 1030982 Deaths


--8) Let's see some continent numbers:

Select continent, max(cast(total_deaths as int)) as death
From New_Project..covid
where continent is not null
group by continent
Order by death desc

--9) WORLD STATISTICS : Daily cases and date 

Select date, sum(new_cases) as dailyCases, sum(cast(new_deaths as int)) as dailyDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentDailyDeath
From New_Project..covid
where continent is not null
group by date
Order by 1,2

--10) Total numbers world wide
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as PercenTotalDeath
From New_Project..covid
where continent is not null
--group by date
Order by 1,2
--			Total cases as at August 8 2022 IS    578Million worldwide with about 6.4Million death

--11) Infection and Vaccination (we got number of vaccination by country and percent of population vaccinated)
--		We used temp table 
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location  nvarchar(255),
date      datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(numeric,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
from New_Project..covid dea join New_Project..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

select *, (RollingVaccinated/population)*100
from #PercentPopulationVaccinated


--12) CREATing View, we may need later for visuals in Power BI

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(numeric,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
from New_Project..covid dea join New_Project..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null