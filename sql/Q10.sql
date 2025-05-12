--Q10

WITH Pairs AS (
    SELECT artist_id, GROUP_CONCAT(genre_id ORDER BY genre_id) AS pairs
    FROM artist_genre
    GROUP BY artist_id
    HAVING COUNT(*) > 1
)
SELECT pairs, COUNT(*) AS frequency
FROM Pairs 
GROUP BY pairs
ORDER BY frequency DESC
LIMIT 3;

