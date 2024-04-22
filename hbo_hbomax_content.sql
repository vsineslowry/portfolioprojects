RENAME TABLE hbo_hbomax_content.hbo_contnet TO hbo_hbomax_content.hbo_content;

SELECT *
FROM hbomax_content;

SELECT *
FROM hbo_content;

-- identify duplicates from hbomax_content--

SELECT title, `year`, CONCAT(title, `year`), COUNT(CONCAT(title, `year`))
FROM hbomax_content
GROUP BY title, `year`, CONCAT(title, `year`)
HAVING COUNT(CONCAT(title, `year`)) >1
;

SELECT *
FROM (
	SELECT `index`,
    CONCAT(title, `year`),
    ROW_NUMBER() OVER(PARTITION BY CONCAT(title, `year`) ORDER BY CONCAT(title, `year`)) AS row_num
    FROM hbomax_content
    ) AS row_table
    WHERE row_num > 1;
    
DELETE FROM hbomax_content
WHERE 
	`index` IN (
	SELECT `index`
FROM (SELECT `index`,
    CONCAT(title, `year`),
    ROW_NUMBER() OVER(PARTITION BY CONCAT(title, `year`) ORDER BY CONCAT(title, `year`)) AS row_num
    FROM hbomax_content
    ) AS row_table
    WHERE row_num > 1
    );

-- identify and delete duplicates from hbom_content--

SELECT title, `year`, CONCAT(title, `year`), COUNT(CONCAT(title, `year`))
FROM hbo_content
GROUP BY title, `year`, CONCAT(title, `year`)
HAVING COUNT(CONCAT(title, `year`)) >1
;

SELECT *
FROM (
	SELECT `index`,
    CONCAT(title, `year`),
    ROW_NUMBER() OVER(PARTITION BY CONCAT(title, `year`) ORDER BY CONCAT(title, `year`)) AS row_num
    FROM hbo_content
    ) AS row_table
    WHERE row_num > 1;
    
    DELETE FROM hbo_content
WHERE 
	`index` IN (
	SELECT `index`
FROM (SELECT `index`,
    CONCAT(title, `year`),
    ROW_NUMBER() OVER(PARTITION BY CONCAT(title, `year`) ORDER BY CONCAT(title, `year`)) AS row_num
    FROM hbo_content
    ) AS row_table
    WHERE row_num > 1
    );
    
    
-- join the two tables --

CREATE TABLE hbo_hbomax_joined AS
SELECT h.title, h.`type`, h.`year`, h.rating, h.imdb_score, h.rotten_score, h.decade, h.imdb_bucket, h.genres_Action_Adventure, h.genres_Animation, hm.genres_Anime, h.genres_Biography, h.genres_Children, h.genres_Comedy, h.genres_Crime, h.genres_Cult, h.genres_Documentary, h.genres_Drama, h.genres_Family, h.genres_Fantasy, h.genres_Food,h.`genres_Game Show`, h.genres_History, h.genres_Horror, h.genres_Independent, h.genres_LGBTQ, h.genres_Musical, h.genres_Mystery, h.genres_Reality, h.genres_Romance, h.genres_Science_Fiction, h.genres_Sport, h.genres_Stand_up_Talk, h.genres_Thriller, h.genres_Travel
FROM hbo_content h
JOIN hbomax_content hm
ON h.title = hm.title
AND h.`year`=hm.`year`
;

-- we habe a total of 1181 titles --
SELECT *
FROM hbo_hbomax_joined;

-- how many have rotten tomatoes scores? 455--

SELECT *
FROM hbo_hbomax_joined
WHERE rotten_score = 0;

-- how many have imdb scores? 42--
SELECT *
FROM hbo_hbomax_joined
WHERE imdb_score = 0;
    
SELECT *
FROM hbo_hbomax_joined
WHERE imdb_score = 0 AND rotten_score = 0;

ALTER TABLE hbo_hbomax_joined
ADD COLUMN average_score FLOAT AFTER imdb_score;

ALTER TABLE hbo_hbomax_joined
MODIFY COLUMN average_score DECIMAL(10,2);

UPDATE hbo_hbomax_joined
SET average_score = (imdb_score + (rotten_score / 10)) / 2
WHERE imdb_score != 0 AND rotten_score != 0;

UPDATE hbo_hbomax_joined
SET average_score = imdb_score
WHERE rotten_score <= 10
AND imdb_score > 0;

UPDATE hbo_hbomax_joined
SET average_score = NULL
WHERE imdb_score = 0;

SELECT *
FROM hbo_hbomax_joined;

SELECT *
FROM hbo_hbomax_joined
WHERE `type`= 'TV'
ORDER BY average_score DESC
LIMIT 15;

SELECT *
FROM hbo_hbomax_joined
WHERE `type`= ''
AND rotten_score > 0
ORDER BY average_score DESC
LIMIT 15;

SELECT *
FROM hbo_hbomax_joined
WHERE `type`= ''
AND rotten_score > 0
AND genres_Documentary=0
ORDER BY average_score DESC
LIMIT 15;



    