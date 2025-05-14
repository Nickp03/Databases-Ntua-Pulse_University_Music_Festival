-- Q04

-- Nested loop join without force index
/*
EXPLAIN FORMAT=JSON

SELECT artist.stage_name, AVG(review_summary.avg_interpretation) AS avg_interpretation, AVG(review_summary.avg_overall_impression) AS avg_overall_impression
FROM artist
INNER JOIN performance FORCE INDEX (PRIMARY) ON performance.artist_id = artist.artist_id
INNER JOIN review_summary ON review_summary.performance_id = performance.performance_id
WHERE artist.artist_id = 58
GROUP BY artist.artist_id, artist.stage_name;*/

-- Nested loop join with force index
/*
EXPLAIN FORMAT=JSON

SELECT artist.stage_name, AVG(review_summary.avg_interpretation) AS avg_interpretation, AVG(review_summary.avg_overall_impression) AS avg_overall_impression
FROM artist
INNER JOIN performance FORCE INDEX (PRIMARY) ON performance.artist_id = artist.artist_id
INNER JOIN review_summary ON review_summary.performance_id = performance.performance_id
WHERE artist.artist_id = 58
GROUP BY artist.artist_id, artist.stage_name;*/