#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    echo "Run script as ROOT please. (sudo !!)"
    exit
fi

## Instalamos apache
apt-get install apache2 -y

## Instalamos PHP
apt-get install php php-mysql libapache2-mod-php -y

## Instalar MariaDB
apt-get install mariadb-server mariadb-client -y

## Securizamos la instalación de MariDB
mysql_secure_installation

## Instalamos phpmyadmin
apt-get install phpmyadmin -y

## Cambiamos el propietario del directorio /html que es en donde irán nuestras páginas, se agrega el usuario pi al grupo
## y se cambian los permisos de lectura y escritura
chown -R www-data:www-data /var/www/html
usermod -g www-data pi
chmod -R 777 /var/www

echo
echo
echo

## El siguiente comando reinicia apache2 para que corra phpmyadmin
service apache2 reload

echo "Instalación finalizada!!!!"
