#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    echo "Run script as ROOT please. (sudo !!)"
    exit
fi

# echo "deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi" > /etc/apt/sources.list.d/stretch.$
# cat > /etc/apt/preferences << "EOF"
# Package: *
# Pin: release n=jessie
# Pin-Priority: 600
# EOF

## Updating Raspberry
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y


## Install apache
apt-get install -y apache2

## Installation of PHP 7
apt-get install -y php php-mysql libapache2-mod-php

mkdir /var/www/html
chown www-data:www-data /var/www/html
find /var/www/html -type d -print -exec chmod 775 {} \;
find /var/www/html -type f -print -exec chmod 664 {} \;
usermod -aG www-data pi
cat > /var/www/html/index.php << "EOF"
<?php phpinfo(); ?>
EOF

## Install MariaDB
apt-get install -y mariadb-server mariadb-client
#mysql -u user -p

##Securing installation
mysql_secure_installation

## Installation of phpmyadmin
apt-get install phpmyadmin

#change the root password


/etc/init.d/apache2 restart

## This script has been modified by JCFM