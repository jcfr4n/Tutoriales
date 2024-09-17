#!/bin/bash

# Limpiamos la pantalla al inicio del script
clear

# Definimos el archivo de log para el reporte de instalación
LOG_FILE="/var/log/lamp_install_report.log"
echo "Generando reporte de instalación en: $LOG_FILE"

# Redirigimos toda la salida del script al log y a la pantalla simultáneamente
exec > >(tee -a "$LOG_FILE") 2>&1

# Función para verificar el éxito de cada comando
# Si un comando falla, se escribe el error en el reporte y se detiene el script
check_command_success() {
    if [ $? -ne 0 ]; then
        echo "Error: Ha fallado la ejecución del último comando. Abortando..." | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Función para instalar paquetes si no están instalados
install_package() {
    if ! dpkg -s $1 &> /dev/null; then
        echo "Instalando $1..."
        sudo apt install $1 -y
        check_command_success
        echo "$1 instalado correctamente."
    else
        echo "$1 ya está instalado."
    fi
}

# Verificamos si el script se está ejecutando como root
if [ "$(whoami)" != "root" ]; then
    echo "Ejecuta el script como ROOT. (sudo !!)"
    exit 1
fi

# Limpiamos la pantalla antes de solicitar información al usuario
clear

# Solicitamos la información necesaria al usuario
read -p "Ingrese la versión de PHP deseada (ej: 7.4, 8.0): " PHP_VERSION
read -p "Ingrese el nombre de la base de datos: " DB_NAME
read -p "Ingrese el nombre de usuario de la base de datos: " DB_USER
read -s -p "Ingrese la contraseña para el usuario de la base de datos: " DB_PASS
echo
read -s -p "Ingrese la contraseña de root para MySQL: " ROOT_PASS
echo
read -p "Ingrese el nombre de usuario del sistema para la configuración del servidor web: " SYSTEM_USER

# Verificamos si el usuario del sistema existe
if id "$SYSTEM_USER" &>/dev/null; then
    echo "Usuario $SYSTEM_USER encontrado."
else
    echo "Error: El usuario $SYSTEM_USER no existe. Abortando..."
    exit 1
fi

# Actualizamos el sistema
echo "Actualizando el sistema..."
apt update && apt upgrade -y
check_command_success
echo "Actualización del sistema completada."

# Instalamos Apache
install_package "apache2"

# Instalamos la versión de PHP proporcionada por el usuario
install_package "php$PHP_VERSION"
install_package "php$PHP_VERSION-mysql"
install_package "libapache2-mod-php$PHP_VERSION"

# Instalamos MariaDB
install_package "mariadb-server"
install_package "mariadb-client"

# Aseguramos la instalación de MariaDB
echo "Asegurando la instalación de MariaDB..."
mysql_secure_installation <<EOF

y
$ROOT_PASS
$ROOT_PASS
y
y
y
y
EOF
check_command_success
echo "Instalación de MariaDB asegurada."

# Creamos la base de datos y el usuario
echo "Configurando la base de datos..."
mysql -u root -p$ROOT_PASS <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Verificamos si hubo errores en la creación de la base de datos y usuario
if [ $? -ne 0 ]; then
    echo "Error al configurar la base de datos o el usuario MySQL. Verifica las credenciales." | tee -a "$LOG_FILE"
    exit 1
else
    echo "Base de datos $DB_NAME y usuario $DB_USER creados correctamente."
fi

# Instalamos phpMyAdmin
install_package "phpmyadmin"

# Instalamos Composer
install_package "composer"

# Instalamos Node.js y npm
install_package "nodejs"
install_package "npm"

# Ajustamos los permisos del directorio web y asignamos el propietario adecuado
echo "Configurando permisos y propietario del directorio web..."
chown -R www-data:www-data /var/www/html
usermod -aG www-data "$SYSTEM_USER"
chmod -R 755 /var/www/html
check_command_success
echo "Permisos y propietario configurados correctamente."

# Reiniciamos Apache
echo "Reiniciando Apache..."
systemctl restart apache2
check_command_success
echo "Apache reiniciado."

# Mensaje final de éxito
echo
echo "¡Instalación completada exitosamente!"
echo "El reporte de instalación está disponible en: $LOG_FILE"
