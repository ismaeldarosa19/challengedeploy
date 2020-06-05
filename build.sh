#!/bin/bash
#construimos las imágenes a partir de 2 dockerfile que levantamos desde github
file='credentials/credentials.json'
if [ -e "$file" ]; then
        python credentials/challengeAuthAPI.py --noauth_local_webserver
	sleep 3
else
clear
echo  "\e[91mNo se puede continuar con el deploy por los siguientes motivos:\n \e[39m"
echo " No existe el archivo credentials.json en el directorio credentials/ del proyecto. Revisar los pasos detallados a continuación:\n"
echo "- Se debe generar el archivo credentials.json siguiendo la documentación de google: https://developers.google.com/gmail/api/quickstart/python"
echo "- Descargar el archivo y copiarlo al directorio credentials/ del proyecto luego ejecutar el archivo build.sh"
echo "- Ingresar desde cualquier navegador a la url solicitada por la API y dar los permisos correspondientes."
echo "- Luego de dar los permisos google proveerá de un código, el cual hay que pegarlo en este script."
echo
echo 
echo
exit 1
fi

file='credentials/token.json'
if [ -e "$file" ]; then
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

	#Copiamos el token al contenedor dev
	docker cp credentials/token.json dev:/opt/challenge

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

else
clear
echo  "\e[91mNo se puede continuar con el deploy por los siguientes motivos:\n \e[39m"
echo " No se ha generado el token de autenticación. Revisar los pasos detallados a continuación:\n"
echo "- Se debe generar el archivo credentials.json siguiendo la documentación de google: https://developers.google.com/gmail/api/quickstart/python"
echo "- Descargar el archivo y copiarlo al directorio credentials/ del proyecto luego ejecutar el archivo build.sh"
echo "- Ingresar a la url solicitada por la API desde cualquier navegador y dar los permisos correspondientes."
echo "- Luego de dar los permisos google proveedrá de un código, el cual hay que pegarlo en este script"
echo
echo
echo
exit 1
fi

