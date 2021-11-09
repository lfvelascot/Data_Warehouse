from datetime import datetime
import mysql.connector


class MysqlDB:
    def __init__(self, hostname, port, user, password, db):
        self.hostname = hostname
        self.port = port
        self.username = user
        self.password = password
        self.database = db
        self.condb = None

    def connectmysql(self):
        try:
            self.condb = mysql.connector.connect(host=self.hostname, port=self.port,
                                                 user=self.username,
                                                 passwd=self.password,
                                                 db=self.database)
            cursor = self.condb.cursor()
            cursor.execute("SET lc_time_names = 'es_CO';")
            print("Conexión exitoso a " + self.database)
        except Exception as e: \
                print("Error de conexión", e)

    def closeconection(self):
        try:
            self.condb.close()
            print('Desconexión exitosa a ' + self.database)
        except Exception as e: \
                print("Error de desconexión", e)


class Querys:
    def __init__(self, condb1, condb2):
        self.condb1 = condb1
        self.condb2 = condb2

    def select(self, sql):
        cursor = self.condb1.cursor()
        try:
            cursor.execute("SELECT DISTINCT " + sql)
            return cursor.fetchall()
        except Exception as e: \
                print("Error de consulta", e)

    def insert(self, c, tabla, sql):
        cursori = self.condb2.cursor()
        try:
            cursori.executemany("INSERT IGNORE INTO " + sql, c)
            print("TABLA ", tabla, " CARGADA ")
            self.condb2.commit()
        except Exception as e:
            print("Error de insercion", e)
            self.condb2.rollback()


if __name__ == '__main__':
    ## Creacion de las conexiones a la base de datos
    print("INICIO DE CARGA DE DATOS A SAKILA_DW: ", datetime.today().strftime('%Y-%m-%d %H:%M:%S'))
    sakila = MysqlDB('localhost', 3306, 'root', 'password', 'sakila')
    sakila_dw = MysqlDB('localhost', 3306, 'root', 'password', 'sakila_dw')
    ## Conexion a las bases de datos
    sakila.connectmysql()
    sakila_dw.connectmysql()
    ## Inicio de clase dedicada a las consultas e inserciones
    query = Querys(sakila.condb, sakila_dw.condb)
    ### Ejecucion de las sentencias SQL
    ## DIM_TIME
    c = query.select(
        "DATE(pay.payment_date), YEAR(pay.payment_date) ,MONTHNAME(pay.payment_date) ,DAYOFMONTH(pay.payment_date) ,DAYOFWEEK(pay.payment_date) FROM payment AS pay "
        "UNION SELECT DISTINCT DATE(ren.rental_date),YEAR(ren.rental_date),MONTHNAME(ren.rental_date),DAYOFMONTH(ren.rental_date) ,DAYOFWEEK(ren.rental_date) FROM sakila.rental AS ren "
        "UNION SELECT DISTINCT DATE(inv.last_update) ,YEAR(inv.last_update) ,MONTHNAME(inv.last_update) ,DAYOFMONTH(inv.last_update) ,DAYOFWEEK(inv.last_update) FROM sakila.inventory AS inv;");
    query.insert(c, "DIM_TIME",
                 "dim_time (complete_date, year, month, day, week_day) VALUES (%s, %s, %s, %s, %s)")
    ## DIM_CUSTOMER
    c = query.select(
        "customer.customer_id,CONCAT(customer.first_name,' ',customer.last_name) ,customer.active ,address.address, city.city, country.country FROM customer "
        "INNER JOIN address ON customer.address_id = address.address_id "
        "INNER JOIN city ON address.city_id = city.city_id "
        "INNER JOIN country ON city.country_id = country.country_id;")
    query.insert(c, "DIM_CUSTOMER",
                 "dim_customer (id_customer, name, status, address, city, country) VALUES (%s, %s, %s, %s, %s, %s)")
    ## DIM_STORE
    c = query.select(
        "store.store_id , address.address, city.city , country.country FROM store "
        "INNER JOIN address ON store.address_id = address.address_id "
        "INNER JOIN city ON address.city_id = city.city_id "
        "INNER JOIN country ON city.country_id = country.country_id;")
    query.insert(c, "DIM_STORE",
                 "dim_store (id_store, address, city, country) VALUES (%s, %s, %s, %s)")
    ## DIM_STAFF
    c = query.select(
        "staff.staff_id, CONCAT(staff.first_name, ' ', staff.last_name), staff.store_id FROM staff;")
    query.insert(c, "DIM_SATFF",
                 "dim_staff (id_staff, name, id_store) VALUES (%s, %s, %s)")
    ## DIM_ACTOR
    c = query.select(
        "actor_id, CONCAT(first_name, ' ', last_name) FROM actor;")
    query.insert(c, "DIM_ACTOR",
                 "dim_actor (id_actor, name) VALUES (%s, %s)")
    ## DIM_CATEGORY
    c = query.select(
        "category.category_id, category.name FROM category;")
    query.insert(c, "DIM_CATEGORY",
                 "dim_category (id_category, name) VALUES (%s, %s)")
    ## DIM_FILM
    c = query.select(
        "film.film_id, film.title, language.name FROM film "
        "INNER JOIN language ON film.language_id = language.language_id;")
    query.insert(c, "DIM_FILM",
                 "dim_film (id_film, title, language) VALUES (%s, %s, %s)")
    ## BRIDGE_FILM_CATEGORY
    c = query.select(
        "film_category.category_id, film_category.film_id FROM film_category;")
    query.insert(c, "BRIDGE_FILM_CATEGORY",
                 "bridge_film_category (id_category,id_film) VALUES (%s, %s)")
    ## BRIDGE_FILM_ACTOR
    c = query.select(
        "film_actor.actor_id, film_actor.film_id FROM film_actor;")
    query.insert(c, "BRIDGE_FILM_ACTOR",
                 "bridge_film_actor (id_actor,id_film) VALUES (%s, %s)")
    ## FACT_INVENTORY
    c = query.select(
        "inventory.film_id, DATE_FORMAT(sakila.inventory.last_update, '%Y-%m-%d'), inventory.store_id, 1 FROM  inventory;")
    query.insert(c, "FACT_INVENTORY",
                 "fact_inventory (dim_film,dim_time, dim_store, quantity_film) VALUES (%s, %s, %s, %s)")
    ## FACT RENTALS
    c = query.select(
        "rental.customer_id, inventory.film_id, inventory.store_id, DATE_FORMAT(rental.rental_date, '%Y-%m-%d'), rental.staff_id,1 FROM rental "
        "INNER JOIN  inventory ON inventory.inventory_id = rental.inventory_id;")
    query.insert(c, "FACT_RENTALS",
                 "fact_rentals (dim_customer,dim_film, dim_store,dim_time,dim_staff, quantity_rentals) VALUES (%s, %s, %s, %s,%s, %s)")
    ## FACT_SALES
    c = query.select(
        "payment.customer_id, DATE_FORMAT(sakila.payment.payment_date, '%Y-%m-%d'), staff.store_id, payment.staff_id, 1 FROM payment "
        "INNER JOIN staff ON payment.staff_id = staff.staff_id;")
    query.insert(c, "FACT_SALES",
                 "fact_sales(dim_customer,dim_time,dim_store,dim_staff,quantity_sales) VALUES (%s, %s, %s,%s, %s)")
    ##Desconexion a las bases de datos
    sakila.closeconection()
    sakila_dw.closeconection()
    print("FIN DE CARGA DE DATOS A SAKILA_DW: ", datetime.today().strftime('%Y-%m-%d %H:%M:%S'))
