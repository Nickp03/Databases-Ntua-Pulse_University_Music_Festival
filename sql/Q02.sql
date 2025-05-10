-- Q02

-- Ορισμός της μεταβλητής εισόδου για το έτος
SET @input_year = 2023;

SELECT DISTINCT pulse_university.artist.stage_name, pulse_university.genre.genre_name AS genre
FROM pulse_university.artist
INNER JOIN pulse_university.genre ON pulse_university.artist.genre_id = pulse_university.genre.genre_id
INNER JOIN pulse_university.performance ON pulse_university.performance.artist_id = pulse_university.artist.artist_id
INNER JOIN pulse_university.event ON pulse_university.performance.event_id = pulse_university.event.event_id
INNER JOIN pulse_university.festival ON pulse_university.event.festival_id = pulse_university.festival.festival_id
WHERE pulse_university.festival.year = @input_year
ORDER BY pulse_university.artist.stage_name;