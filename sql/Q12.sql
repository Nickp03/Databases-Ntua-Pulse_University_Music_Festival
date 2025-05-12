-- Q12
SELECT 
    e.event_date,
    sr.role_name,
    COUNT(ss.staff_id) AS total_staff
FROM staff_schedule ss
JOIN event e ON ss.event_id = e.event_id
JOIN staff s ON s.staff_id = ss.staff_id
JOIN staff_role sr ON sr.role_id = s.role_id
GROUP BY e.event_date, sr.role_name
ORDER BY e.event_date, sr.role_name;