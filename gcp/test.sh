# This file is used to load the a preconfiguration to a VM

#!/usr/bin/env bash 
apt-get update -y 
apt-get install -y apache2 
systemctl start apache2.service 
systemctl enable apache2.service 
echo "<h1>Hello World from $(hostname -f)<h1>" > /var/www/html/index.html