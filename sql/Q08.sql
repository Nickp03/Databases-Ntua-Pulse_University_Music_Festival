--Q08

SET @date='2000-06-16';

-- select all support staff that is not sceduled on the selected date
select staff_id ,staff_role.role_name
from staff
join staff_role
on staff.role_id=staff_role.role_id
WHERE staff.role_id=2 AND staff_id NOT IN (
    select staff_id 
    from staff_schedule 
    join event 
    on event.event_id=staff_schedule.event_id 
    where event.event_date=@date);

-- to see the available support staff
select staff_id,role_id from staff where role_id=2;