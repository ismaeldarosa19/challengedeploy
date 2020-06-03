FROM mysql:latest AS mysql
ENV MYSQL_ROOT_PASSWORD Qazxsw21!!
ENV MYSQL_DATABASE challenge
ENV MYSQL_USER userChallenge
ENV MYSQL_PASSWORD Qazxsw21!!
ADD database.sql /docker-entrypoint-initdb.d
expose 3306
