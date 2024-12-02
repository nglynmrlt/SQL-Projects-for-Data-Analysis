---1. How many Olympics games have been held?
Select count(distinct Games)
from dbo.athlete

---2. List down all Olympics games held so far
Select games
from dbo.athlete
group by Games

---3. Mention the total number of nations who participated in each Olympics game?
Select NOC, count(NOC) as #ofTeams
from dbo.athlete
group by NOC
Order by #ofTeams DESC

---4. Which year saw the highest and lowest no of countries participating in olympics?
---Lowest was on 1896 while the highest was on 2016
Select Year, count(distinct NOC) as #ofTeams
from dbo.athlete
group by Year
Order by #ofTeams DESC

---5. Which nation has participated in all of the olympic games?
Select N.region
from dbo.athlete as A
JOIN dbo.noc_regions as N
	on a.noc = n.NOC
	group by N.region
Having Count (distinct Games) = (Select Count (Distinct Games) from dbo.athlete)

---6. Identify the sport which was played in all summer olympics
Select Sport as 'Sport During Summmer'
from dbo.athlete
WHERE Season = 'Summer'
Group by Sport

---7. Which Sports were just played only once in the olympics?
Select Sport as Played_Once, Count (Distinct Year) as #
from dbo.athlete
Group by Sport
Having Count (Distinct Year) = 1

---8. Fetch the total no of sports played in each olympic games
Select Games, count (Distinct Sport) as #ofSport
from dbo.athlete
group by Games
Order by #ofSport DESC

---9. Fetch details of the oldest athletes to win a gold medal.
Select Top 1 *
from dbo.athlete
WHERE MEDAL = 'gold'  and Age <> 'NA'
ORDER BY Age DESC

---10. Find the Ratio of male and female athletes participated in all olympic games.
Select top 1
	(Select count(*) from dbo.athlete where Sex = 'M') * 1.0 /
	(Select count(*) from dbo.athlete where Sex = 'F') as 'Male to Female Ratio',
	(Select count(*) from dbo.athlete where Sex = 'F') * 1.0 /
	(Select count(*) from dbo.athlete where Sex = 'M') as 'Female to Male Ratio'
from dbo.athlete
Group by Sex

---10. Find the # of male and female athletes participated in all olympic games.
Select Sex, count(*) as #ofGender
from dbo.athlete
Group by Sex

---11. Fetch the top 5 athletes who have won the most gold medals.
Select Top 5 Name, count (Medal) as #ofMedals
from dbo.athlete
WHERE MEDAL = 'gold'
Group by Name
Order by #ofMedals DESC

---12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
Select  Top 5 Name, count (Medal) as #ofMedals
from dbo.athlete
WHERE MEDAL <> 'NA'
Group by Name
Order by #ofMedals DESC

---13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
Select Top 5 NOC as Country, count (Medal) as #ofMedals
from dbo.athlete
WHERE MEDAL <> 'NA'
Group by NOC
Order by #ofMedals DESC

---14. List down total gold, silver and broze medals won by each country.
SELECT N.Region as Country,
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GoldMedals,
    SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS SilverMedals,
    SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS BronzeMedals
FROM dbo.athlete as A
JOIN dbo.noc_regions as N
	on A. NOC = N.NOC
GROUP BY N.Region
ORDER BY N.Region

---15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.
SELECT N.Region as Country, A.Games,
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GoldMedals,
    SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS SilverMedals,
    SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS BronzeMedals
FROM dbo.athlete as A
JOIN dbo.noc_regions as N
	on A. NOC = N.NOC
GROUP BY N.Region, A.Games
ORDER BY N.Region, A.Games

---16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
---GOLD (Top 5)
SELECT Top 5 N.Region as Country,  A.Games,
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GoldMedals
FROM dbo.athlete as A
JOIN dbo.noc_regions as N
	on A. NOC = N.NOC
GROUP BY N.Region, A.Games
Having SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) = (
	Select Max(GoldCount)
		from (Select N.Region, A.Games, SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GoldCount
	from dbo.athlete as A
	JOIN dbo.noc_regions as N
	on A. NOC = N.NOC
	GROUP BY N.Region, A.Games) as GoldperGame
	WHERE GoldperGame.Games = A.Games)
Order By GoldMedals DESC

---SILVER (Top 5)
SELECT Top 5 N.Region as Country,  A.Games,
    SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS SilverMedals
FROM dbo.athlete as A
JOIN dbo.noc_regions as N
	on A. NOC = N.NOC
GROUP BY N.Region, A.Games
Having SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) = (
	Select Max(SilverCount)
		from (Select N.Region, A.Games, SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS SilverCount
	from dbo.athlete as A
	JOIN dbo.noc_regions as N
	on A. NOC = N.NOC
	GROUP BY N.Region, A.Games) as SilverperGame
	WHERE SilverperGame.Games = A.Games)
Order By SilverMedals DESC

---BRONZE (Top 5)
SELECT Top 5 N.Region as Country,  A.Games,
    SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS BronzeMedals
FROM dbo.athlete as A
JOIN dbo.noc_regions as N
	on A. NOC = N.NOC
GROUP BY N.Region, A.Games
Having SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) = (
	Select Max(BronzeCount)
		from (Select N.Region, A.Games, SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS BronzeCount
	from dbo.athlete as A
	JOIN dbo.noc_regions as N
	on A. NOC = N.NOC
	GROUP BY N.Region, A.Games) as BronzeperGame
	WHERE BronzeperGame.Games = A.Games)
Order By BronzeMedals DESC

---17. most medals in each olympic games
SELECT Top 5 N.Region as Country,  A.Games,
    SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS ALLMedals
FROM dbo.athlete as A
JOIN dbo.noc_regions as N
	on A. NOC = N.NOC
GROUP BY N.Region, A.Games
Having SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) = (
	Select Max(ALLMedalsCount)
		from (Select N.Region, A.Games, SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS ALLMedalsCount
	from dbo.athlete as A
	JOIN dbo.noc_regions as N
	on A. NOC = N.NOC
	GROUP BY N.Region, A.Games) as ALLMedalsGame
	WHERE ALLMedalsGame.Games = A.Games)
Order By ALLMedals DESC

---18. Which countries have never won gold medal but have won silver/bronze medals?
Select DISTINCT NOC as Country,
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GoldMedals,
    SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS SilverMedals,
    SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS BronzeMedals
from dbo.athlete 
WHERE NOC NOT IN (
	SELECT DISTINCT NOC
	from dbo.athlete
	where Medal = 'Gold'
	)
and MEDAL IN ('Silver', 'Bronze')
GROUP BY NOC

---19. In which Sport/event, India has won highest medals.
Select A.Sport, N.Region, Count (*) as ALLMedals,
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GoldMedals,
    SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS SilverMedals,
    SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS BronzeMedals
from dbo.athlete as A
JOIN dbo.noc_regions as N
on A. NOC = N.NOC
WHERE N.region = 'india' and MEDAL <> 'NA'
Group by A.Sport, N.Region
Order by ALLMedals DESC

---20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games
SELECT A.Sport, A.Games, Count (*) as ALLMedals,
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GoldMedals,
    SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS SilverMedals,
    SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS BronzeMedals
FROM dbo.athlete as A
JOIN dbo.noc_regions as N
	on A. NOC = N.NOC
WHERE N.region = 'india' and MEDAL <> 'NA' and Sport = 'Hockey'
GROUP BY  A.Games, A.Sport
ORDER BY ALLMedals Desc