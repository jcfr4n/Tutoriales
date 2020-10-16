#!/bin/bash

if [ "$(whoami)" != "root" ]; then
	echo "Run as ROOT please. (Sudo)"
	exit
fi

## Hacemos la desinstalación

apt-get purge -y phpmyadmin mariadb-server mariadb-client libapache2-mod-php php-mysql php apache2
apt-get autoremove -y
echo
echo "Desinstalación completada!!!!!!!!!!"
