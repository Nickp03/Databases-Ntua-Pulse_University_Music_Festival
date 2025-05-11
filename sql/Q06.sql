-- Q06
-- SIMPLE
SET @searched_for_owner=789;

select owner_id,review.ticket_id,performance_id,SUM(overall_impression+interpretation+sound_and_lighting+stage_presence+organization)/5 AS Average 
from review 
join ticket 
on ticket.ticket_id=review.ticket_id 
where owner_id=@searched_for_owner
group by owner_id,performance_id 
order by owner_id,performance_id;

--FORCE INDEX
SET @searched_for_owner=789;

select owner_id,review.ticket_id,performance_id,SUM(overall_impression+interpretation+sound_and_lighting+stage_presence+organization)/5 AS Average 
from review force index (review_ticket)
join ticket force index (tick_id)
on ticket.ticket_id=review.ticket_id 
where owner_id=@searched_for_owner
group by owner_id,performance_id 
order by owner_id,performance_id;


-- owners to use as examples:
-- to ensure they have reviewed multiple performances run
-- select owner_id,count(performance_id) from review join ticket on ticket.ticket_id=review.ticket_id group by owner_id having count(owner_id)>1;
-- +----------+-----------------------+
-- | owner_id | count(performance_id) |
-- +----------+-----------------------+
-- |        5 |                     3 |
-- |       42 |                     2 |
-- |       51 |                     2 |
-- |       80 |                     2 |
-- |      126 |                     2 |
-- |      160 |                     2 |
-- |      315 |                     2 |
-- |      349 |                     2 |
-- |      373 |                     2 |
-- |      482 |                     2 |
-- |      489 |                     2 |
-- |      547 |                     2 |
-- |      593 |                     2 |
-- |      729 |                     2 |
-- |      730 |                     2 |
-- |      740 |                     2 |
-- |      789 |                     3 |
-- |      849 |                     2 |
-- |     1118 |                     2 |
-- |     1166 |                     2 |
-- |     1188 |                     2 |
-- |     1213 |                     2 |
-- |     1245 |                     3 |
-- |     1253 |                     2 |
-- |     1328 |                     2 |
-- |     1333 |                     2 |
-- |     1421 |                     3 |
-- |     1449 |                     2 |
-- +----------+-----------------------+