--Q07

select festival_id,SUM(staff.level_id)/COUNT(staff.level_id) AS Average_experience_level
from event
join staff_schedule
on event.event_id=staff_schedule.event_id
join staff
on staff.staff_id=staff_schedule.staff_id
where staff_schedule.role_id=4
group by festival_id
order by Average_experience_level asc
limit 1;

