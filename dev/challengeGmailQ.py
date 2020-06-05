from mysql.connector import Error
from mysql.connector import errorcode
import os ##importamos el modulo os para poder obtener las variables de entorno correspondientes a usuario y password de la base de datos
import mysql.connector
from tabulate import tabulate

dbConnect = {
        'host':'mysql',
        'user':os.getenv('userDB'),
        'password':os.environ.get('passDB'),
        'database':'challenge'

}
conexion = mysql.connector.connect(**dbConnect)
cursor = conexion.cursor()

def main():
            ## Buscamos en toda la tabla busqueda y mostramos los reultados utilizando el modulo tabulate
            sql="select * from busquedas"
            cursor.execute(sql)
            data_tmp = cursor.fetchall()
            print(tabulate(data_tmp, headers=['ID', 'ID Mensaje', 'Fecha', 'From', 'Asunto'], tablefmt='psql'))
if __name__ == '__main__':
        main()
cursor.close()
conexion.close()
