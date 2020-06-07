# Buscador de strings en correo Gmail
    Desarrollado en Python 3.8
    Documentación basada en Ubuntu 18.04 / Docker 19.03

## ¿Que hace?
    Busca una cadena de texto específica en el inbox de una cuenta de gmail. La cadena de texto se busca en 
    el asunto o cuerpo de los mensajes. Los mensajes encontrados que cumplan con esa condición, se guardarán 
    en una base de datos con la siguiente información: fecha, from, subject.

## ¿Como puedo ejecutarlo? 
### Utilizando Docker
    - Instalar Docker
        https://docs.docker.com/engine/install/      
   
    - Clonar el repositorio challengedeploy
        git clone https://github.com/ismaeldarosa19/challengedeploy.git
   
    - Habilitar la API en la cuenta a utilizar y descargar el archivo credentials.json
        https://developers.google.com/gmail/api/quickstart/python
   
    - Mover el archivo credentials.json al directorio credentials del proyecto
                
    - Ejecutar el archivo build.sh en la raiz del pryecto
        Este archivo realiza el deployment del proyecto. Automatizando el todo el proceso de construcción.
    
    - En el paso final del deployment se solicita un código para generar el token de la API. Este código 
    se obtiene accediendo a una url sugerida en pantalla. Luego de acceder a la url, hay que seleccionar 
    la cuenta de gmail(misma cuenta utilizada en Paso 3). Se conceden los permisos de acceso y al final se 
    obtiene un código. Este código es el que hay que copiar para pegar en el script.
    
    


## ¿Qué hace el archivo build.sh?
   ### El archivo build.sh es el archivo que realiza el deploy de todo el proyecto como se enumera a continuación.
   
        1 - Construye una imagen de docker llamada dev donde se interpretará el lenguaje Python (Versión 3.8).
                docker build  -t dev/challenge  -f dev/dockerfile.dev .
        
        2 - Construye una imagen de docker llamada mysql donde funcionará la base de datos
                docker build  -t mysql/challenge  -f database/dockerfile.mysql .
        
        3 - Genera strings seguros, que se utilizarán para definir la generación de usuario y passwords de la base de 
        datos a través de variables de entorno.
                randomstring()
                {
                    export LC_CTYPE=C
                    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
                }
        
        4 - Ejecuta el contenedor de base de datos en modo interactivo y en segundo plano, enviando las variables de 
        entorno con los valores generados por la funcion randomstring.
                docker run -it -e MYSQL_ROOT_PASSWORD=$var_mysql_root_password -e MYSQL_USER=$var_mysql_user -e
                MYSQL_PASSWORD=$var_mysql_password -e MYSQL_DATABASE=$var_mysql_database --name mysql -d mysql/challenge
                        
        5 - Ejecuta el contenedor dev en modo interactivo y en segundo plano. Se envía como parámetro las variables de
        entorno generadas previamente. Se genera un link al contenedor mysql para poder realizar conexiones a la base 
        de datos.
         docker run -e userDB=$var_mysql_user -e passDB=$var_mysql_password -it --name dev --link mysql -d dev/challenge
        
        6 - Copia/crea archivos y directorios necesarios para el funcionamiento del script.
        
        7 - Se ejecuta el archivo challengeAuthAPI.py del conenedor dev. Este archivo se encarga de solicitar el código 
        para la generación del token de autenticación(Paso 6 del apartado anterior).
        
        
                
## ¿Cuando termina el deploy, cómo utilizo el script?
            Para poder ejecutar el script en busca de la palabra "DevOps", se debe ejecutar el siguiente comando:
                docker exec -it dev python challengeGmail.py
                
            Para buscar los registros que hay en la base de datos, se debe ejecutar lo siguiente:
                docker exec -it dev python challengeGmailQ.py
                
## ¿Se puede utilizar sin Docker?
            Este script se puede utilizar de manera independiente a Docker, con los siguientes requerimientos:
            
            - Python 3.8
            - Mysql
            
            
            
            
            
                
