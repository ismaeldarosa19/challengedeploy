file='credentials/credentials.json'
if [ -e "$file" ]; then
	python credentials/challengeAuthAPI.py --noauth_local_webserver
else
    echo "No existe el archivo credentials.json en el directorio credentials/"
fi

