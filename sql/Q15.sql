-- Q15
SELECT 
    o.first_name,
    o.last_name,
    a.stage_name AS artist_name,
    SUM(
        r.interpretation + r.sound_and_lighting + 
        r.stage_presence + r.organization + r.overall_impression
    ) AS total_score
FROM review r
JOIN ticket t ON r.ticket_id = t.ticket_id
JOIN owner o ON t.owner_id = o.owner_id
JOIN performance p ON r.performance_id = p.performance_id
JOIN artist a ON a.artist_id = p.artist_id
WHERE p.artist_id IS NOT NULL
GROUP BY o.owner_id, a.artist_id
ORDER BY total_score DESC
LIMIT 5;