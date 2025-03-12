USE sakila;

-- 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.

SELECT DISTINCT lower(title) AS film_title
	FROM film;
    
-- 2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".

SELECT lower(title) AS film_title
	FROM film 
    WHERE rating = "PG-13";

-- 3. Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en su descripción.

SELECT lower(title) AS film_title, lower(description)
	FROM film 
    WHERE description LIKE ("%amazing%");

-- 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.

SELECT lower(title) AS film_title
	FROM film 
    WHERE length > 120;

-- 5. Recupera los nombres de todos los actores.

SELECT lower(first_name) AS actor_name
	FROM actor;
    
-- 6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.

SELECT CONCAT(lower(first_name), " ", lower(last_name)) AS actor_name
	FROM actor
    WHERE last_name LIKE ("Gibson");

-- 7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.
    
SELECT lower(first_name) AS actor_name
	FROM actor
    WHERE actor_id BETWEEN 10 AND 20;

-- 8. Encuentra el título de las películas en la tabla film que no sean ni "R" ni "PG-13" en cuanto a su clasificación.

SELECT lower(title) AS film_title
	FROM film 
    WHERE rating NOT IN ("R", "PG-13");

-- 9. Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la clasificación junto con el recuento.

SELECT rating, COUNT(rating) AS num_of_films
	FROM film
    GROUP BY rating;
    
-- 10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.

SELECT CONCAT(lower(c.first_name), " ", lower(c.last_name)) AS customer_name, COUNT(c.customer_id) AS rented_films
	FROM customer AS c
    INNER JOIN rental AS r
    USING (customer_id)
    GROUP BY c.customer_id; 

-- 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.

SELECT c.name AS category, COUNT(fc.category_id) AS rented_films
	FROM rental AS r
    INNER JOIN inventory AS i
    USING (inventory_id)
    INNER JOIN film_category AS fc
    USING (film_id)
    INNER JOIN category as c
    USING(category_id)
    GROUP BY fc.category_id;

-- 12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.

SELECT rating, ROUND(AVG(length),2) AS length_in_min
	FROM film
    GROUP BY rating;

-- 13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".

SELECT CONCAT(lower(first_name), " ", lower(last_name)) AS actor_name
	FROM actor AS a
    INNER JOIN film_actor AS fa
    USING (actor_id)
    INNER JOIN film AS f
    USING(film_id)
    WHERE f.title = "Indian Love";

-- 14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.

SELECT lower(title) AS film_title
	FROM film
    WHERE description LIKE ("%dog%") OR description LIKE ("%cat%");

-- 15. Hay algún actor o actriz que no aparezca en ninguna película en la tabla film_actor.

/* En principio, la tabla intermedia y la relacion entre film y actor debería evitar esto. En cualquier caso, si hubiera alguno, aparecería con */

SELECT * 
	FROM film_actor
    WHERE film_id IS NULL;

-- 16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.

SELECT lower(title) AS film_title, release_year
	FROM film
    WHERE release_year BETWEEN 2005 AND 2010;

-- 17. Encuentra el título de todas las películas que son de la misma categoría que "Family".

SELECT lower(f.title) AS film_title
	FROM film as f
    INNER JOIN film_category AS fc
    USING (film_id)
    WHERE category_id = (
						SELECT category_id
							FROM category
							WHERE name = "Family"
    );
    
-- 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.

SELECT CONCAT(lower(a.first_name), " ", lower(a.last_name)) AS actor_name
	FROM actor AS a
    INNER JOIN film_actor AS fa
    USING (actor_id)
    GROUP BY actor_name
    HAVING COUNT(fa.film_id) > 10;
    
-- 19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla film.

SELECT lower(title)
	FROM film
    WHERE rating = "R" AND length > 120; 
    
-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y muestra el nombre de la categoría junto con el promedio de duración

SELECT c.name, ROUND(AVG(length), 2) AS avg_length_in_min
	FROM category AS c
    INNER JOIN film_category AS fc
    USING (category_id)
    INNER JOIN film AS f
    USING (film_id)
    GROUP BY (c.name)
    HAVING AVG(length) > 120;

-- 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las que han actuado.


WITH actors_in_films AS (
						SELECT CONCAT(lower(a.first_name), " ", lower(a.last_name)) AS actor_name, COUNT(fa.actor_id) AS num_of_films
							FROM actor AS a
                            INNER JOIN film_actor AS fa
                            USING (actor_id)
                            GROUP BY (fa.actor_id))
					
SELECT actor_name, num_of_films
	FROM actors_in_films
	WHERE num_of_films > 5; 

-- 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. 
-- Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego selecciona las películas correspondientes.

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

-- 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror". 
-- Utiliza una subconsulta para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.

WITH actors_in_horror AS (
						SELECT DISTINCT CONCAT(lower(a.first_name), " ", lower(a.last_name)) AS actor_name
							FROM actor as a
							INNER JOIN film_actor AS fm
							USING (actor_id)
							INNER JOIN film_category AS fc
							USING (film_id)
							INNER JOIN category AS c
							USING (category_id)
							WHERE c.name = "Horror")
    
SELECT CONCAT(lower(a.first_name), " ", lower(a.last_name)) AS actor_name
	FROM actor AS a
    WHERE CONCAT(lower(a.first_name), " ", lower(a.last_name)) NOT IN ( SELECT actor_name FROM actors_in_horror);
    
-- 24. Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla film.

SELECT lower(title) AS film
	FROM film AS f
    INNER JOIN film_category AS fm
    USING (film_id)
    INNER JOIN category AS c
    USING(category_id)
    WHERE c.name = "Comedy" AND f.length > 180;
    
##############################################################################################################################
########################################################## B O N U S #########################################################
##############################################################################################################################

-- Encuentra todos los actores que han actuado juntos en al menos una película. 
-- La consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que han actuado juntos.

/* Primero: ver los actores que comparten film_id en film_actor. 
	Se hace un self join cuando fa1.film_id = fa2.film_id y para evitar duplicados, se une solo si fa1.actor_id < fa2.actor_id. 
    Así, si el 1 y el 10 están en la misma peli, cuenta solo cuando actor1 es 1 y actor2 es 10 y no viceversa.
    
    Segundo: Agrupar por pares de actores que comparten el film_id. 
		Así podemos contar los film_id en las que aparecen juntos.
        
	Tercero: Mostrar el nombre de los actores. 
		Como se ha hecho un self join, habrá que hacer un join a cada film_actor para poder mostrar los nombres de actor1 y actor2*/
    
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