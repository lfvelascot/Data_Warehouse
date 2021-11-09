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

    def __init__(self):
        ## Conexion a las bases de datos
        self.sakila = MysqlDB('localhost', 3306, 'root', 'password', 'sakila')
        self.sakila_dw = MysqlDB('localhost', 3306, 'root', 'password', 'sakila_dw')
        self.sakila.connectmysql()
        self.sakila_dw.connectmysql()
        self.months = (
            "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre",
            "Noviembre",
            "Diciembre")
        self.days = ("Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado", "Domingo")

    def desconectar(self):
        self.sakila.closeconection()
        self.sakila_dw.closeconection()

    def extract(self, sql):
        cursor = self.sakila.condb.cursor()
        try:
            cursor.execute("SELECT " + sql)
            return cursor.fetchall()
        except Exception as e: \
                print("Error de consulta", e)

    def load(self, c, tabla, sql):
        cursori = self.sakila_dw.condb.cursor()
        try:
            cursori.executemany("INSERT IGNORE INTO " + sql, c)
            print("TABLA ", tabla, " CARGADA CON ", len(c),
                  " REGISTROS (Los registros pueden ser repetidos y por ende haber sido ignroados)")
            self.sakila_dw.condb.commit()
        except Exception as e:
            print("Error de insercion", e)
            self.sakila_dw.condb.rollback()

    def trans_dim_date(self, c):
        l, f = [], []
        for i in c:
            a = i[0].strftime('%Y-%m-%d')
            if a not in f:
                f.append(a)
                aux = (a, i[0].year, self.months[i[0].month - 1], i[0].day, self.days[i[0].weekday() - 1])
                l.append(aux)
        return l

    def trans_dim_customer(self, c):
        l = []
        for i in c:
            name = i[1] + " " + i[2]
            aux = (i[0], name, i[3], i[4], i[5])
            l.append(aux)
        return l

    def trans_dim_staff(self, c):
        l = []
        for i in c:
            aux = (i[0], i[1] + " " + i[2], i[3])
            l.append(aux)
        return l

    def trans_dim_actor(self, c):
        l = []
        for i in c:
            aux = (i[0], i[1] + " " + i[2])
            l.append(aux)
        return l

    def trans_fact_inventory(self, c):
        l = []
        for i in c:
            a = i[0].strftime('%Y-%m-%d')
            aux = [a, i[1], i[2]]
            p = self.almacenado_inv(l, aux)
            if p == -1:
                aux.append(1)
                l.append(aux)
            else:
                a = l[p]
                a[3] = a[3] + 1
                l[p] = a
        return l

    def trans_fact_sales(self, c):
        l = []
        for i in c:
            a = i[1].strftime('%Y-%m-%d')
            aux = [i[0], a, i[2], i[3], 1, i[4]]
            p = self.almacenado(l, aux, 4)
            if p == -1:
                l.append(aux)
            else:
                a = l[p]
                a[4] = a[4] + 1
                a[5] = a[5] + aux[5]
                l[p] = a
        return l

    def almacenado(self, l, c, r):
        x = 0
        for i in l:
            k = 0
            for j in range(r):
                if i[j] == c[j]:
                    k = k + 1
            if k == r:
                return x
            x = x + 1
        return -1

    def almacenado_inv(self, l, c):
        x = 0
        for i in l:
            k = 0
            for j in range(1, 3):
                if i[j] == c[j]:
                    k = k + 1
            if k == 2:
                return x
            x = x + 1
        return -1

    def trans_fact_rentals(self, c):
        l = []
        for i in c:
            a = i[3].strftime('%Y-%m-%d')
            aux = [i[0], i[1], i[2], a, i[4]]
            p = self.almacenado(l, aux, 5)
            if p == -1:
                aux.append(1)
                l.append(aux)
            else:
                a = l[p]
                a[5] = a[5] + 1
                l[p] = a
        return l


