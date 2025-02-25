-- #DATA CLEANING

SELECT *
FROM us_household_income;

SELECT *
FROM ushousehold_statistics;

--

ALTER TABLE ushousehold_statistics
RENAME COLUMN `ï»¿id` TO `id`;

-- # REMOVING DUPLICATES

SELECT id, count(id)
FROM us_household_income
GROUP BY 1
HAVING count(id) > 1;

SELECT *
FROM 
	(
	SELECT row_id,id, ROW_NUMBER() OVER(PARTITION BY id ) as num
	FROM us_household_income) AS COUNTS
WHERE num > 1;

DELETE FROM us_household_income
WHERE row_id IN(
SELECT row_id
FROM 
	(
	SELECT row_id, id, ROW_NUMBER() OVER(PARTITION BY id ) as num
	FROM us_household_income) AS COUNTS
WHERE num > 1);


SELECT id, count(id)
FROM ushousehold_statistics
GROUP BY 1
HAVING count(id) > 1;

-- #Fixing names

SELECT State_Name,COUNT(State_name)
FROM us_household_income
GROUP BY 1
ORDER BY 2;

UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';


SELECT Type,COUNT(State_name)
FROM us_household_income
GROUP BY 1
ORDER BY 2;


SELECT * 
FROM us_household_income
WHERE Place = '';

SELECT *
FROM us_household_income
WHERE County = 'Autauga County'
;

UPDATE us_household_income
SET place = 'Autaugaville'
WHERE county = 'Autauga County'
AND City = 'Vinemont';


SELECT Type, Count(*)
FROM us_household_income
GROUP BY 1
order by 2
;


UPDATE us_household_income
SET Type = 'CDP'
WHERE Type = 'CPD'
;

UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;

SELECT ALand, AWater
FROM us_household_income
WHERE (ALand = 0 OR ALand = '' OR  ALand IS NULL) AND
 (AWater = 0 OR AWater = '' OR  AWater IS NULL)
;


SELECT *
FROM ushousehold_statistics
WHERE Stdev = 0;
 
 
UPDATE ushousehold_statistics
SET stdev = NULL
WHERE stdev = 0
;
 
 
 


















