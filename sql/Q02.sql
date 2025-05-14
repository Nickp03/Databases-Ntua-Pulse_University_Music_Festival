-- Q02

-- Ορισμός των μεταβλητών εισόδου για το έτος και το είδος
SET @input_year = 2021;
SET @input_genre = 'rock';

SELECT a.stage_name, g.genre_name AS genre, CASE WHEN f_in.year IS NOT NULL THEN 'Ναι' ELSE 'Όχι' END AS Συμμετείχε
FROM artist AS a
JOIN artist_genre AS ag ON a.artist_id = ag.artist_id
JOIN genre AS g ON ag.genre_id = g.genre_id AND g.genre_name = @input_genre -- Κρατάμε καλλιτέχνες ίδιου είδους
LEFT JOIN (
    SELECT DISTINCT p.artist_id, f.year
    FROM performance AS p
    JOIN event AS e ON p.event_id = e.event_id
    JOIN festival AS f ON e.festival_id = f.festival_id
    WHERE f.year = @input_year) AS f_in ON a.artist_id = f_in.artist_id -- Προσωρινός πίνακας με όλους τους καλλιτέχνες που είχαν εμφάνιση στο φεστιβάλ του έτους
ORDER BY a.stage_name;