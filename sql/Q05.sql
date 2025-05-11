-- Q05

WITH participation_counts AS (
	SELECT artist.artist_id AS artist_id, artist.stage_name AS stage_name, COUNT(DISTINCT event.festival_id) AS festival_participations
	FROM artist
	JOIN performance ON performance.artist_id = artist.artist_id
	JOIN event ON performance.event_id = event.event_id
	WHERE TIMESTAMPDIFF(YEAR, artist.DOB, CURRENT_DATE()) < 30
GROUP BY artist.artist_id, artist.stage_name)
SELECT participation_counts.artist_id, participation_counts.stage_name, participation_counts.festival_participations
FROM participation_counts
WHERE participation_counts.festival_participations = (
	SELECT MAX(inner_counts.festival_participations)
	FROM participation_counts AS inner_counts);