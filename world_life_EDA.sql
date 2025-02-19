#EDA 

SELECT *
FROM world_life_expectancy;

#LIFE INCREASE FOR EACH COUNTRY THE PAST 15 YEARS

SELECT Country, 
Min(`Life expectancy`), MAX(`Life expectancy`),
ROUND(Max(`Life expectancy`)- Min(`Life expectancy`), 1) AS Life_increase
FROM world_life_expectancy
GROUP BY Country
HAVING Min(`Life expectancy`) <> 0
ORDER BY 4 DESC
;

# AVERAGE LIFE EXPECTANCY BY YEAR

SELECT year, 
ROUND(AVG(`Life expectancy`), 1)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY 2;

--

# LIFE EXPECTANCY AND GDP CORRELATION

SELECT Country, 
ROUND(AVG(`Life expectancy`),1) AS Life_exp, 
ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY country
HAVING Life_exp > 0
AND GDP > 0
ORDER BY 2
;

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) , 2) Low_GDP_Life_expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) , 2) Low_GDP_Life_expectancy
FROM world_life_expectancy
;

--

SELECT Status, 
ROUND(AVG(`Life expectancy`),1),
COUNT(DISTINCT Country)
FROM world_life_expectancy
GROUP BY Status
;

--
#LIFE EXPECTANCY AND BMI CORRELATION

SELECT Country, 
ROUND(AVG(`Life expectancy`),1) AS Life_exp, 
ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY country
HAVING Life_exp > 0
AND BMI > 0
ORDER BY BMI DESC
;

--
#ROLLING ADULT MORTALITY COUNTS BY YEAR (UNFORTONATELY NO TOTAL POPULATION DATA)

SELECT Country, Year, 
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER (PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
;




















