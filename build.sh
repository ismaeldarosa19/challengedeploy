#!/bin/bash
#construimos las imágenes a partir de 2 dockerfile que levantamos desde github
COLOR1='\033[0;32m'
COLOR2='\033[1;92m'
COLOR0='\033[0m'

clear
file='credentials/credentials.json'
echo "Verificando Credenciales"
sleep 1
if [ -e "$file" ]; then
        echo "${COLOR1}OK${COLOR0}"
        sleep 1
else
clear
echo  "\e[91mNo se puede continuar con el deploy por los siguientes motivos:\n \e[39m"
echo " No existe el archivo credentials.json en el directorio credentials/ del proyecto. Revisar los pasos detallados a continuación:\n"
echo "- Se debe generar el archivo credentials.json siguiendo la documentación de google: https://developers.google.com/gmail/api/quickstart/python"
echo "- Descargar el archivo y copiarlo al directorio credentials/ del proyecto"
echo "- Ejecutar el archivo build.sh"
echo
echo
echo
exit 1
fi
echo "${COLOR1}Comenzando deploy${COLOR0}"
sleep 1

        docker build  -t dev/challenge  -f dev/dockerfile.dev .
        docker build  -t mysql/challenge  -f database/dockerfile.mysql .

        #creamos la funcion randomstring para generar contraseñas randómicas para las credenciales de la DB
        randomstring()
        {
                export LC_CTYPE=C
                cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
        }

        #asignamos contraseñas randómicas a variables a través de la función randomstring
        var_mysql_root_password=$(randomstring)
        var_mysql_user=$(randomstring)
        var_mysql_password=$(randomstring)
        var_mysql_database='challenge'

        #ejecutamos el contenedor mysql, asignamos las variables generadas a las variables de entorno que utiliza el dockerfile para crear la DB
        docker run -it -e MYSQL_ROOT_PASSWORD=$var_mysql_root_password -e MYSQL_USER=$var_mysql_user -e MYSQL_PASSWORD=$var_mysql_password -e MYSQL_DATABASE=$var_mysql_database --name mysql -d mysql/challenge --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

        #ejecutamos el contenedor dev y lo linkeamos a mysql para poder conectarnos a la base de datos
        docker run -e userDB=$var_mysql_user -e passDB=$var_mysql_password -it --name dev --link mysql -d dev/challenge

        #se crea una ventana de 20 segs para dar tiempo a que levante el mysql en el contenedor. Por razones de tiempo y objetivo del challenge
        #no se realizó un control que esté preguntando a MYSQL si está vivo. Lo cual sería la manera correcta de hacerlo.

echo "${COLOR1}OK${COLOR0}"
sleep 3
docker exec -ti dev mkdir /opt/challenge/credentials
docker exec -ti dev touch /opt/challenge/credentials/token.json
docker cp credentials/credentials.json dev:/opt/challenge/credentials
docker cp credentials/challengeAuthAPI.py dev:/opt/challenge/credentials

#clear
        clear
        y=2
        x=0
        i=10
        while [ $i -lt 101 ]; do
            tput cup $y $x
            echo ''
            echo '**** Finalizando deploy |||| API Gmail Python*****'
            echo '*                                                *'
            if [ $i = 100 ]
                then
                echo '*                       FIN                      *'
            else
                echo '*                       '$i%'                      *'
            fi

            echo '*                                                *'
            echo '**************** Ismael da Rosa ******************'
            echo ''
            i=$((i+5))
        sleep 1
        done

        printf "${COLOR1}Deploy OK.${COLOR0}\n"
        sleep 1
        clear
        echo "Para comenzar a utilizar el script, se debe autorizar la utilizacion de la API"
        echo "A continuacion se solicitara un codigo."
        echo "El codigo se obtiene accediendo a la url sugerida desde cualquier navegador y aceptando los permisos de acceso"
        echo
        echo
	echo "Presiona Enter para continuar ";
	read name;
	docker exec -ti dev python credentials/challengeAuthAPI.py --noauth_local_webserver
        clear
        printf "Ejecutar consulta a la API: ${COLOR2}docker exec -it dev python challengeGmail.py\n\n"
        printf "${COLOR0}Consultar registros en DB: ${COLOR2}docker exec -it dev python challengeGmailQ.py\n${COLOR0}"
        echo '\n\n\n'


