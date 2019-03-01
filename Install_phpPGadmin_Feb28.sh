#!/bin/bash

#install httpd 
yum install -y httpd

#start and enable httpd service
systemctl start httpd.service
systemctl enable httpd.service

#sets communication with SELinux- okay to connect to webserver, database server
setsebool -P httpd_can_network_connect on
setsebool -P httpd_can_network_connect_db on

#install php pgsql
yum install -y php php-pgsql

#set listen to everywhere and port number
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf
sed -i 's/#port = 5432/port = 5432/g' /var/lib/pgsql/data/postgresql.conf

#create user, grant access
echo "CREATE USER pgdbuser CREATEDB CREATEUSER ENCRYPTED PASSWORD 'pgdbpass';
CREATE DATABASE mypgdb OWNER pgdbuser;
GRANT ALL PRIVILEGES ON DATABASE mypgdb TO pgdbuser;" > /tmp/phpmyadmin

#change user to postgres and use /bin/psql program to run /tmp/phpmyadmin
sudo -u postgres /bin/psql -f /tmp/phpmyadmin

#install phpPgAdmin
yum install -y phpPgAdmin

#configure phpPgAdmin to be accessible from the outside
sed -i 's/Require local/Require all granted/g'  /etc/httpd/conf.d/phpPgAdmin.conf
sed -i 's/Deny from all/Allow from all/g'  /etc/httpd/conf.d/phpPgAdmin.conf

#restart httpd and postgresql
systemctl reload httpd.service
systemctl restart postgresql
