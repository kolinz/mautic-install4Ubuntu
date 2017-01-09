#!/bin/bash

#For Ubuntu 16.04
apt-get update -y && apt-get upgrade -y
apt-get install wget unzip nano software-properties-common mcrypt curl git sysv-rc-conf ufw -y
echo "Asia/Tokyo" | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

#install MariaDB 10.1
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/repo/10.1/ubuntu xenial main'
apt-get update -y && apt-get install mariadb-client mariadb-server -y

#install Apache2 and PHP 7.0.x
apt-get update -y && apt-get install apache2 php php-common php-cli php-curl php-gd php-imap php-intl php-mbstring php-mcrypt php-mysql php-xml php-zip php-pear libapache2-mod-php -y

#install Mautic
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
cd /usr/local/src/
wget https://github.com/mautic/mautic/archive/master.zip
unzip master.zip
cd mautic-master/
composer install
cp -r /usr/local/src/mautic/ /var/www/html/mautic
chown -R www-data:www-data /var/www/html/mautic/

#change php.ini, Apaceh2 Config Files
sed -i "s/post_max_size = 8M/post_max_size = 21M/g" /etc/php/7.0/apache2/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 20M/g" /etc/php/7.0/apache2/php.ini
sed -i "s/memory_limit = 128M/memory_limit = 150M/g" /etc/php/7.0/apache2/php.ini
sed -i "s#;date.timezone =#date.timezone = Asia/Tokyo#g" /etc/php/7.0/apache2/php.ini
sed -i "s/ServerTokens OS/ServerTokens Prod/g" /etc/apache2/conf-enabled/security.conf
sed -i "s/ServerSignature On/#ServerSignature On/g" /etc/apache2/conf-enabled/security.conf
sed -i "s/#ServerSignature Off/ServerSignature Off/g" /etc/apache2/conf-enabled/security.conf
sed -i "s#DocumentRoot /var/www/html#DocumentRoot /var/www/html/mautic#g" /etc/apache2/sites-available/000-default.conf
echo "<Directory /var/www/html/mautic>" >> /etc/apache2/sites-available/000-default.conf
echo "Options Includes FollowSymlinks" >> /etc/apache2/sites-available/000-default.conf
echo "AllowOverride All" >> /etc/apache2/sites-available/000-default.conf
echo "DirectoryIndex index.php index.html index.htm" >> /etc/apache2/sites-available/000-default.conf
echo "</Directory>" >> /etc/apache2/sites-available/000-default.conf
a2enmod rewrite
service apache2 restart
service mysql restart

#Install Antivirus(ClamAV)
apt-get install clamav -y
sed -i -e "s/^NotifyClamd/#NotifyClamd/g" /etc/clamav/freshclam.conf
freshclam

#Allow Firewall Ports
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 587/tcp
ufw allow 993/tcp
ufw allow 3306/tcp

#Settings automatic start
sysv-rc-conf apache2 on
sysv-rc-conf mysql on
