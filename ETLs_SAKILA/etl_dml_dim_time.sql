USE sakila;
SET lc_time_names = 'es_CO';
        
INSERT IGNORE sakila_dw.dim_time SELECT DISTINCT
        DATE(pay.payment_date) AS 'complete_date',
            YEAR(pay.payment_date) AS 'year',
            MONTHNAME(pay.payment_date) AS 'month',
            DAYOFMONTH(pay.payment_date) AS 'day',
            DAYOFWEEK(pay.payment_date) AS 'week_day'
    FROM
        sakila.payment AS pay UNION SELECT DISTINCT
        DATE(ren.rental_date) AS 'complete_date',
            YEAR(ren.rental_date) AS 'year',
            MONTHNAME(ren.rental_date) AS 'month',
            DAYOFMONTH(ren.rental_date) AS 'day',
            DAYOFWEEK(ren.rental_date) AS 'week_day'
    FROM
        sakila.rental AS ren UNION SELECT DISTINCT
        DATE(inv.last_update) AS 'complete_date',
            YEAR(inv.last_update) AS 'year',
            MONTHNAME(inv.last_update) AS 'month',
            DAYOFMONTH(inv.last_update) AS 'day',
            DAYOFWEEK(inv.last_update) AS 'week_day'
    FROM
        sakila.inventory AS inv;
        

USE sakila;

SELECT DISTINCT
    DATE(pay.payment_date) AS 'complete_date',
    YEAR(pay.payment_date) AS 'year',
    MONTHNAME(pay.payment_date) AS 'month',
    DAYOFMONTH(pay.payment_date) AS 'day',
    DAYOFWEEK(pay.payment_date) AS 'week_day'
FROM
    sakila.payment AS pay 
UNION SELECT DISTINCT
    DATE(ren.rental_date) AS 'complete_date',
    YEAR(ren.rental_date) AS 'year',
    MONTHNAME(ren.rental_date) AS 'month',
    DAYOFMONTH(ren.rental_date) AS 'day',
    DAYOFWEEK(ren.rental_date) AS 'week_day'
FROM
    sakila.rental AS ren 
UNION SELECT DISTINCT
    DATE(inv.last_update) AS 'complete_date',
    YEAR(inv.last_update) AS 'year',
    MONTHNAME(inv.last_update) AS 'month',
    DAYOFMONTH(inv.last_update) AS 'day',
    DAYOFWEEK(inv.last_update) AS 'week_day'
FROM
    sakila.inventory AS inv;

SELECT DISTINCT
    customer.customer_id AS 'id_dim_customer',
    CONCAT(customer.first_name,
            ' ',
            customer.last_name) AS 'name',
    customer.active AS 'status',
    address.address AS 'address',
    city.city AS 'city',
    country.country AS 'country'
FROM
    sakila.customer
        INNER JOIN
    sakila.address ON sakila.customer.address_id = sakila.address.address_id
        INNER JOIN
    sakila.city ON sakila.address.city_id = sakila.city.city_id
        INNER JOIN
    sakila.country ON sakila.city.country_id = sakila.country.country_id;

SELECT DISTINCT
    store.store_id AS 'id_dim_store',
    address.address AS 'address',
    city.city AS 'city',
    country.country AS 'country'
FROM
    sakila.store
        INNER JOIN
    sakila.address ON sakila.store.address_id = sakila.address.address_id
        INNER JOIN
    sakila.city ON sakila.address.city_id = sakila.city.city_id
        INNER JOIN
    sakila.country ON sakila.city.country_id = sakila.country.country_id;
    
SELECT 
    staff.staff_id AS 'id_dim_staff',
    CONCAT(staff.first_name, ' ', staff.last_name) AS 'name',
    staff.store_id AS 'id_store'
FROM
    sakila.staff;
    
SELECT 
    actor.actor_id AS 'id_actor',
    CONCAT(actor.first_name, ' ', actor.last_name) AS 'name'
FROM
    sakila.actor;
   
SELECT 
    category.category_id AS 'id_category',
    category.name AS 'name'
FROM
    sakila.category;
    
SELECT 
    film.film_id AS 'id_dim_film',
    film.title AS 'title',
    language.name AS 'language'
FROM
    sakila.film
        INNER JOIN
    sakila.language ON sakila.film.language_id = sakila.language.language_id;

SELECT 
    film_actor.actor_id AS 'id_actor',
    film_actor.film_id AS 'id_film'
FROM
    sakila.film_actor;
    
SELECT 
    film_category.category_id AS 'id_category',
    film_category.film_id AS 'id_film'
FROM
    sakila.film_category;
  
SELECT 
    sakila.inventory.film_id AS 'dim_film',
    sakila.inventory.store_id AS 'dim_store',
    DATE_FORMAT(sakila.inventory.last_update, '%Y-%m-%d') AS 'dim_time',
    1 AS 'quatify'
FROM
    sakila.inventory;
    
SELECT 
    rental.customer_id AS 'dim_customer',
    inventory.film_id AS 'dim_film',
    inventory.store_id AS 'dim_store',
    DATE_FORMAT(sakila.rental.rental_date, '%Y-%m-%d') AS 'dim_time',
    rental.staff_id AS 'dim_staff',
    1 AS 'quantity_rentals'
FROM
    rental
        INNER JOIN
    sakila.inventory ON sakila.inventory.inventory_id = sakila.rental.inventory_id;

SELECT 
    payment.customer_id AS 'dim_customer',
    DATE_FORMAT(sakila.payment.payment_date, '%Y-%m-%d') AS 'dim_time',
    staff.store_id AS 'dim_store',
    payment.staff_id AS 'dim_store',
    1 AS 'quantity_sales'
FROM
    sakila.payment
        INNER JOIN
    sakila.staff ON sakila.payment.staff_id = sakila.staff.staff_id;
