-- Q04

SELECT artist.stage_name, AVG(review_summary.avg_interpretation) AS avg_interpretation, AVG(review_summary.avg_overall_impression) AS avg_overall_impression
FROM artist
INNER JOIN performance ON performance.artist_id = artist.artist_id
INNER JOIN review_summary ON review_summary.performance_id = performance.performance_id
WHERE artist.artist_id = 58
GROUP BY artist.artist_id, artist.stage_name;