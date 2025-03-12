USE sakila;

SELECT DISTINCT lower(title) AS film_title
	FROM film;
    
SELECT lower(title) AS film_title
	FROM film 
    WHERE rating = "PG-13";


SELECT lower(title) AS film_title, lower(description)
	FROM film 
    WHERE description LIKE ("%amazing%");


SELECT lower(title) AS film_title
	FROM film 
    WHERE length > 120;


SELECT lower(first_name) AS actor_name
	FROM actor;
    

SELECT CONCAT(lower(first_name), " ", lower(last_name)) AS actor_name
	FROM actor
    WHERE last_name LIKE ("Gibson");

    
SELECT lower(first_name) AS actor_name
	FROM actor
    WHERE actor_id BETWEEN 10 AND 20;


SELECT lower(title) AS film_title
	FROM film 
    WHERE rating NOT IN ("R", "PG-13");


SELECT rating, COUNT(rating) AS num_of_films
	FROM film
    GROUP BY rating;
    

SELECT c.customer_id, CONCAT(lower(c.first_name), " ", lower(c.last_name)) AS customer_name, COUNT(c.customer_id) AS rented_films
	FROM customer AS c
    INNER JOIN rental AS r
    USING (customer_id)
    GROUP BY c.customer_id; 

SELECT c.name AS category, COUNT(fc.category_id) AS rented_films
	FROM rental AS r
    INNER JOIN inventory AS i
    USING (inventory_id)
    INNER JOIN film_category AS fc
    USING (film_id)
    INNER JOIN category as c
    USING(category_id)
    GROUP BY fc.category_id;


SELECT rating, ROUND(AVG(length),2) AS length_in_min
	FROM film
    GROUP BY rating;


SELECT CONCAT(lower(first_name), " ", lower(last_name)) AS actor_name
	FROM actor AS a
    INNER JOIN film_actor AS fa
    USING (actor_id)
    INNER JOIN film AS f
    USING(film_id)
    WHERE f.title = "Indian Love";


SELECT lower(title) AS film_title
	FROM film
    WHERE description LIKE ("%dog%") OR description LIKE ("%cat%");


SELECT * 
	FROM film_actor
    WHERE film_id IS NULL;

SELECT lower(title) AS film_title
	FROM film
    WHERE release_year BETWEEN 2005 AND 2010;


SELECT lower(f.title) AS film_title
	FROM film as f
    INNER JOIN film_category AS fc
    USING (film_id)
    WHERE category_id = (
						SELECT category_id
							FROM category
							WHERE name = "Family"
    );


SELECT CONCAT(lower(a.first_name), " ", lower(a.last_name)) AS actor_name
	FROM actor AS a
    INNER JOIN film_actor AS fa
    USING (actor_id)
    GROUP BY actor_name
    HAVING COUNT(fa.film_id) > 10;
    

SELECT lower(title)
	FROM film
    WHERE rating = "R" AND length > 120; 
    

SELECT c.name, ROUND(AVG(length), 2) AS avg_length_in_min
	FROM category AS c
    INNER JOIN film_category AS fc
    USING (category_id)
    INNER JOIN film AS f
    USING (film_id)
    GROUP BY (c.name)
    HAVING AVG(length) > 120;


WITH actors_in_films AS (
						SELECT CONCAT(lower(a.first_name), " ", lower(a.last_name)) AS actor_name, COUNT(fa.actor_id) AS num_of_films
							FROM actor AS a
                            INNER JOIN film_actor AS fa
                            USING (actor_id)
                            GROUP BY (fa.actor_id))
					
SELECT actor_name, num_of_films
	FROM actors_in_films
	WHERE num_of_films > 5; 


SELECT DISTINCT lower(f.title) AS film_title
	FROM rental AS r
    INNER JOIN inventory AS i
    USING (inventory_id)
    INNER JOIN film AS f
    USING (film_id)
    WHERE r.rental_id IN (
							SELECT rental_id
							FROM rental
							WHERE TIMESTAMPDIFF(DAY, rental_date, return_date) > 5
);

WITH actors_in_horror AS (
						SELECT DISTINCT CONCAT(lower(a.first_name), " ", lower(a.last_name)) AS actor_name
							FROM actor as a
							INNER JOIN film_actor AS fa
							USING (actor_id)
							INNER JOIN film_category AS fc
							USING (film_id)
							INNER JOIN category AS c
							USING (category_id)
							WHERE c.name = "Horror")
    
SELECT CONCAT(lower(a.first_name), " ", lower(a.last_name)) AS actor_name
	FROM actor AS a
    WHERE CONCAT(lower(a.first_name), " ", lower(a.last_name)) NOT IN ( SELECT actor_name FROM actors_in_horror);
    

SELECT lower(title) AS film
	FROM film AS f
    INNER JOIN film_category AS fm
    USING (film_id)
    INNER JOIN category AS c
    USING (category_id)
    WHERE c.name = "Comedy" AND f.length > 180;
    
    
SELECT CONCAT(lower(a1.first_name), " ", lower(a1.last_name)) AS actor_1, CONCAT(lower(a2.first_name), " ", lower(a2.last_name)) AS actor_2, COUNT(fa1.film_id) AS films_together
	FROM film_actor AS fa1
    INNER JOIN film_actor AS fa2
    ON fa1.film_id = fa2.film_id
    AND fa1.actor_id < fa2.actor_id
    INNER JOIN actor AS a1
    ON fa1.actor_id = a1.actor_id
    INNER JOIN actor AS a2
    ON fa2.actor_id = a2.actor_id
    GROUP BY actor_1, actor_2;