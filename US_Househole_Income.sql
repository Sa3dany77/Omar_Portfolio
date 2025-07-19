# First phase is the Data Cleaning Process

USE us_project;

SELECT * 
FROM us_household_income;

SELECT * 
FROM us_project.us_household_income_statistics;

ALTER TABLE us_household_income_statistics RENAME COLUMN `ï»¿id` TO `ID`;

SELECT ID,COUNT(ID)
FROM us_household_income
GROUP BY ID
HAVING COUNT(ID) > 1;

SELECT *
FROM (
SELECT row_id,
ID,
ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID) as row_num
FROM us_household_income
) as Duplicates
WHERE row_num > 1;

DELETE FROM us_household_income
WHERE row_id IN
(SELECT row_id
	FROM (
	SELECT row_id,
			ID,
		ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID) as row_num
	FROM us_household_income
		) as Duplicates
	WHERE row_num > 1);

SELECT state_name, COUNT(state_name)
FROM us_household_income
GROUP BY state_name;

UPDATE us_household_income
SET state_name = 'Georgia'
WHERE state_name = 'georia';

UPDATE us_household_income
SET state_name = 'Alabama'
WHERE state_name = 'alabama';

UPDATE us_household_income
SET place = 'Autaugaville'
WHERE city = 'Vinemont'
AND county = 'Autauga County';

UPDATE us_household_income
SET type = 'Borough'
WHERE type = 'Boroughs';

# Secound the Exploratory Data Analysis Phase "EDA"

SELECT state_name, SUM(aland), SUM(awater)
FROM us_household_income
GROUP BY state_name
ORDER BY 2 DESC;
# Comparing which state has most land area and water access

SELECT state_name, SUM(aland), SUM(awater)
FROM us_household_income
GROUP BY state_name
ORDER BY 2 DESC
Limit 10;
# TOP 10 States by Land area

SELECT u.state_name, ROUND(AVG(mean),1), ROUND(AVG(median),1)
FROM us_household_income u
JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE mean <> 0
GROUP BY u.state_name
ORDER By 2 DESC
LIMIT 10;
# Top income States

SELECT u.state_name, city, ROUND(AVG(mean),1)
FROM us_household_income u
JOIN us_household_income_statistics us
	ON u.id = us.id
GROUP BY u.state_name, city
ORDER BY ROUND(AVG(mean),1) DESC
LIMIT 10;
# Top income Cities in the US

