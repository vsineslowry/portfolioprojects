RENAME TABLE worldlifexpectancy TO world_life_expectancy;

SELECT *
FROM world_life_expectancy;

-- clean up column names --

ALTER TABLE world_life_expectancy
CHANGE COLUMN `Lifeexpectancy` `Life_Expectancy` VARCHAR(1024) NOT NULL,
CHANGE COLUMN `AdultMortality` `Adult_Mortality` bigint NOT NULL,
CHANGE COLUMN `infantdeaths` `Infant_Deaths` bigint NOT NULL,
CHANGE COLUMN `percentageexpenditure` `Percentage_Expenditure` double NOT NULL,
CHANGE COLUMN `under-fivedeaths` `Under-Five_Deaths` double NOT NULL,
CHANGE COLUMN `thinness1-19years` `Thinness_1-19_years` double NOT NULL,
CHANGE COLUMN `thinness5-9years` `Thinness_5-9_years` double NOT NULL
;

-- identify duplicate rows by concatenating Country and Year -- 

SELECT  Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY  Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year))>1;

-- use row_number and partitioning to pull out duplicates based on row_id --

SELECT *
FROM (
	SELECT Row_id,
    CONCAT(Country, Year),
    ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
    FROM world_life_expectancy
    ) AS Row_table
    WHERE Row_num > 1;
    
    -- delete rows with row_id corresponding to duplicates --
    
DELETE FROM world_life_expectancy
WHERE
	Row_id IN (
    SELECT Row_id
FROM (SELECT Row_id,
    CONCAT(Country, Year),
    ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
    FROM world_life_expectancy
    ) AS Row_table
    WHERE Row_num > 1
    );
    
SELECT *
FROM world_life_expectancy
WHERE Status = '';

-- identify blanks in Status column --

SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> '';

-- identify Countries whose status is 'Developing' --

SELECT DISTINCT(country)
FROM world_life_expectancy
WHERE Status = 'Developing';

-- use self join in order to pupulate blank Status with corresponding Status to that Country --

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.status = 'Developing'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developing'
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.status = 'Developed'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developed'
;

-- populate missing values in Life Expectancy based on the average of surrounding years --

SELECT t1.Country, t1.Year, t1.`Life_Expectancy`, 
t2.Country, t2.Year, t2.`Life_Expectancy`,
t3.Country, t3.Year, t3.`Life_Expectancy`,
ROUND((t2.`Life_Expectancy` + t3.`Life_Expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life_Expectancy` = ''
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life_Expectancy` = ROUND((t2.`Life_Expectancy` + t3.`Life_Expectancy`)/2,1)
WHERE t1.`Life_Expectancy` = ''
;

SELECT *
FROM world_life_expectancy
WHERE 'Life_Expectancy' = ''
;
