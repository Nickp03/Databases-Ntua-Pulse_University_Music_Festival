-- Q01

SELECT f.year AS festival_year,
    COALESCE(SUM(CASE WHEN t.method_of_purchase = 'bank_account' THEN t.cost END), 0) AS bank_account,
    COALESCE(SUM(CASE WHEN t.method_of_purchase = 'credit' THEN t.cost END), 0) AS credit,
    COALESCE(SUM(CASE WHEN t.method_of_purchase = 'debit' THEN t.cost END), 0) AS debit,
    SUM(t.cost) AS total_revenue
FROM festival AS f
JOIN event AS e ON e.festival_id = f.festival_id
JOIN ticket AS t ON t.event_id = e.event_id
GROUP BY f.year
ORDER BY f.year;