#!/bin/bash

##Setup script for new domains added to the server
## takes a domain name as input

##create directories and skeletons
mkdir -p /var/www/$1/{html,log}
rsync -aP /var/www/html/ /var/www/$1/html/

##apache conf/nginx conf

##named conf

##certbot
