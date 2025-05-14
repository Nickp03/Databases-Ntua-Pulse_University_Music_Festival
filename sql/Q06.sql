-- Q06
-- SIMPLE
SET @searched_for_owner=1421;

with reviewed_performances AS(
    select owner_id,ticket.event_id,performance_id,SUM(overall_impression+interpretation+sound_and_lighting+stage_presence+organization) AS Performance_Average 
    from review
    join ticket
    on ticket.ticket_id=review.ticket_id
    where owner_id=@searched_for_owner
    group by review.performance_id)
select 
    owner_id,
    reviewed_performances.event_id,
    GROUP_CONCAT(reviewed_performances.performance_id ORDER BY reviewed_performances.performance_id) AS events_performances,
    SUM(Performance_Average)/(COUNT(*)*5) AS Event_Average
from performance
join reviewed_performances
on reviewed_performances.performance_id=performance.performance_id
group by event_id;

-- visitors to use as examples( they have reviewd multiple performances of an event): 789,729,1421









