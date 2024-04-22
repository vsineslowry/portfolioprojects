SELECT * 
FROM US_Project.us_household_income;

SELECT *
FROM US_Project.us_household_income_statistics;

 -- identify duplicates based on a count of ids --
 
SELECT id, COUNT(id)
 FROM US_Project.us_household_income
 GROUP BY id
 HAVING COUNT(id) > 1;
 
-- use partition to pull out row number based on id and procede to delete duplicates--

 SELECT *
 FROM (
 SELECT row_id,
 id,
 ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
 FROM US_Project.us_household_income
 ) duplicates
 WHERE row_num > 1
 ;
 
 DELETE FROM USHouseholdIncome
 WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id,
				id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
		FROM US_Project.us_household_income
		) duplicates
 WHERE row_num > 1)
 ;


-- do the same for household_income_statistics table --

SELECT id, COUNT(id)
 FROM US_Project.us_household_income_statistics
 GROUP BY id
 HAVING COUNT(id) > 1;
 
 
 -- review state names for cleanliness--
 
 SELECT State_Name, COUNT(State_Name)
 FROM us_household_income
 GROUP BY State_Name
 ORDER BY COUNT(State_Name);
 
 -- update misspelled name --
 
 UPDATE us_household_income
 SET State_Name = 'Georgia'
 WHERE State_Name = 'georia';
 
 SELECT * 
FROM US_Project.us_household_income;

-- identified null value in Place --

 SELECT Place, COUNT(Place)
 FROM us_household_income
 GROUP BY Place
 ORDER BY COUNT(Place)
;

-- identify missing place based on existing data and update the field --
SELECT * 
FROM US_Project.us_household_income
WHERE City = 'Vinemont'
;

UPDATE us_household_income
 SET Place = 'Autaugaville'
 WHERE County = 'Autauga County' 
 AND State_Name = 'Alabama';
 
 
 -- Identified mispellings in Type names --
 
SELECT Type, COUNT(Type)
 FROM us_household_income
 GROUP BY Type
 ORDER BY Type
 ;
 
 UPDATE us_household_income
 SET Type = 'Borough'
 WHERE Type = 'Boroughs'
 ;
 
UPDATE us_household_income
 SET Type = 'CDP'
 WHERE Type = 'CPD'
 ;
 
 SELECT ALand, Awater
 FROM us_household_income
 WHERE (AWater = 0 OR AWater = '' OR AWater IS NULL)

 ;
 