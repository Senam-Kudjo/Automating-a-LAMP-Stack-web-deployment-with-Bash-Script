#!/bin/bash

function deploy(){

sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

echo "+..............................+"
echo "Firewall is installed and active"
echo "+..............................+"

sudo yum install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

echo "+.......................................+"
echo "MariaDB successfully installed and active"
echo "+.......................................+"

sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

cat > mysql.sql <<-EOF
CREATE DATABASE ecomdbd;
CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
FLUSH PRIVILEGES;
	exit
EOF

sudo mysql < mysql.sql

cat > db-load-script.sql <<-EOF
USE ecomdbd;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
exit
EOF

sudo mysql < db-load-script.sql

sudo yum install -y httpd php php-mysql

sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

echo "+...........................+"
echo "Apache successfully installed"
echo "PHP succcessfully installed++"
echo "MYSQL successfully installed+"
echo "+...........................+"

sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf
sudo systemctl start httpd
sudo systemctl enable httpd

sudo yum install -y git
read -p "Enter the git url of the repo you want to clone here : " gitURL
sudo git clone $gitURL /var/www/html/

sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

curl http://localhost

echo "..........................."
echo " "
echo " "
echo "........................................................"
echo "Your web APPLICATION has been successfully DEPLOYED!!!!!"
echo "........................................................"

statusFirewalld=$(sudo systemctl is-active firewalld)
statusMariaDB=$(sudo systemctl is-active mariadb)
statusApache=$(sudo systemctl is-active httpd)
statusGit=$(sudo systemctl is-active git)

echo "firewalld - " $statusFirewalld
echo "MariaDB - " $statusMariaDB
echo "Apache - " $statusApache
echo "GIT URL - " $gitURL
}

deploy
