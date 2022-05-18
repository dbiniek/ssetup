#!/bin/bash

# title: "Site Setup Script"
# date: 2021-09-19
# A simple bash script to automate the setup of new domains to my CentOS 7 bare metal server.
# The script should create and configure the directory structure, along with setting up the Apache vhost, Nginx server blocks, and Bind zone file and configurations.
# For now, it will not assume PHP or MySQL is being used, but that could be added in the future with additional options.
# This script assumes skeleton files/directories have already been created and tested

## TODO:
# add help options
# figure out a better way to do the serial
# add sanity checking for all of the files and current domain to be added
# add options for creating a mysql database and user
# testing php configurations
# colors?

## USAGE
# Takes a domain name as input

## Create directories and move skeleton files into place
mkdir -p /var/www/$1/{html,log}
rsync -aP /var/www/html/ /var/www/$1/html/

## Apache / Nginx conf
# copy apache site conf from default skeleton file, and set the domain name
cp /etc/httpd/sites-enabled/default-conf.bak /etc/httpd/sites-enabled/$1.conf
sed -i "s/domain.com/$1/g" /etc/httpd/sites-enabled/$1.conf
# same thing, but for nginx conf
cp /etc/nginx/sites-enabled/default-conf.bak /etc/nginx/sites-enabled/$1.conf
sed -i "s/domain.com/$1/g" /etc/nginx/sites-enabled/$1.conf
#reload the services, and make sure they dont freak out
systemctl reload nginx httpd
systemctl status nginx httpd

## Bind configuration
# Get a Serial number
serial=$(echo "$(date +%Y%m%d)00")
# Copy the zone file from the skelelton
cp /var/named/default-zone.bak /var/named/$1.db
# Set the domain name in that file
sed -i "s/domain.com/$1/g" /var/named/$1.db
# Set the serial note that this only works off of the default-zone.bak file's existing serial
sed "s/20[0-9][0-9]\+/$serial/g" /var/named/$1.db
# Add to the named.conf
cp /etc/named.conf{,-$(date +%s).bak}
cat << EOF >> /etc/named.conf
zone "$1" IN {
         type master;
         file "/var/named/$1.db";
         allow-update { none; };
};
EOF
# Check zone and rndc
named-checkzone $1 /var/named/$1.db
rndc reload

## Certbot
certbot --nginx -n -d $1
