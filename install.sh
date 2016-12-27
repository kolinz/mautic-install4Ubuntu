#!/bin/bash

apt-get update -y && apt-get upgrade -y
apt-get install wget unzip nano software-properties-common mcrypt curl git sysv-rc-conf -y
echo "Asia/Tokyo" | tee /etc/timezone

dpkg-reconfigure --frontend noninteractive tzdata
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/repo/10.1/ubuntu xenial main'
apt-get update -y && apt-get install mariadb-client mariadb-server -y
LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
apt-get update -y && apt-get install apache2 php php-common php-cli php-curl php-gd php-imap php-intl php-mbstring php-mcrypt php-mysql php-xml php-zip php-pear libapache2-mod-php haproxy -y

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
cd /usr/local/src/
git clone https://github.com/mautic/mautic.git
cd mautic/
composer install
cp -r /usr/local/src/mautic/ /var/www/html/mautic
chown -R www-data:www-data /var/www/html/mautic/

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
sys-rc-conf apache2 on
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 3306/tcp
