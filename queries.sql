/* Query 1
  Which family movies have been rented 30 times or more?
*/
SELECT f.title AS film_title,
  c.name AS category_name,
  COUNT(*) AS rental_count
FROM film AS f
JOIN film_category AS fc
  ON f.film_id = fc.film_id
JOIN category AS c
  ON fc.category_id = c.category_id
JOIN inventory AS i
  ON f.film_id = i.film_id
JOIN rental AS r
  ON i.inventory_id = r.inventory_id
WHERE c.name IN ('Animation', 'Children', 'Classics',
'Comedy', 'Family', 'Music')
GROUP BY 1, 2
HAVING COUNT(*) >= 30
ORDER BY 3 DESC;


/* Query 2
 From Workspace + Question Set #2, Question 1
 How the two stores compare in their count of rental orders every
 month for all the years we have data for.
*/
SELECT DATE_PART('month', r.rental_date) AS rental_month,
  DATE_PART('year', r.rental_date) AS rental_year,
  s.store_id AS store_id,
  COUNT(*) AS count_rentals
FROM rental AS r
JOIN staff AS s
  ON r.staff_id = s.staff_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC;


/* Query 3
 Out of the top 10 paying customers, who made the least number of payments
 for the year and what was the total amount paid?
*/
WITH table1 AS (SELECT p.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS fullname,
  SUM(p.amount) AS pay_amount
FROM payment as p
JOIN customer as c
  ON p.customer_id = c.customer_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10)

SELECT DATE_TRUNC('year', p.payment_date) AS pay_mon,
  t1.fullname,
  COUNT(*) AS pay_countpermon,
  SUM(p.amount) AS total_amount
FROM table1 AS t1
JOIN payment AS p
  ON t1.customer_id = p.customer_id
GROUP BY 1, 2
ORDER BY 3 DESC;


/* Query 4
What is the top earning film in each category?
*/
WITH table1 AS (SELECT p.amount,
  f.title AS film_title,
  c.name AS category_name
FROM payment AS p
JOIN rental AS r
  ON p.rental_id = r.rental_id
JOIN inventory AS i
  ON i.inventory_id = r.inventory_id
JOIN film AS f
  ON f.film_id = i.film_id
JOIN film_category AS fc
  ON f.film_id = fc.film_id
JOIN category AS c
  ON fc.category_id = c.category_id),

table2 AS (SELECT t1.film_title,
  t1.category_name,
  SUM(t1.amount) AS total_amt
FROM table1 AS t1
GROUP BY 1, 2
ORDER BY 3 DESC)

SELECT *
FROM (SELECT t2.*,
  ROW_NUMBER() OVER (PARTITION BY t2.category_name ORDER BY t2.total_amt DESC) AS category_rank
FROM table2 AS t2) AS t3
WHERE t3.category_rank = 1
ORDER BY 3 DESC;
