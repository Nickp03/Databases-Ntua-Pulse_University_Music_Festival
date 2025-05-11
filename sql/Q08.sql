--Q08

SET @date='2000-06-16'

SELECT DISTINCT staff_id
FROM staff_schedule
WHERE staff_id NOT IN (
    SELECT staff_id
    FROM staff_schedule 
    JOIN event 
    ON event.event_id = staff_schedule.event_id
    WHERE event.event_date = @date
);