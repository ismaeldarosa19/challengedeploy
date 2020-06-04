#construimos las imágenes a partir de 2 dockerfile que levantamos desde github
docker build  -t dev/challenge https://github.com/ismaeldarosa19/challengedeploy.git -f dev/dockerfile.dev
docker build  -t mysql/challenge https://github.com/ismaeldarosa19/challengedeploy.git -f database/dockerfile.mysql

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

#mensaje de finalización y ayuda de ejecución
#clear
#sleep 2
COLOR1='\033[0;33m'
COLOR2='\033[0;93m'
COLOR0='\033[0m'
printf "${COLOR1}El deploy ha finalizado.\n"
echo
printf "Ejecutar: ${COLOR2}docker exec -it dev python challengeGmail.py\n${COLOR0}"

