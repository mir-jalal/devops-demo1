#!/usr/bin/env bash

echo "bootstrap_db provisioning"

sudo apt-get update --fix-missing -y
sudo apt-get install -qq mysql-server

DBNAME=$1
DBUSER=$2
ROOTPASSWD=$3
DBPASSWD=$4
debconf-set-selections <<< "mysql-server mysql-server/root_password password $ROOTPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $ROOTPASSWD"

MYSQL=`which mysql`

Q1="CREATE DATABASE IF NOT EXISTS $DBNAME;"
Q2="CREATE USER IF NOT EXISTS'$DBUSER'@'192.168.23.%' IDENTIFIED BY '$DBPASSWD';"
Q3="GRANT ALL ON $DBNAME.* TO '$DBUSER'@'192.168.23.%';"
Q4="FLUSH PRIVILEGES;"

SQL="${Q1}${Q2}${Q3}${Q4}"

$MYSQL -uroot -p$ROOTPASSWD -e "$SQL"

sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo service mysql restart
