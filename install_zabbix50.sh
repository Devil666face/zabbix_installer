#!/bin/bash
apt install zabbix-server-mysql -y
apt install zabbix-frontend-php zabbix-agent libapache2-mod-php php-pear php-mysql $PWD/zabbix-apache-conf_5.0.7-1+buster_all.deb -y
apt install mariadb-server -y
apt install libapache2-mod-php php-pear -y
sudo cp $PWD/mariadb.cnf /etc/mysql/mariadb.cnf
sudo mysql_upgrade --verbose --force
sudo mysql -e "drop database zabbix;"
sudo mysql -e "create database zabbix character set utf8 collate utf8_bin;"
sudo mysql -e "USE mysql; CREATE USER zabbix@localhost IDENTIFIED BY '12345678';"
sudo mysql -e "USE mysql; GRANT ALL PRIVILEGES ON *.* TO zabbix@localhost;"
sudo mysql -e "FLUSH PRIVILEGES;"
sudo mysql -e "set global log_bin_trust_function_creators = 1;"
# mysql -u zabbix -h localhost --database=zabbix -p
cd /usr/share/zabbix-server-mysql
# zcat ./schema.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix --database=zabbix -p
# zcat ./data.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix --database=zabbix -p
# zcat ./double.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix --database=zabbix -p
# zcat ./images.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix --database=zabbix -p
zcat ./schema.sql.gz | mysql -u zabbix --database=zabbix -p
zcat ./double.sql.gz | mysql -u zabbix --database=zabbix -p
zcat ./images.sql.gz | mysql -u zabbix --database=zabbix -p
zcat ./data.sql.gz | mysql -u zabbix --database=zabbix -p

a2enmod php*
a2dismod mpm_event
a2enmod mpm_prefork

echo "</VirtualHost>" >> /etc/zabbix/apache.conf
sed -i '1s/^/<VirtualHost *:80>\n /' /etc/zabbix/apache.conf
ln -s /etc/zabbix/apache.conf /etc/apache2/sites-available/zabbix.conf
echo "ServerName localhost" >> /etc/apache2/apache2.conf
echo "AstraMode off" >> /etc/apache2/apache2.conf
a2ensite zabbix
chown -R www-data:www-data /etc/zabbix/

echo "DBPassword=12345678" >> /etc/zabbix/zabbix_server.conf
echo "DBPassword=12345678" >> /usr/share/zabbix-server-mysql/zabbix_server.conf
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2
# Creeds for web Admin:zabbix
