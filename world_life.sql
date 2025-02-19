#DATA CLEANING

SELECT * FROM world_life_expectancy;

#REMOVING DUPLICATES

SELECT country, year ,COUNT(concat(Country, Year)) 
from world_life_expectancy
GROUP BY country, Year
HAVING COUNT(concat(Country, Year)) > 1
;

SELECT *
FROM
(
SELECT Row_ID,
concat(Country, Year),
ROW_NUMBER() OVER(PARTITION BY concat(Country, Year) ORDER BY concat(Country, Year)) as Row_Num 
FROM world_life_expectancy
) AS row_table
WHERE Row_num > 1
;


DELETE FROM world_life_expectancy
WHERE ROW_ID IN(
SELECT ROW_ID
FROM
	(
	SELECT Row_ID,
	concat(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY concat(Country, Year) ORDER BY concat(Country, Year)) as Row_Num 
	FROM world_life_expectancy
  	) AS row_table
WHERE Row_num > 1)
;

--
#FILLING BLANKS

SELECT *
FROM world_life_expectancy
WHERE status = ''
;


SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE status <> '';

SELECT DISTINCT(country)
FROM world_life_expectancy
WHERE status  = 'Developing';

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.Country = t2.country
SET t1.status = 'Developing'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developing'
;


UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.Country = t2.country
SET t1.status = 'Developed'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developed'
;

--

SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = '';


SELECT country, year,`Life expectancy`
FROM world_life_expectancy
#WHERE `Life expectancy` = ''
;

SELECT t1.country, t1.year,t1.`Life expectancy`,
t2.country, t2.year,t2.`Life expectancy`,
t3.country, t3.year,t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year -1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
	AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year -1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
	AND t1.Year = t3.Year + 1
SET t1.`Life expectancy`  = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
WHERE t1.`Life expectancy` = ''
;

--

SELECT *
FROM world_life_expectancy;









































