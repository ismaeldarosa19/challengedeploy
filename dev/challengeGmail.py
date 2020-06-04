from googleapiclient.discovery import build
from httplib2 import Http
from oauth2client import file, client, tools
from mysql.connector import Error
from mysql.connector import errorcode
import os ##importamos el modulo os para poder obtener las variables de entorno correspondientes a usuario y password de la base de datos
import mysql.connector
from datetime import date
from datetime import datetime

dbConnect = {
        'host':'mysql',
        'user':os.getenv('userDB'),
        'password':os.environ.get('passDB'),
        'database':'challenge'

}
conexion = mysql.connector.connect(**dbConnect)
cursor = conexion.cursor()
SCOPES = 'https://www.googleapis.com/auth/gmail.readonly'
user_id =  'me' ## Definimos el user_id para hacer las consultas a Gmail. El usuario definido es el mismo que se define en las credenciales(me).
query_string='DevOps' ## Definimos la cadena a buscar en los correos

def main():
    ## Abrimos la conexion al archivo de logs
    file_object = open('log.txt', 'a') 

    ## Se valida la autorizaciòn, verificando si existe y no está caducado token.json
    store = file.Storage('token.json')
    creds = store.get()

    ##Si no existen o esta caducadas las credenciales, se hace la solicitud
    if not creds or creds.invalid:
        flow = client.flow_from_clientsecrets('credentials.json', SCOPES)
        creds = tools.run_flow(flow, store)
    service = build('gmail', 'v1', http=creds.authorize(Http()))
    
    # Llamamos a la api buscando en INBOX y matcheamos en la query a "DevOps"
    results = service.users().messages().list(userId=user_id,labelIds = ['INBOX'],q=query_string).execute()
    messages = results.get('messages', [])
    
    if not messages:
        ## Escribimos el resultado en el archivo de logs
        file_object.write(logTime + "   Se realizo una busqueda sin resultados \n") 
    else:
    	## Si se encuentran mensajes con los parámetros indicados, los recorremos en búsca de los headers 
        repetidos=0
        for message in messages: 
        	#Leemos cada mensaje por donde pasamos en el bucle, obtenìendolo a través del message id en el array message[] 
            msg = service.users().messages().get(userId=user_id, id=message['id']).execute() 
            ## Obtenemos la estructura del mensaje a través del campo payload, y asì podremos obtener los headers
            payload = msg['payload'] 
            ## Obtenemos los headers para poder obtener los campos solicitados(fecha, from y asunto)
            header = payload['headers'] 
  
            ## Dentro del json obtenido(variable header) buscamos los campos Date, From y Subject y guardamos los valores en las variables correspondientes(dateEmail, senderEmail y subjectEmail)
            for date in header: ## Buscamos Fecha
                if date['name'] == 'Date':
                    dateEmail = (date['value'])

            for sender in header: ## Buscamos From
                if sender['name'] == 'From':
                    senderEmail = (sender['value'])

            for subject in header: ## Buscamos Asunto
                if subject['name'] == 'Subject':
                    subjectEmail = subject['value']

            ## Agregamos un control, verificamos, si ya existe el id de mensaje. Si ya existe no lo grabamos en la DB. De esta manera no se registrarán en la DB mails duplicados.
            sql="select * from busquedas where idmsg = %s"         
            cursor.execute(sql, (message['id'],))
            data_tmp = cursor.fetchone()

            if data_tmp:
                repetidos+=1
                print ("existe y no se inserta")
            if not data_tmp:
                sqlInsertar = "INSERT INTO busquedas (`idmsg`,`date`, `from`, `subject`) VALUES (%s,%s, %s, %s)"
                cursor.execute(sqlInsertar,(message['id'],dateEmail,senderEmail,subjectEmail))
                conexion.commit()
                logTime=format(datetime.now())

                ## Registramos en el archivo log, la información insertada
                file_object.write(logTime + "	'INSERT'	" + message['id'] + "	" + dateEmail + "	" + senderEmail + "	" + subjectEmail + "\n") 

    #file_object.close() ## Cerramos la conexion al archivo de logs
print($repetidos)
if __name__ == '__main__':
	main()
cursor.close()
conexion.close()






