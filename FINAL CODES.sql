--create table matches according to ipl_matches table

create table matches(id int,city varchar,date date,player_of_match varchar,
venue varchar,neutral_venue varchar,team1 varchar,team2 varchar,
toss_winner varchar,toss_decision varchar,winner varchar,result varchar,
result_margin int,eliminator varchar,method varchar,umpire1 varchar,umpire2 varchar);

--import data to table mtaches from data set

copy matches from 'G:\IPL Dataset\IPL_matches.csv' delimiter ','csv header;

--create table deliveries from IPL_ball

create table deliveries (id int,
inning int,over int, ball int,
batsman varchar, non_striker varchar,bowler varchar,
batsman_runs int, extra_runs int,
total_runs int, is_wicket int,dismissal_kind varchar,
 player_dismissed varchar, fielder varchar,	extras_type varchar, batting_team varchar,
bowling_team varchar);



--importing data to deliveries from ipl_ball

copy deliveries from 'G:\IPL Dataset\IPL_Ball.csv' delimiter ','csv header;
select * from deliveries;
select batsman , avg(batsman_runs)  from deliveries group by batsman;



--STRIKE RATE
--SRBATS

SELECT BATSMAN,
SUM(BATSMAN_RUNS) AS TOTAL_RUNS,
COUNT(CASE WHEN EXTRAS_TYPE !='WIDES' THEN BALL END ) AS TOTAL_BALLS,
ROUND((SUM(BATSMAN_RUNS)*100/COUNT(CASE WHEN extras_type != 'wides' THEN ball END)), 2) AS STRIKE_RATE
FROM DELIVERIES
GROUP BY BATSMAN 
HAVING COUNT(CASE WHEN extras_type != 'wides' THEN ball END) >=500
ORDER BY STRIKE_RATE DESC
LIMIT 10;
SELECT * FROM SRBATS;

--AVGBATS
 
SELECT
batsman,
COUNT(DISTINCT EXTRACT(YEAR FROM matches.date)) AS seasons_played,
COUNT(INNING) AS innings_played,
SUM(batsman_runs) AS total_runs,
SUM(is_wicket) AS times_dismissed,
SUM(batsman_runs) / NULLIF(SUM(is_wicket), 0) AS batting_average
FROM DELIVERIES
JOIN Matches ON DELIVERIES.id = Matches.id
GROUP BY batsman
HAVING COUNT(DISTINCT EXTRACT(YEAR FROM matches.date)) > 2 AND SUM(is_wicket) > 2
ORDER BY batting_average DESC
LIMIT 10;

--AVERAGE OF A BATSMAN = TOTAL NUMBER OF RUNS SCORED DIVIDED BY THE NUMBER OF TIMES DISMISED
-- BATSMAN SHOUD HAVE PLAYED ATLEAST  2 SEASONS


--hsrd hitter
	
  SELECT
   batsman,
   COUNT(DISTINCT EXTRACT(YEAR FROM matches.date)) AS seasons_played,
    SUM(CASE WHEN batsman_runs = 4 THEN 1 ELSE 0 END) AS fours_count,
    SUM(CASE WHEN batsman_runs = 6 THEN 1 ELSE 0 END) AS sixes_count,
    SUM(batsman_runs) AS total_runs,
    ROUND(((SUM(CASE WHEN batsman_runs = 4 THEN 1 ELSE 0 END) * 4 + SUM(CASE WHEN batsman_runs = 6 THEN 1 ELSE 0 END) * 6) * 100.0) / NULLIF(SUM(batsman_runs), 0), 0) AS boundary_percentage
FROM deliveries
JOIN Matches ON deliveries.id = Matches.id
GROUP BY batsman
HAVING COUNT(DISTINCT EXTRACT(YEAR FROM matches.date)) > 2
ORDER BY boundary_percentage DESC;
LIMIT 10;

	  
	  
	  
	  

--


--BOWLER


--ECONOMY BOWLER

SELECT bowler, SUM(IS_WICKET) AS WICKETS,
round((SUM(total_runs) / (count(bALL)/6.0)),2) AS economy_bowler      
FROM DELIVERIES
GROUP BY bowler
HAVING COUNT(ball) >= 500  
ORDER BY economy_bowler
LIMIT 10;

