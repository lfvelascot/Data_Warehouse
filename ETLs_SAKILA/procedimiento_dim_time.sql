CREATE PROCEDURE `etl_dim_time` ()
BEGIN
DECLARE cd date;
DECLARE y int(4);
DECLARE m VARCHAR(45);
DECLARE d INT(2);
DECLARE wd VARCHAR(45);
DECLARE cursor_date CURSOR FOR SELECT DISTINCT
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

DECLARE CONTINUE HANDLER FOR NOT FOUND SET @hecho = TRUE;
OPEN cursor_date;
loop1: LOOP
FETCH cursor_date INTO cd,y,m,d,wd;
IF @hecho THEN
LEAVE loop1;
END IF;
INSERT IGNORE INTO sakila_dw.dim_time VALUES (cd,y,m,d,wd);
END LOOP loop1;
CLOSE cursor_date;
END