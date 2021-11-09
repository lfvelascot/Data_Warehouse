USE sakila;
SET lc_time_names = 'es_CO';

-- Select DIM_TIME
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

-- Select DIM_CUSTOMER
SELECT DISTINCT
    customer.customer_id AS 'id_dim_customer',
    CONCAT(customer.first_name,
            ' ',
            customer.last_name) AS 'name',
    customer.active AS 'status',
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

-- SELECT DIM_STORE
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

-- SELECT DIM_STAFF    
SELECT 
    staff.staff_id AS 'id_dim_staff',
    CONCAT(staff.first_name, ' ', staff.last_name) AS 'name',
    staff.store_id AS 'id_store'
FROM
    sakila.staff;

-- SELECT DIM_ACTOR    
SELECT 
    actor.actor_id AS 'id_actor',
    CONCAT(actor.first_name, ' ', actor.last_name) AS 'name'
FROM
    sakila.actor;

-- SELECT DIM CATEGORY   
SELECT 
    category.category_id AS 'id_category',
    category.name AS 'name'
FROM
    sakila.category;

-- SELECT DIM_FIML    
SELECT 
    film.film_id AS 'id_dim_film',
    film.title AS 'title',
    language.name AS 'language'
FROM
    sakila.film
        INNER JOIN
    sakila.language ON sakila.film.language_id = sakila.language.language_id;

-- SELECT BRIDGE_FILM_ACTOR
SELECT 
    film_actor.actor_id AS 'id_actor',
    film_actor.film_id AS 'id_film'
FROM
    sakila.film_actor;

-- SELECT BRIDGE_FILM_CATEGORY 
SELECT 
    film_category.category_id AS 'id_category',
    film_category.film_id AS 'id_film'
FROM
    sakila.film_category;

-- SELECT FACT_INVENTORY 
SELECT 
    DATE(sakila.inventory.last_update) AS 'dim_time',
    sakila.inventory.store_id AS 'dim_store',
    sakila.inventory.film_id AS 'dim_film',
    COUNT(*) AS 'quantify'
FROM
    sakila.inventory
GROUP BY dim_store , dim_film;
    
SELECT 
    inventory.last_update, inventory.store_id, inventory.film_id
FROM
    sakila.inventory;
    
-- SELECT FACT_RENTALS    
SELECT 
    DATE(rental.rental_date) AS 'dim_time',
    store.store_id AS 'dim_store',
    rental.staff_id AS 'dim_staff',
    inventory.film_id AS 'dim_film',
    rental.customer_id AS 'dim_customer',
    COUNT(*) AS 'quantify_rentals'
FROM
    sakila.rental
        INNER JOIN
    sakila.staff ON sakila.rental.staff_id = sakila.staff.staff_id
        INNER JOIN
    sakila.store ON sakila.staff.store_id = sakila.store.store_id
        INNER JOIN
    sakila.inventory ON sakila.rental.inventory_id = sakila.inventory.inventory_id
GROUP BY dim_time , dim_store , dim_staff , dim_film , dim_customer;


-- SELECT FACT_SALES 
SELECT 
    DATE(payment.payment_date) AS 'dim_time',
    store.store_id AS 'dim_store',
    payment.staff_id AS 'dim_staff',
    payment.customer_id AS 'dim_customer',
    COUNT(*) AS 'quantify_sales',
    SUM(payment.amount) AS cost
FROM
    sakila.payment
        INNER JOIN
    sakila.staff ON payment.staff_id = staff.staff_id
        INNER JOIN
    sakila.store ON staff.store_id = store.store_id
GROUP BY dim_time , dim_store , dim_staff , dim_customer;

