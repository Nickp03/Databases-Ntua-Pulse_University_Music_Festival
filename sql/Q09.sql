--Q09
-- Στην υλοποίηση της άσκησης θεωρούμε ότι το φεστιβάλ διεξάγεται τις ίδιες ημερομηνίες ετησίως επομένως για να μετρήσουμε τον
-- αριθμό των παραστάσεων που ένας επισκέπτης παρακολούθησε στο χρονικό διάστημα ενός χρόνου εμφανίζουμε τις παραστάσεις που 
-- παρακολούθησε ανά φεστιβάλ

-- ΔΙΝΕΙ ΠΙΝΑΚΑ ΜΕ ΤΟΥς OWNERS ΚΑΙ ΤΑ EVENTS ΠΟΥ ΕΧΟΥΝ ΠΑΡΑΚΟΛΟΥΘΗΣΕΙ ΑΝΑ ΦΕΣΤΙΒΑΛ

WITH visited_per_festival AS(
    SELECT DISTINCT owner_id,event.festival_id, COUNT(event.event_id) AS event_count
    FROM ticket
    JOIN event ON event.event_id = ticket.event_id
    WHERE ticket.activated = TRUE
    GROUP BY owner_id, event.festival_id
    HAVING COUNT(event.event_id) > 3),
    grouped_visitors AS (
        SELECT 
            event_count,
            GROUP_CONCAT(owner_id ORDER BY owner_id) AS visitors,
            COUNT(*) AS number_of_visitors
        FROM visited_per_festival
        GROUP BY event_count
        HAVING COUNT(*)>1 
    )
SELECT * FROM grouped_visitors
ORDER BY event_count DESC;



-- Για επιβεβαίωση τρέχουμε 
/*
select owner_id,event.event_id,festival_id,ticket.activated from ticket join event on event.event_id=ticket.event_id where owner_id=1453 or owner_id=127 ;

+----------+----------+-------------+-----------+
| owner_id | event_id | festival_id | activated |
+----------+----------+-------------+-----------+
|      127 |      201 |          23 |         1 |
|      127 |      204 |          23 |         1 |
|      127 |      205 |          23 |         1 |
|      127 |      207 |          23 |         1 |
|      127 |      206 |          23 |         1 |
|     1453 |      229 |          26 |         1 |
|     1453 |      230 |          26 |         1 |
|     1453 |      226 |          26 |         1 |
|     1453 |      251 |          28 |         1 |
|     1453 |      227 |          26 |         1 |
|     1453 |      228 |          26 |         1 |
+----------+----------+-------------+-----------+
*/


/*All owners with multiple tickets(events) per festival in our database
MariaDB [pulse_university]> SELECT owner_id, COUNT(event.event_id) AS event_count
    -> FROM ticket
    -> JOIN event ON event.event_id = ticket.event_id
    -> GROUP BY owner_id, event.festival_id
    -> HAVING COUNT(event.event_id) > 1
    -> ORDER BY event_count DESC;
+----------+-------------+
| owner_id | event_count |
+----------+-------------+
|      127 |           3 |
|     1453 |           3 |
|       54 |           2 |
|       69 |           2 |
|      132 |           2 |
|      310 |           2 |
|      506 |           2 |
|      540 |           2 |
|      650 |           2 |
|      905 |           2 |
|      551 |           2 |
|     1219 |           2 |
|     1260 |           2 |
|     1410 |           2 |
|     1481 |           2 |
|     1491 |           2 |
|      441 |           2 |
|      507 |           2 |
|      599 |           2 |
|      850 |           2 |
|      871 |           2 |
|      881 |           2 |
|      897 |           2 |
|      903 |           2 |
|     1023 |           2 |
|     1221 |           2 |
|     1393 |           2 |
|     1462 |           2 |
|       24 |           2 |
|      156 |           2 |
|      559 |           2 |
|      617 |           2 |
|      729 |           2 |
|      850 |           2 |
|      884 |           2 |
|     1027 |           2 |
|     1208 |           2 |
|       77 |           2 |
|      152 |           2 |
|      339 |           2 |
|      477 |           2 |
|      967 |           2 |
|     1027 |           2 |
|     1032 |           2 |
|     1092 |           2 |
|      122 |           2 |
|      617 |           2 |
|      622 |           2 |
|      629 |           2 |
|      843 |           2 |
|     1327 |           2 |
|      242 |           2 |
|     1014 |           2 |
|     1407 |           2 |
|      160 |           2 |
|      888 |           2 |
|      940 |           2 |
|     1188 |           2 |
|     1346 |           2 |
|     1370 |           2 |
|     1454 |           2 |
+----------+-------------+
61 rows in set (0.008 sec)*/