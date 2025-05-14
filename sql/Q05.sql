-- Q05

WITH participation_counts AS (
	SELECT a.artist_id, a.stage_name, TIMESTAMPDIFF(YEAR, a.DOB, CURDATE()) AS age, COUNT(p.performance_id) AS performance_count
	FROM artist AS a
	JOIN performance AS p ON p.artist_id = a.artist_id
	JOIN event AS e ON p.event_id = e.event_id
	WHERE TIMESTAMPDIFF(YEAR, a.DOB, CURDATE()) < 30
	GROUP BY a.artist_id, a.stage_name)
SELECT pc.stage_name, pc.age, pc.performance_count
FROM participation_counts AS pc
WHERE pc.performance_count = (SELECT MAX(performance_count) FROM participation_counts);