if __name__ == '__main__':
    ## Creacion de las conexiones a la base de datos
    print("INICIO DE CARGA DE DATOS A SAKILA_DW: ", datetime.today().strftime('%Y-%m-%d %H:%M:%S'))
    ## Inicio de clase dedicada a las consultas e inserciones
    query = Querys()
    ### Ejecucion de las sentencias SQL
    ## DIM_TIME
    c = query.extract("payment_date FROM payment;") + query.extract("rental_date FROM rental;") + query.extract(
        "last_update FROM inventory;")
    c = query.trans_dim_date(c)
    query.load(c, "DIM_TIME", "dim_time (complete_date, year, month, day, week_day) VALUES (%s, %s, %s, %s, %s)")
    ## DIM_CUSTOMER
    c = query.extract(
        "customer.customer_id,customer.first_name,customer.last_name,customer.active , city.city, country.country FROM customer "
        "INNER JOIN address ON customer.address_id = address.address_id "
        "INNER JOIN city ON address.city_id = city.city_id "
        "INNER JOIN country ON city.country_id = country.country_id;")
    c = query.trans_dim_customer(c)
    query.load(c, "DIM_CUSTOMER",
               "dim_customer (id_customer, name, status, city, country) VALUES (%s, %s,  %s, %s, %s)")
    ## DIM_STORE
    c = query.extract(
        "store.store_id , address.address, city.city , country.country FROM store "
        "INNER JOIN address ON store.address_id = address.address_id "
        "INNER JOIN city ON address.city_id = city.city_id "
        "INNER JOIN country ON city.country_id = country.country_id;")
    query.load(c, "DIM_STORE", "dim_store (id_store, address, city, country) VALUES (%s, %s, %s, %s)")
    ## DIM_STAFF
    c = query.extract("staff.staff_id, staff.first_name, staff.last_name, staff.store_id FROM staff;")
    c = query.trans_dim_staff(c)
    query.load(c, "DIM_SATFF", "dim_staff (id_staff, name, id_store) VALUES (%s, %s, %s)")
    ## DIM_ACTOR
    c = query.extract("actor_id, first_name, last_name FROM actor;")
    c = query.trans_dim_actor(c)
    query.load(c, "DIM_ACTOR", "dim_actor (id_actor, name) VALUES (%s, %s)")
    ## DIM_CATEGORY
    c = query.extract("category_id, name FROM category;")
    query.load(c, "DIM_CATEGORY", "dim_category (id_category, name) VALUES (%s, %s)")
    ## DIM_FILM
    c = query.extract(
        "film.film_id, film.title, language.name FROM film "
        "INNER JOIN language ON film.language_id = language.language_id;")
    query.load(c, "DIM_FILM", "dim_film (id_film, title, language) VALUES (%s, %s, %s)")
    ## FACT_INVENTORY
    c = query.extract("inventory.last_update,  inventory.film_id, inventory.store_id FROM sakila.inventory;")
    c = query.trans_fact_inventory(c)
    query.load(c, "FACT_INVENTORY",
               "fact_inventory (dim_time,dim_film, dim_store, quantity_film) VALUES (%s, %s, %s, %s)")
    ## FACT RENTALS
    c = query.extract(
        "rental.customer_id, inventory.film_id,store.store_id,rental.rental_date,rental.staff_id "
        "FROM sakila.rental "
        "INNER JOIN sakila.staff ON rental.staff_id = staff.staff_id "
        "INNER JOIN sakila.store ON staff.store_id = store.store_id "
        "INNER JOIN sakila.inventory ON rental.inventory_id = inventory.inventory_id;")
    c = query.trans_fact_rentals(c)
    query.load(c, "FACT_RENTALS",
               "fact_rentals (dim_customer,dim_film, dim_store,dim_time,dim_staff, quantity_rentals) VALUES (%s, %s, %s,%s, %s, %s)")
    ## FACT_SALES
    c = query.extract(
        "payment.customer_id,payment.payment_date,store.store_id, payment.staff_id ,payment.amount FROM sakila.payment "
        "INNER JOIN sakila.staff ON payment.staff_id = staff.staff_id  "
        "INNER JOIN sakila.store ON staff.store_id = store.store_id;")
    c = query.trans_fact_sales(c)
    query.load(c, "FACT_SALES",
               "fact_sales(dim_customer,dim_time,dim_store,dim_staff,quantity_sales, cost) VALUES (%s, %s, %s,%s, %s, %s)")
    ## BRIDGE_FILM_CATEGORY
    c = query.extract("film_category.category_id, film_category.film_id FROM film_category;")
    query.load(c, "BRIDGE_FILM_CATEGORY", "bridge_film_category (id_category,id_film) VALUES (%s, %s)")
    ## BRIDGE_FILM_ACTOR
    c = query.extract("film_actor.actor_id, film_actor.film_id FROM film_actor;")
    query.load(c, "BRIDGE_FILM_ACTOR", "bridge_film_actor (id_actor,id_film) VALUES (%s, %s)")
    ##Desconexion a las bases de datos
    query.desconectar()
    print("FIN DE CARGA DE DATOS A SAKILA_DW: ", datetime.today().strftime('%Y-%m-%d %H:%M:%S'))
