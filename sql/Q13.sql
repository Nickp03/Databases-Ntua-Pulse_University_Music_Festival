-- Q13
SELECT 
    a.artist_id,
    a.stage_name,
    COUNT(DISTINCT l.continent) AS continents_participated
FROM performance p
JOIN artist a ON p.artist_id = a.artist_id
JOIN event e ON p.event_id = e.event_id
JOIN festival f ON e.festival_id = f.festival_id
JOIN location l ON f.location_id = l.location_id
WHERE p.artist_id IS NOT NULL
GROUP BY a.artist_id, a.stage_name
HAVING COUNT(DISTINCT l.continent) >= 3;