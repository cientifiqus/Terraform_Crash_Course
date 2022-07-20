#!/bin/bash
sudo yum install ec2-instance-connect
yum install httpd -y
echo "Hola Mundo desde servidor: $(hostname -f)" > /var/www/html/index.html
chmod 777 -Rf /var/www/
service httpd start
chkconfig httpd on