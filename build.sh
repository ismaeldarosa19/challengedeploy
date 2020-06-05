#!/bin/bash
#construimos las imágenes a partir de 2 dockerfile que levantamos desde github
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
docker run -it -e MYSQL_ROOT_PASSWORD=$var_mysql_root_password -e MYSQL_USER=$var_mysql_user -e MYSQL_PASSWORD=$var_mysql_password -e MYSQL_DATABASE=$var_mysql_database --name mysql -d mysql/challenge

#ejecutamos el contenedor dev y lo linkeamos a mysql para poder conectarnos a la base de datos
docker run -e userDB=$var_mysql_user -e passDB=$var_mysql_password -it --name dev --link mysql -d dev/challenge



#se crea una ventana de 20 segs para dar tiempo a que levante el mysql en el contenedor. Por razones de tiempo y objetivo del challenge 
#no se realizó un control que esté preguntando a MYSQL si está vivo. Lo cual sería la manera correcta de hacerlo.
sleep 1
#clear
clear
COLOR1='\033[0;32m'
COLOR2='\033[1;92m'
COLOR0='\033[0m'

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

printf "${COLOR1}El deploy ha finalizado.\n"
printf "Ejecutar consulta a la API: ${COLOR2}docker exec -it dev python challengeGmail.py\n\n"
printf "${COLOR1}Consultar registros en DB: ${COLOR2}docker exec -it dev python challengeGmailQ.py\n${COLOR0}"
echo '\n\n\n'

