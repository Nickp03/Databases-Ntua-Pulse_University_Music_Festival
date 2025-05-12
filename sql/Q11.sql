--Q11
WITH artist_counts AS (
    SELECT 
        artist_id,
        COUNT(*) AS appearances
    FROM performance
    WHERE artist_id IS NOT NULL
    GROUP BY artist_id
),
max_appearances AS (
    SELECT MAX(appearances) AS max_app FROM artist_counts
)
SELECT 
    a.artist_id,
    a.stage_name,
    ac.appearances
FROM artist_counts ac
JOIN artist a ON a.artist_id = ac.artist_id
JOIN max_appearances ma ON ac.appearances <= ma.max_app - 5;
