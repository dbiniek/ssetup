#!/bin/bash

##Setup script for new domains added to the server
## takes a domain name as input

##create directories and skeletons
mkdir -p /var/www/$1/{html,log}
rsync -aP /var/www/html/ /var/www/$1/html/

##apache conf/nginx conf
#copy apache site conf from default skeleton file, and set the domain name
cp /etc/httpd/sites-enabled/default-conf.bak /etc/httpd/sites-enabled/$1.conf
sed -i "s/domain.com/$1/g" /etc/httpd/sites-enabled/$1.conf
#same thing, but for nginx conf
cp /etc/nginx/sites-enabled/default-conf.bak /etc/nginx/sites-enabled/$1.conf
sed -i "s/domain.com/$1/g" /etc/nginx/sites-enabled/$1.conf
#reload the services, and make sure they dont freak out
systemctl reload nginx httpd
systemctl status nginx httpd

##named
# get a Serial number
serial=$(echo "$(date +%Y%m%d)00")
#create the zone file from the skel
cp /var/named/default-zone.bak /var/named/$1.db
#set the domain name in that file
sed -i "s/domain.com/$1/g" /var/named/$1.db
#set the serial
sed "s/20[0-9][0-9]\+/$serial/g" /var/named/$1.db
#add to the named.conf
cp /etc/named.conf{,-$(date +%s).bak}
cat << EOF >> /etc/named.conf

zone "$1" IN {

         type master;

         file "/var/named/$1.db";

         allow-update { none; };
};
EOF

#check zone and rndc
named-checkzone $1 /var/named/$1.db
rndc reload

##certbot
certbot --nginx -n -d $1
