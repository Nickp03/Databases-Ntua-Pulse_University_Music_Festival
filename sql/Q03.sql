-- Q03

SELECT festival.year AS festival_year, artist.stage_name, COUNT(*) AS warmup_count
FROM festival
INNER JOIN event ON event.festival_id = festival.festival_id
INNER JOIN performance ON performance.event_id = event.event_id
INNER JOIN perf_kind ON performance.kind_id = perf_kind.kind_id
INNER JOIN artist ON performance.artist_id = artist.artist_id
WHERE perf_kind.kind_name = 'warm up' AND performance.artist_id IS NOT NULL
GROUP BY festival.year, artist.stage_name
HAVING COUNT(*) > 2
ORDER BY artist.stage_name;