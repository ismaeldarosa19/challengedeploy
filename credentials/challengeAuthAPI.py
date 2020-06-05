from googleapiclient.discovery import build
from httplib2 import Http
from oauth2client import file, client, tools
from mysql.connector import Error
from mysql.connector import errorcode
import os ##importamos el modulo os para poder obtener las variables de entorno correspondientes a usuario y password de la base de datos
import mysql.connector
from datetime import date
from datetime import datetime

SCOPES = 'https://www.googleapis.com/auth/gmail.readonly'
user_id =  'me' ## Definimos el user_id para hacer las consultas a Gmail. El usuario definido es el mismo que se define en las credenciales(me).

def main():
    ## Se valida la autorizaciòn, verificando si existe y no está caducado token.json
    store = file.Storage('credentials/token.json')
    creds = store.get()

    ##Si no existen o esta caducadas las credenciales, se hace la solicitud
    if not creds or creds.invalid:
        flow = client.flow_from_clientsecrets('credentials/credentials.json', SCOPES)
        creds = tools.run_flow(flow, store)
    service = build('gmail', 'v1', http=creds.authorize(Http()))
    
if __name__ == '__main__':
	main()