--SR BOWLER


SELECT BOWLER,
SUM(IS_WICKET) AS WICKETS,
ROUND(COUNT(ball) / NULLIF(SUM(is_wicket), 0),2) AS strike_bowler
FROM DELIVERIES
GROUP BY BOWLER
HAVING COUNT(ball) >= 500  
ORDER BY STRIKE_bowler DESC
LIMIT 10;

--ALLROUNDER


SELECT
    a.batsman AS all_rounder,
    ROUND((SUM(a.batsman_runs) * 1.0 / COUNT(a.ball) * 100), 2) AS bats_strikerate,
    b.strike_bowler
FROM deliveries AS a
INNER JOIN (
    SELECT BOWLER,
           SUM(IS_WICKET) AS WICKETS,
           ROUND(COUNT(ball) / NULLIF(SUM(is_wicket), 0), 2) AS strike_bowler
    FROM DELIVERIES
    
    GROUP BY BOWLER
    HAVING COUNT(ball) >= 300
) AS b ON a.batsman = b.bowler
WHERE a.extras_type != 'wides'  -- Exclude wides here as well
GROUP BY a.batsman, b.strike_bowler
HAVING COUNT(a.ball) >= 500
ORDER BY bats_strikerate DESC, strike_bowler DESC
LIMIT 10;



--wicket keeper





SELECT fielder as wicketkeeper ,
dismissal_kind, COUNT(*) AS stumping_count
FROM deliveries
WHERE dismissal_kind = 'stumped'
GROUP BY fielder , dismissal_kind
ORDER BY stumping_count DESC
LIMIT 2;












------------------------------------------------------------------------------------------------------------------------------------------------------------------------


ADDITIONAL QUESTIONS 










1. Get the count of cities that have hosted an IPL match

select   count(distinct city) from matches;

2. Create table deliveries_v02 with all the columns of the table ‘deliveries’ and an additional
column ball_result containing values boundary, dot or other depending on the total_run

create table  deliveries_v02 
as select *, 
 case when total_runs >=4 then 'boundary' when
 total_runs =0 then 'dot' else 'other' end as ball_result
 from deliveries;
 
 
 3. Write a query to fetch the total number of boundaries and dot balls from the
deliveries_v02 table.
 
 
 
 
 select ball_result, count(ball_result)
 from deliveries_v02
 group by ball_result;
 
4. Write a query to fetch the total number of boundaries scored by each team from the
deliveries_v02 table and order it in descending order of the number of boundaries
scored
 
 
 select batting_team, count(ball_result) as boundaries from deliveries_v02
 where ball_result  = 'boundary' 
 group by batting_team
 order by  boundaries desc;
 
5. Write a query to fetch the total number of dot balls bowled by each team and order it in
descending order of the total number of dot balls bowled. 
 
select bowling_team, count(ball_result) as dot_balls from deliveries_v02
where ball_result ='dot'
group by bowling_team
order by dot_balls desc;

6. Write a query to fetch the total number of dismissals by dismissal kinds where dismissal
kind is not NA

select dismissal_kind , count(dismissal_kind) from deliveries_v02 
 where  DISMISSAL_KIND<>'NA'
group by dismissal_kind;


7. Write a query to get the top 5 bowlers who conceded maximum extra runs from the
deliveries table


 SELECT BOWLER , SUM(EXTRA_RUNS) AS EXTRAS
 FROM   deliveries_v02 
 GROUP BY BOWLER
ORDER BY EXTRAS DESC
LIMIT 5;

8. Write a query to create a table named deliveries_v03 with all the columns of
deliveries_v02 table and two additional column (named venue and match_date) of venue
and date from table matches

create table deliveries_v03  as
select a.* , b.venue , b.date from deliveries_v02 as a 
join matches as b on a.id=b.id;
select * from deliveries_v03;


9. Write a query to fetch the total runs scored for each venue and order it in the descending
order of total runs scored.


select venue , sum(total_runs) as total_runs
from
deliveries_v03
group by
venue
order by  total_runs
desc;


10. Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the
descending order of total runs scored.

select venue , sum(total_runs) as runs_scored,
extract(year from Date) as year
from deliveries_v03
where venue ='Eden Gardens'
group by venue , year
order by runs_scored
desc;







