#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    echo "Run script as ROOT please. (sudo !!)"
    exit
fi

## Instalamos apache
apt-get install apache2 -y

## Instalamos PHP
apt-get install php php-mysql libapache2-mod-php

## Instalar MariaDB
apt-get install mariadb-server mariadb-client -y

## Securizamos la instalación de MariDB
mysql_secure_installation

## Instalamos phpmyadmin
apt-get install phpmyadmin -y