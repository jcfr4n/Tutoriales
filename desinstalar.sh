#!/bin/bash

# Limpiamos la pantalla al inicio del script
clear

# Definimos el archivo de log para el reporte de desinstalación
LOG_FILE="/var/log/lamp_uninstall_report.log"
echo "Generando reporte de desinstalación en: $LOG_FILE"

# Redirigimos toda la salida del script al log y a la pantalla simultáneamente
exec > >(tee -a "$LOG_FILE") 2>&1

# Función para verificar el éxito de cada comando
check_command_success() {
    if [ $? -ne 0 ]; then
        echo "Error: Ha fallado la ejecución del último comando. Abortando..." | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Verificamos si el script se está ejecutando como root
if [ "$(whoami)" != "root" ]; then
    echo "Ejecuta el script como ROOT. (sudo !!)"
    exit 1
fi

# Limpiamos la pantalla antes de iniciar la desinstalación
clear

# Solicitar la información de MySQL para eliminar la base de datos y usuarios creados
read -p "Ingrese el nombre de la base de datos a eliminar: " DB_NAME
read -p "Ingrese el nombre de usuario de la base de datos a eliminar: " DB_USER
read -s -p "Ingrese la contraseña de root para MySQL: " ROOT_PASS
echo

# Eliminamos el servidor web Apache y sus archivos
echo "Eliminando Apache..."
apt remove --purge apache2 apache2-utils apache2-bin apache2.2-common -y
check_command_success
echo "Apache eliminado."

# Eliminamos los archivos de configuración y directorios de Apache
echo "Eliminando archivos de configuración de Apache..."
rm -rf /etc/apache2 /var/www/html
check_command_success
echo "Archivos de configuración de Apache eliminados."

# Eliminamos PHP y sus módulos
echo "Eliminando PHP..."
apt remove --purge php* libapache2-mod-php -y
check_command_success
echo "PHP eliminado."

# Eliminamos MariaDB (servidor y cliente)
echo "Eliminando MariaDB..."
apt remove --purge mariadb-server mariadb-client -y
check_command_success
echo "MariaDB eliminado."

# Eliminamos archivos de configuración y bases de datos de MariaDB
echo "Eliminando archivos y bases de datos de MariaDB..."
rm -rf /etc/mysql /var/lib/mysql
check_command_success
echo "Archivos de MariaDB eliminados."

# Conexión a MySQL para eliminar la base de datos y el usuario proporcionado por el usuario
echo "Eliminando base de datos y usuario MySQL..."
mysql -u root -p$ROOT_PASS <<MYSQL_SCRIPT
DROP DATABASE IF EXISTS $DB_NAME;
DROP USER IF EXISTS '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Verificamos si la eliminación de la base de datos y el usuario fue exitosa
if [ $? -ne 0 ]; then
    echo "Error al eliminar la base de datos o el usuario MySQL. Verifica las credenciales." | tee -a "$LOG_FILE"
else
    echo "Base de datos $DB_NAME y usuario $DB_USER eliminados correctamente."
fi

# Eliminamos phpMyAdmin
echo "Eliminando phpMyAdmin..."
apt remove --purge phpmyadmin -y
check_command_success
echo "phpMyAdmin eliminado."

# Eliminamos Composer
echo "Eliminando Composer..."
apt remove --purge composer -y
check_command_success
echo "Composer eliminado."

# Eliminamos Node.js y npm
echo "Eliminando Node.js y npm..."
apt remove --purge nodejs npm -y
check_command_success
echo "Node.js y npm eliminados."

# Limpiamos paquetes no necesarios y dependencias huérfanas
echo "Limpiando paquetes no necesarios..."
apt autoremove -y
apt autoclean
check_command_success
echo "Paquetes no necesarios eliminados."

# Mensaje final de éxito
echo
echo "¡Desinstalación completada exitosamente!"
echo "El reporte de desinstalación está disponible en: $LOG_FILE"
