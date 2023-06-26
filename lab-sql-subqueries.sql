USE sakila;

-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT SUM(title) AS total_copies
FROM sakila.film
WHERE title = 'Hunchback Impossible';

SELECT * FROM sakila.inventory;

SELECT COUNT(*) AS total_copies
FROM sakila.film f
JOIN sakila.inventory i 
ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';

-- List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT f.title, f.length
FROM sakila.film AS f
WHERE f.length > (SELECT AVG(length) FROM sakila.film);

-- Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT a.actor_id, a.first_name, a.last_name
FROM sakila.actor a
WHERE a.actor_id IN (
  SELECT fa.actor_id
  FROM sakila.film_actor fa
  JOIN sakila.film f ON f.film_id = fa.film_id
  WHERE f.title = 'Alone Trip'
);

-- Sales have been lagging among young families, and you want to target family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT f.title
FROM sakila.film AS f
JOIN sakila.film_category fc 
ON f.film_id = fc.film_id
JOIN sakila.category AS c 
ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- Retrieve the name and email of customers from Canada using both subqueries and joins. 
-- To use joins, you will need to identify the relevant tables and their primary and foreign keys.

SELECT c.first_name, c.last_name, c.email
FROM sakila.customer AS c
WHERE c.address_id IN (
    SELECT a.address_id
    FROM sakila.address AS a
    WHERE a.city_id IN (
        SELECT ci.city_id
        FROM sakila.city AS ci
        WHERE ci.country_id IN (
            SELECT co.country_id
            FROM sakila.country AS co
            WHERE co.country = 'Canada'
        )
    )
);

SELECT c.first_name, c.last_name, c.email
FROM sakila.customer AS c
JOIN sakila.address AS a 
ON c.address_id = a.address_id
JOIN sakila.city AS ci 
ON a.city_id = ci.city_id
JOIN sakila.country AS co 
ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- Determine which films were starred by the most prolific actor in the Sakila database. 
-- A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

SELECT fa.actor_id, COUNT(*) AS film_count
FROM sakila.film_actor AS fa
GROUP BY fa.actor_id
ORDER BY film_count DESC
LIMIT 1;

SELECT f.title
FROM sakila.film AS f
JOIN sakila.film_actor fa 
ON f.film_id = fa.film_id
WHERE fa.actor_id = (SELECT actor_id
                     FROM sakila.film_actor
                     GROUP BY actor_id
                     ORDER BY COUNT(*) DESC
                     LIMIT 1);
                     
-- Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.                     

SELECT p.customer_id, SUM(p.amount) AS total_payments
FROM sakila.payment AS p
GROUP BY p.customer_id
ORDER BY total_payments DESC
LIMIT 1;

SELECT f.title
FROM sakila.film AS f
JOIN sakila.inventory AS i 
ON f.film_id = i.film_id
JOIN sakila.rental AS r 
ON i.inventory_id = r.inventory_id
WHERE r.customer_id = (SELECT customer_id
                       FROM sakila.payment
                       GROUP BY customer_id
                       ORDER BY SUM(amount) DESC
                       LIMIT 1);

-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
-- You can use subqueries to accomplish this.

SELECT customer_id, total_amount_spent
FROM (
    SELECT customer_id, SUM(amount) AS total_amount_spent
    FROM payment 
    GROUP BY customer_id
) AS subquery
WHERE total_amount_spent > (
    SELECT AVG(total_amount_spent)
    FROM (
        SELECT customer_id, SUM(amount) AS total_amount_spent
        FROM payment
        GROUP BY customer_id
    ) AS subquery_avg
);
