--Q14
WITH genre_appearances AS (
  SELECT 
    g.genre_id,
    g.genre_name,
    f.year,
    COUNT(*) AS total_appearances
  FROM performance p
  LEFT JOIN artist a ON p.artist_id = a.artist_id
  LEFT JOIN band b ON p.band_id = b.band_id
  JOIN genre g ON g.genre_id = COALESCE(a.genre_id, b.genre_id)
  JOIN event e ON p.event_id = e.event_id
  JOIN festival f ON e.festival_id = f.festival_id
  GROUP BY g.genre_id, g.genre_name, f.year
  HAVING COUNT(*) >= 3
),
consecutive_equal_genres AS (
  SELECT 
    ga1.genre_name,
    ga1.year AS year1,
    ga2.year AS year2,
    ga1.total_appearances
  FROM genre_appearances ga1
  JOIN genre_appearances ga2 
    ON ga1.genre_id = ga2.genre_id
    AND ga2.year = ga1.year + 1
    AND ga1.total_appearances = ga2.total_appearances
)
SELECT * FROM consecutive_equal_genres;
