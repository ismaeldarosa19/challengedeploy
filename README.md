# Buscador de strings en correo Gmail
    Desarrollado en Python 3.8
    Documentación basada en Ubuntu 18.04 / Docker 19.03

## ¿Que hace?
    A través de la API de Gmail se busca una cadena de texto definida previamente(DevOps). Esta cadena de texto tiene 
    que aparecer en el asunto o cuerpo de los mensajes. Los correos que se encuentren con ese string se guardarán en 
    una base de datos con la siguiente información: fecha, from, subject.

## ¿Como puedo ejecutarlo?
    - Instalar Docker
        sudo apt install docker.io *
        
    - Generar y descargar token siguiendo la documentación de google. 
        siguiendo la documentación oficial de Google: https://developers.google.com/gmail/api/quickstart/python
        
    - Clonar el repositorio challengedeploy
        git clone https://github.com/ismaeldarosa19/challengedeploy.git
        
    - Copiar el token al directorio credentials del proyecto
        cp token.json ./credentials
        
    - Ejecutar build.sh
        sh ./build.sh


## ¿Qué hace el archivo build.sh?
   ### El archivo build.sh es el archivo que desencadena el deploy de todo el proyecto como se enumera a continuación.
   
        1 - Construye una imagen de docker llamada dev donde se interpretará el lenguaje Python.
                docker build  -t dev/challenge  -f dev/dockerfile.dev .
        
        2 - Construye una imagen de docker llamada mysql donde funcionará la base de datos
                docker build  -t mysql/challenge  -f database/dockerfile.mysql .
        
        3 - Genera strings seguros que se utilizarán, para definir la generación de usuario y passwords de la base de 
        datos a través de variables de entorno.
                randomstring()
                {
                    export LC_CTYPE=C
                    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
                }
        
        4 - Ejecuta el contenedor de base de datos en modo interactivo y en segundo plano, enviando las variables de 
        entorno con los valores generados por la funcion randomstrin.
                docker run -it -e MYSQL_ROOT_PASSWORD=$var_mysql_root_password -e MYSQL_USER=$var_mysql_user -e
                MYSQL_PASSWORD=$var_mysql_password -e MYSQL_DATABASE=$var_mysql_database --name mysql -d mysql/challenge
                        
        5 - Ejecuta el contenedor dev en modo interactivo y en segundo plano. Se envía como parámetro las variables de
        entorno generadas previamente. Se genera un link al contenedor mysql para poder realizar conexiones a la base 
        de datos.
         docker run -e userDB=$var_mysql_user -e passDB=$var_mysql_password -it --name dev --link mysql -d dev/challenge
                
## ¿Cuando termina el deploy, cómo realizo la consulta?
            Para poder ejecutar el script en busca de la palabra "DevOps", se debe ejecutar el siguiente comando:
                docker exec -it dev python challengeGmail.py    
                
