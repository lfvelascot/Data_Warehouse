import mysql.connector
import pandas as pd

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

    def load(self, sql, data, table):
        cursor = self.condb.cursor()
        try:
            cursor.executemany("INSERT IGNORE INTO " + sql, data)
            print("TABLA ", table, " CARGADA CON ", len(data),
                  " REGISTROS (Los registros pueden ser repetidos y por ende haber sido ignroados)")
            self.condb.commit()
        except Exception as e:
            print("Error de insercion", e)
            self.condb.rollback()

    def extract(self, sql):
        cursor = self.condb.cursor()
        try:
            cursor.execute("SELECT " + sql)
            return cursor.fetchall()
        except Exception as e: \
                print("Error de consulta", e)

    def closeconection(self):
        try:
            self.condb.close()
            print('Desconexión exitosa a ' + self.database)
        except Exception as e: \
                print("Error de desconexión", e)


class Archivo_Mort:

    def __init__(self, nombre):
        self.ruta = '/DATASETS/'+nombre
        self.sep = ';'
        self.names =['COD_DPTO', 'COD_MUNIC', 'A_DEFUN', 'COD_INSP', 'SIT_DEFUN', 'OTRSITIODE',
                      'COD_INST', 'NOM_INST', 'TIPO_DEFUN', 'FECHA_DEF', 'ANO', 'MES', 'HORA', 'MINUTOS',
                      'SEXO', 'FECHA_NAC', 'EST_CIVIL', 'EDAD', 'NIVEL_EDU', 'ULTCURFAL', 'MUERTEPORO',
                      'SIMUERTEPO', 'OCUPACION', 'IDPERTET', 'IDPUEBIN', 'N_IDPUEBIN', 'CODPRES', 'CODPTORE',
                      'CODMUNRE', 'AREA_RES', 'BARRIOFAL', 'COD_LOCA', 'CODIGO', 'VEREDAFALL', 'SEG_SOCIAL',
                      'IDADMISALU', 'IDCLASADMI', 'PMAN_MUER', 'CONS_EXP', 'MU_PARTO', 'T_PARTO', 'TIPO_EMB',
                      'T_GES', 'PESO_NAC', 'EDAD_MADRE', 'N_HIJOSV', 'N_HIJOSM', 'EST_CIVM', 'NIV_EDUM',
                      'ULTCURMAD', 'EMB_FAL', 'EMB_SEM', 'EMB_MES', 'MAN_MUER', 'COMOCUHEC', 'CODOCUR',
                      'CODMUNOC', 'DIROCUHEC', 'LOCALOCUHE', 'C_MUERTE', 'C_MUERTEB', 'C_MUERTEC', 'C_MUERTED',
                      'C_MUERTEE', 'ASIS_MED', 'N_DIR1', 'T_DIR1', 'M_DIR1', 'C_DIR1', 'C_DIR12', 'N_ANT1', 'T_ANT1',
                      'M_ANT1', 'C_ANT1', 'C_ANT12', 'N_ANT2', 'T_ANT2', 'M_ANT2', 'C_ANT2', 'C_ANT22', 'N_ANT3',
                      'T_ANT3',
                      'M_ANT3', 'C_ANT3', 'C_ANT32', 'N_PAT1', 'T_PAT1', 'M_PAT1', 'C_PAT1', 'N_PAT2', 'C_PAT2',
                      'N_BAS1',
                      'C_BAS1', 'N_MCM1', 'C_MCM1', 'CAUSA_666', 'IDPROFCER', 'DD_EXP', 'MM_EXP', 'FECHA_EXP',
                      'FECHAGRA',
                      'CAU_HOMOL', 'GRU_ED1', 'GRU_ED2', 'HORA_SE']
        self.dataframe = pd.read_csv(self.ruta, sep=self.sep, header=None,
                                     names=self.names)
        self.dataframe_lugar = pd.read_csv("/DATASETS/Departamentos_y_municipios_de_Colombia.csv", sep=self.sep, header=None,
                                     names=['REGION','CÓDIGO DANE DEL DEPARTAMENTO','DEPARTAMENTO','CÓDIGO DANE DEL MUNICIPIO','MUNICIPIO'])

    def extract_departament(self):
        lista,pk = [], []
        for i in self.dataframe.index:
            clave = self.dataframe["COD_DPTO"][i]
            if clave not in pk:
                pk.append(clave)
                aux = (clave,self.buscar_departamento(clave))
                lista.append(aux)
        return lista

    def buscar_departamento(self, clave):
        for i in self.dataframe_lugar.index:
            if self.dataframe_lugar['CÓDIGO DANE DEL DEPARTAMENTO'][i] == clave:
                return self.dataframe_lugar['DEPARTAMENTO'][i]
        else:
            return "SIN NOMBRE"


if __name__ == '__main__':
    ods = MysqlDB('localhost', 3306, 'root', 'password', 'ods_bona_health')
    arc = Archivo_Mort("Mort_Can_Mama.cvs")
    print (arc.extract_departament())