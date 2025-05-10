-- Q01

SELECT festival.year AS festival_year, ticket.method_of_purchase AS payment_method, SUM(ticket.cost) AS total_revenue
FROM festival
JOIN event ON event.festival_id = festival.festival_id
JOIN ticket ON ticket.event_id = event.event_id
GROUP BY festival.year, ticket.method_of_purchase
ORDER BY festival.year, ticket.method_of_purchase;