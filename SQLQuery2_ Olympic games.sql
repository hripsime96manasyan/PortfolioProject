--Analysing a historical dataset on the modern Olympic Games, including all the Games from Athens 1896 to Rio 2016
--2 tables uploaded in the database: Olympics_history and Olympics_history_noc_regions

select * from olympics_history
select * from noc_regions_olympics_history

--Writing a query to see how many olympics games have been held.

 select count(distinct games) as total_olympic_games
 from olympics_history

 --Listing down all Olympics games held so far

 select distinct (year), season, city
 from olympics_history
 order by year asc

 --Mentioning the total no of nations who participated in each olympics game

select games, count(distinct region) as total_countries
from olympics_history o
join noc_regions_olympics_history nr
on o.noc=nr.noc
group by games
order by games asc

--Finding out which year saw the highest and lowest no of countries participating in olympics

 with all_countries as
              (select games, nr.region
              from olympics_history o
              join noc_regions_olympics_history nr 
			  on nr.noc=o.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1


-- writing a query that will return which nation has participated in all of the olympic games

 with tot_games as
              (select count(distinct games) as total_games
              from olympics_history),
          countries as
              (select games, nr.region as country
              from olympics_history o
              join noc_regions_olympics_history nr ON nr.noc=o.noc
              group by games, nr.region),
          countries_participated as
              (select country, count(1) as total_participated_games
              from countries
              group by country)
      select cp.*
      from countries_participated cp
      join tot_games tg on tg.total_games = cp.total_participated_games
      order by 1

-- writing a query to identify the sport which was played in all summer olympics

 with t1 as
          	(select count(distinct games) as total_games
          	from olympics_history where season = 'Summer'),
          t2 as
          	(select distinct games, sport
          	from olympics_history where season = 'Summer'),
          t3 as
          	(select sport, count(1) as no_of_games
          	from t2
          	group by sport)
      select *
      from t3
      join t1 on t1.total_games = t3.no_of_games

--writing a query to fetch oldest athletes to win a gold medal


 with temp as
            (select name,sex,cast(case when age = 'NA' then '0' else age end as int) as age
              ,team,games,city,sport, event, medal from olympics_history),
    ranking as
            (select *, rank() over(order by age desc) as rnk from temp
    where medal='Gold')
    select *
    from ranking
    where rnk = 1


--Writing a query to fetch the top 5 athletes who have won the most medals (gold/silver/bronze)

with t1 as
            (select name, team, count(1) as total_medals
            from olympics_history
            where medal in ('Gold', 'Silver', 'Bronze')
            group by name, team),
        t2 as
            (select *, dense_rank() over (order by total_medals desc) as rnk
            from t1)
    select name, team, total_medals
    from t2
    where rnk <= 5

--Query to show in which Sport/event, Armenia has won highest medals

with t1 as
        	(select sport, count(1) as total_medals
        	from olympics_history
        	where medal <> 'NA'
        	and team = 'Armenia'
        	group by sport),
        t2 as
        	(select *, rank() over(order by total_medals desc) as rnk
        	from t1)
    select sport, total_medals
    from t2
    where rnk = 1


-- Breaking down all olympic games where Armenia won medal for Weightlifting and how many medals in each olympic games was won.

select team, sport, games, count(1) as total_medals
    from olympics_history
    where medal <> 'NA'
    and team = 'Armenia' and sport = 'Weightlifting'
    group by team, sport, games
    order by total_medals desc

-- Top 5 most successful countries in olympics. Success is defined by no of medals won.

 with t1 as
            (select nr.region, count(1) as total_medals
            from olympics_history o
            join noc_regions_olympics_history nr on nr.noc = o.noc
            where medal <> 'NA'
            group by nr.region),
        t2 as
            (select *, dense_rank() over(order by total_medals desc) as rnk
            from t1)
    select *
    from t2
    where rnk <= 5