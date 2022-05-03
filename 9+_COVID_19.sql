-- 9+ COVID 19
-- In which we measure the impact of COVID-19

/*
1. Modify the query to show data from Spain
*/

SELECT name, DAY(whn),
 confirmed, deaths, recovered
 FROM covid
WHERE name = 'Spain'
AND MONTH(whn) = 3 AND YEAR(whn) = 2020
ORDER BY whn

/*
2. Modify the query to show confirmed for the day before.
*/

SELECT name, DAY(whn), confirmed, LAG(confirmed, 1) 
 OVER (PARTITION BY name ORDER BY whn) dbf
 FROM covid
WHERE name = 'Italy'
AND MONTH(whn) = 3 AND YEAR(whn) = 2020
ORDER BY whn

/*
3. Show the number of new cases for each day, for Italy, 
   for March.
*/

SELECT name, DAY(whn), confirmed - LAG(confirmed, 1) 
 OVER (PARTITION BY name ORDER BY whn) new
 FROM covid
WHERE name = 'Italy'
AND MONTH(whn) = 3 AND YEAR(whn) = 2020
ORDER BY whn

/*
4. Show the number of new cases in Italy for each week 
   in 2020 - show Monday only.
*/

SELECT name, DATE_FORMAT(whn,'%Y-%m-%d'), confirmed - 
LAG(confirmed,1) OVER (PARTITION BY name ORDER BY whn) new
 FROM covid
WHERE name = 'Italy'
AND WEEKDAY(whn) = 0 AND YEAR(whn) = 2020
ORDER BY whn

/* 
5. Show the number of new cases in Italy for each week 
   - show Monday only.
*/

SELECT tw.name, DATE_FORMAT(tw.whn,'%Y-%m-%d'), 
tw.confirmed - lw.confirmed
 FROM covid tw LEFT JOIN covid lw ON 
  DATE_ADD(lw.whn, INTERVAL 1 WEEK) = tw.whn
   AND tw.name=lw.name
WHERE tw.name = 'Italy'
AND WEEKDAY(tw.whn) = 0
ORDER BY tw.whn

/*
6. Include the ranking for the number of deaths in the 
   table.
*/

SELECT 
   name,
   confirmed,
   RANK() OVER (ORDER BY confirmed DESC) rc,
   deaths,
   RANK() OVER (ORDER BY deaths DESC) rc
  FROM covid
WHERE whn = '2020-04-20'
ORDER BY confirmed DESC

/*
7. Show the infect rate ranking for each country. Only 
   include countries with a population of at least 10 
   million.
*/

SELECT 
   world.name,
   ROUND(100000*confirmed/population,0), 
   RANK() OVER (ORDER BY confirmed/population) rank
  FROM covid JOIN world ON covid.name=world.name
WHERE whn = '2020-04-20' AND population > 10000000
ORDER BY population DESC

/*
8. For each country that has had at last 1000 new cases 
   in a single day, show the date of the peak number of 
   new cases.
*/

SELECT 
   name, 
   DATE_FORMAT(whn,'%Y-%m-%d'), 
   MAX(new_cases) peakNewCases 
FROM 
   (SELECT 
       covid.name, 
       covid.whn,
       covid.confirmed - LAG(covid.confirmed, 1) OVER 
	   (PARTITION BY covid.name ORDER BY covid.whn) new_cases
    FROM covid
    ORDER BY new_cases DESC) AS new_covid
WHERE new_covid.new_cases >= 1000
GROUP BY name
ORDER BY DATE_FORMAT(whn,'%Y-%m-%d')