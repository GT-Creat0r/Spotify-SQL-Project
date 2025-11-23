-- Spotify SQL Project

DROP TABLE IF EXISTS spotify
CREATE TABLE spotify(
	artist VARCHAR(255), 
	track VARCHAR(255),
	album	VARCHAR(255),
	album_type	VARCHAR(50),
	danceability FLOAT,
	energy FLOAT,
	loudness FLOAT,
	speechiness FLOAT,
	acousticness FLOAT,
	instrumentalness FLOAT,
	liveness FLOAT,
	valence FLOAT,
	tempo FLOAT,
	duration_min FLOAT,
	title VARCHAR(255),
	channel VARCHAR(255),
	views BIGINT,
	likes BIGINT,
	comments BIGINT,
	licensed BOOLEAN,
	official_video BOOLEAN,
	stream	BIGINT,
	energyLiveness	FLOAT,
	most_playedon VARCHAR(50)
);


--EDA (Exploratory Data Analysis)
SELECT * FROM spotify;

SELECT COUNT(*)
FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT  DISTINCT album_type
FROM spotify;


SELECT MAX(duration_min)
FROM spotify ;

SELECT MIN(duration_min)
FROM spotify ;

SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min=0;

SELECT DISTINCT channel FROM spotify;

SELECT most_playedon,
	COUNT(*)
FROM spotify
GROUP BY 1;

-- ---------------------------
--Data Analysis -EASY Category
-- ---------------------------
--1.Retrieve the names of all tracks that have more than 1 billion streams.
SELECT track
FROM spotify
WHERE stream > 1000000000; 

--2. List all albums along with their respective artists.
SELECT DISTINCT album,
		artist
FROM spotify
ORDER BY 1;

--3. Get the total number of comments for tracks where licensed = TRUE.
SELECT 
	SUM(comments) AS total_comments
FROM spotify
WHERE licensed='true';

--4. Find all tracks that belong to the album type single.
SELECT *
FROM spotify
WHERE album_type='single';

--5. Count the total number of tracks by each artist.
SELECT artist,
	COUNT(track) AS total_tracks
FROM spotify
GROUP BY artist
ORDER BY 2;

-- ---------------------------
-- MEDIUM Category
-- ---------------------------
--6. Calculate the average danceability of tracks in each album.
SELECT album,
	AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;

--7. Find the top 5 tracks with the highest energy values.
SELECT track,
	MAX(energy) AS higest_energy
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--8. List all tracks along with their total views and likes where official_video = TRUE.
SELECT track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes 
FROM spotify
WHERE official_video='true'
GROUP BY 1
ORDER BY 2 DESC, 3 DESC;

--9. For each album, calculate the total views of all associated tracks.
SELECT album,
	SUM(views) AS total_views_by_album_tracks
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;

-- For each album and its track , calcuate the total views.
SELECT album,
		track,
	SUM(views) AS total_views_by_each_album_tracks
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;

--10. Retrieve the track names that have been streamed on Spotify more than YouTube.
WITH seperate_stream AS( 
SELECT 
	track,
	COALESCE(SUM(CASE WHEN most_playedon='Spotify' THEN stream END),0) AS stream_on_spotify ,
	COALESCE(SUM(CASE WHEN most_playedon='Youtube' THEN stream END),0) AS stream_on_youtube
FROM spotify
GROUP BY 1
)
SELECT *
FROM seperate_stream
WHERE stream_on_spotify > stream_on_youtube
	AND stream_on_youtube <> 0;



-- ---------------------------
-- ADVANCE Category
-- ---------------------------
--11. Find the top 3 most-viewed tracks for each artist using window functions.
WITH most_viewd
AS(
	SELECT 
		 artist,
		 track,
		 SUM(views) AS most_views,
		DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS most_viewd_rank
	FROM spotify
	GROUP BY 1,2 
)
SELECT *
FROM most_viewd 
WHERE most_viewd_rank BETWEEN 1 AND 3;

--12.Write a query to find tracks where the liveness score is above the average.
SELECT *
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

--13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH difference 
AS(
	SELECT album,
			MAX(energy) AS highest_energy_level,
			MIN(energy) AS lowest_energy_level
	FROM spotify
	GROUP BY album
)
SELECT *,(highest_energy_level-lowest_energy_level) AS diff
FROM difference;


--14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT DISTINCT album,
	track,
	(energy/liveness) AS energy_to_liveness_ratio
FROM spotify
WHERE (energy/liveness) > 1.2
ORDER BY 1;

--15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT track,
		views,
		likes,
		SUM(likes) OVER(ORDER BY views DESC) as cumulative_likes
FROM spotify
ORDER BY views DESC;   -- cleaner and readable output (Output rows are shown in the same order that cumulative sum is calculated)

