#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    echo "Run script as ROOT please. (sudo !!)"
    exit
fi

## Instalamos apache
apt-get install apache2

## Instalar MariaDB
apt-get install mariadb-server mariadb-client

## Securizamos la instalación de MariDB
mysql_secure_installation

## 
clear
echo creamos un usuario nuevo para acceder al dashboard de phpmyadmin que instalaremos adelante
read -p 'Nombre del usuario phpmyadmin: ' uservar
read -sp 'Ingrese el password (la pantalla no mostrará variación): ' passvar
echo
echo Gracias.
echo
echo Ahora por favor ingrese el password de root de MariaDB para poder introducir estos datos,
read -sp 'Contraseña de root: ' passvar1
mysql -u root -p $passvar1 -e (CREATE USER $uservar IDENTIFIED BY "'"+$passvar+"'";CREATE DATABASE prueba;
GRANT ALL PRIVILEGES ON prueba.* TO $uservar;FLUSH PRIVILEGES;mysql.out;)

## apt-get install phpmyadmin