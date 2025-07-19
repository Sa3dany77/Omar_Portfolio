# First phase the Data Cleaning Process

USE world_life_expectancy;

SELECT * 
FROM world_life_expectancy;

SELECT country, year, concat(country,year), count(concat(country,year))
FROM world_life_expectancy
GROUP BY country, year, concat(country,year)
HAVING count(concat(country,year)) > 1;

SELECT *
FROM (SELECT row_id, concat(country, year),
ROW_NUMBER() OVER ( PARTITION BY concat(country, year) ORDER BY concat(country, year)) as Row_Num
		FROM world_life_expectancy
        ) as Row_Table
WHERE Row_Num > 1;

DELETE FROM world_life_expectancy
WHERE row_id IN (SELECT row_id
FROM (SELECT row_id, concat(country, year),
ROW_NUMBER() OVER ( PARTITION BY concat(country, year) ORDER BY concat(country, year)) as Row_Num
		FROM world_life_expectancy
        ) as Row_Table
WHERE Row_Num > 1
);

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.status = 'Developing'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developing';

SELECT *
FROM world_life_expectancy
WHERE status = '' ;

 UPDATE world_life_expectancy t1
 JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.status = 'Developed'
WHERE t1.status =''
AND t2.status <> ''
AND t2.status = 'Developed';

SELECT t1.Country, t1.Year,t1.`Life expectancy`,
t2.Country, t2.Year,t2.`Life expectancy`,
t3.Country, t3.Year,t3.`Life expectancy`,
round((t2.`Life expectancy`+t3.`Life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year + 1
WHERE t1.`Life expectancy` = '';

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year + 1
SET t1.`Life expectancy` = round((t2.`Life expectancy`+t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;

# Secound phase the Exploratory Data Analysis 'EDA'

SELECT Country, MIN(`life expectancy`),
MAX(`life expectancy`),
ROUND(MAX(`life expectancy`)-MIN(`life expectancy`),1) 
AS Life_Increase_Over_15_Years
FROM world_life_expectancy
GROUP BY country
HAVING MIN(`life expectancy`) <> 0
AND MAX(`life expectancy`) <> 0
ORDER BY Life_Increase_Over_15_Years DESC;

SELECT country, ROUND(AVG(`life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY Country;

SELECT
  SUM(CASE WHEN `GDP` >= 1500 THEN 1 ELSE 0 END) AS High_GDP_Count,
  AVG(CASE WHEN `GDP` >= 1500 THEN `Life expectancy` ELSE NULL END) AS High_GDP_Life_Expectancy,
  SUM(CASE WHEN `GDP` <= 1500 THEN 1 ELSE 0 END) AS Low_GDP_Count,
  AVG(CASE WHEN `GDP` <= 1500 THEN `Life expectancy` ELSE NULL END) AS Low_GDP_Life_Expectancy
FROM world_life_expectancy;
# Higher GDP positivly correlates to a higher life expectancy

SELECT Status, ROUND(AVG(`Life expectancy`), 1)
FROM world_life_expectancy
GROUP BY Status;
# Differance in average life expectancy in Developing and Developed countries

SELECT status, COUNT(DISTINCT Country), ROUND(AVG(`Life expectancy`), 1)
FROM world_life_expectancy
GROUP BY status;

SELECT year,
`Life Expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy;

