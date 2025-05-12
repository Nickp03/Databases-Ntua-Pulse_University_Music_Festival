--Q09

SELECT DISTINCT(owner_id), COUNT(event.event_id) AS event_count
FROM ticket
JOIN event ON event.event_id = ticket.event_id
GROUP BY owner_id, event.festival_id
HAVING COUNT(event.event_id) > 3
ORDER BY event_count DESC;

-- Για επιβεβαίωση τρέχουμε 
/*
select owner_id,event.event_id,festival_id from ticket join event on event.event_id=ticket.event_id where owner_id=1453 or owner_id=127 ;
+----------+----------+-------------+
| owner_id | event_id | festival_id |
+----------+----------+-------------+
|      127 |      201 |          23 |
|      127 |      204 |          23 |
|      127 |      205 |          23 |
|      127 |      206 |          23 |
|      127 |      207 |          23 |
|     1453 |      226 |          26 |
|     1453 |      227 |          26 |
|     1453 |      228 |          26 |
|     1453 |      229 |          26 |
|     1453 |      230 |          26 |
|     1453 |      251 |          28 |
+----------+----------+-------------+ 
*/