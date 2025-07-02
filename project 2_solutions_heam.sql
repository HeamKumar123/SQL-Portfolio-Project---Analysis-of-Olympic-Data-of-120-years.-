
select top 5 * from athletes
Select top 5 * from athlete_events

--1 which team has won the maximum gold medals over the years.

select top 1 team, sum (gold_medals) as No_of_gold_medals 
from
(
select a.team, e.year, count(distinct event) as gold_medals
from athletes a join athlete_events e
on a.id=e.athlete_id
where e.medal='gold'
group by a.team, e.year)
as A
group by team 
order by No_of_gold_medals desc;


--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

with cte1 as(
select a.team,e.year, count(distinct event) as no_of_silver_medals, dense_rank () over (partition by a.team order by count( distinct event) desc ) as Rnk 
from athletes a join athlete_events e
on a.id=e.athlete_id
where e.medal='Silver'
group by a.team,e.year)
select team, sum (no_of_silver_medals) as total_silver_medals, max(case when rnk=1 then YEAR end) as year_of_max_silver
from cte1
group by team ;

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years


select top 1 athlete_id, count (event) as No_of_gold_medals
from athlete_events
where athlete_id not in (select distinct athlete_id from athlete_events where medal in ('Silver','bronze')) and medal='Gold'
group by athlete_id
order by No_of_gold_medals desc


--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

with cte1 as (
select a.name,e.year, count (event) as No_of_gold_medals ,dense_rank () over (partition by year order by count (event) desc) as Rnk1
from athletes a join athlete_events e
on a.id=e.athlete_id
where medal='gold'
group by a.name,e.year)
select year,  No_of_gold_medals, STRING_AGG(name,',' ) within group (order by name) as players_name
from cte1
where Rnk1=1
group by year, No_of_gold_medals;

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

Select distinct medal,year, sport 
from (
select sport ,medal,year,RANK () over (partition by medal order by year) as rnk1
from athletes a join athlete_events e
on a.id=e.athlete_id
where a.team='India' and medal is not null)As A
where rnk1=1;

--6 find players who won gold medal in summer and winter olympics both.

select  athlete_id
from athlete_events
where medal='gold'
group by athlete_id 
having COUNT(distinct season)=2 

----7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

select athlete_id, year
from athlete_events
where medal is not null
group by athlete_id, year
having count (distinct medal)=3;

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.


with cte as
(
select a.name, year, event, count (event) as No_of_medals
from 
athlete_events join athletes a on athlete_events.athlete_id=a.id
where year>1999 and medal='gold' and season='summer'
group by a.name, year, event
)
Select name, event from
(
select name, year ,event, 
lag(year,1) over  (partition by name, event order by year) as pr,
lead(year,1) over (partition by name, event order by year) as next
from cte) 
As A
where year=pr+4 and year=next-4;


