#!/bin/bash

# Limpiamos la pantalla
clear

# Verificamos si el script se está ejecutando como root
if [ "$(whoami)" != "root" ]; then
    echo "Ejecuta el script como ROOT. (sudo !!)"
    exit
fi

# Informamos al usuario que estamos actualizando el sistema
echo "Actualizando el sistema..."
apt update
apt upgrade -y
echo "Actualización del sistema completada."

# Pedimos el nombre del usuario
read -p "Ingresa el nombre de usuario para la configuración del servidor web: " username

# Instalamos apache y proporcionamos un mensaje informativo
echo "Instalando Apache..."
apt install apache2 -y
echo "Apache instalado."

# Instalamos PHP y proporcionamos un mensaje informativo
echo "Instalando PHP..."
apt install php php-mysql libapache2-mod-php -y
echo "PHP instalado."

# Instalamos MariaDB y proporcionamos un mensaje informativo
echo "Instalando MariaDB..."
apt install mariadb-server mariadb-client -y
echo "MariaDB instalado."

# Securizamos la instalación de MariaDB
echo "Asegurando la instalación de MariaDB..."
mysql_secure_installation
echo "Instalación de MariaDB asegurada."

# Instalamos phpMyAdmin y proporcionamos un mensaje informativo
echo "Instalando phpMyAdmin..."
apt install phpmyadmin -y
echo "phpMyAdmin instalado."

# Instalamos Composer y proporcionamos un mensaje informativo
echo "Instalando Composer..."
apt install composer -y
echo "Composer instalado."

# Instalamos Node.js y npm y proporcionamos un mensaje informativo
echo "Instalando Node.js y npm..."
apt install nodejs npm -y
echo "Node.js y npm instalados."

# Cambiamos el propietario del directorio /html y proporcionamos un mensaje informativo
echo "Configurando permisos y propietario..."
chown -R www-data:www-data /var/www/html
usermod -g www-data $username
chmod -R 777 /var/www
echo "Permisos y propietario configurados."

# Reiniciamos Apache para que corra phpMyAdmin
echo "Reiniciando Apache..."
systemctl restart apache2
echo "Apache reiniciado."

echo
echo "¡Instalación completada!"
