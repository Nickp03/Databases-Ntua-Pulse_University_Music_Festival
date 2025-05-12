--Q07

SELECT festival_id,SUM(staff.level_id)/COUNT(staff.level_id) AS Average_experience_level
FROM event
JOIN staff_schedule
ON event.event_id=staff_schedule.event_id
JOIN staff
ON staff.staff_id=staff_schedule.staff_id
WHERE staff_schedule.role_id=4
GROUP BY festival_id
ORDER BY Average_experience_level ASC
LIMIT 1;

