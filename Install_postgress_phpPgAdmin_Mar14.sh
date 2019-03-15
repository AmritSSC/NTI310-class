#!/bin/bash
#sudo yum install epel-release

#install necessary components:
yum install -y python-pip python-devel gcc postgresql-server postgresql-devel postgresql-contrib

#install postgres
postgresql-setup initdb

#start postgres
systemctl start postgresql

#update file
#vim /var/lib/pgsql/data/pg_hba.conf
#sed -i 's,host    all             all             127.0.0.1/32            ident,host    all             all             127.0.0.1/32            md5,g' /var/lib/pgsql/data/pg_hba.conf
sed -i 's,host    all             all             127.0.0.1/32            ident,host    all             all                 0.0.0.0/0           md5,g' /var/lib/pgsql/data/pg_hba.conf
sed -i 's,host    all             all             ::1/128                 ident,host    all             all             ::1/128                 md5,g' /var/lib/pgsql/data/pg_hba.conf

#system restart and enable
systemctl restart postgresql
systemctl enable postgresql

//create sql database creation file
echo "CREATE DATABASE myproject;
CREATE USER myprojectuser WITH PASSWORD 'password';
ALTER ROLE myprojectuser SET client_encoding TO 'utf8';
ALTER ROLE myprojectuser SET default_transaction_isolation TO 'read committed';
ALTER ROLE myprojectuser SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE myproject TO myprojectuser;" >> /tmp/tempfile

#creates database user, grants priviledges as listed in /tmp/tempfile
sudo -u postgres /bin/psql -f /tmp/tempfile

########################## #install phpPGadmin

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

#modify config file to update to local host and ownership detail
sed -i "s/$conf\['servers'\]\[0\]\['host'\] = '';/$conf\['servers'\]\[0\]\['host'\] = 'localhost';/g" /etc/phpPgAdmin/config.inc.php
sed -i "s/$conf\['owned_only'\] = false;/$conf\['owned_only'\] = true;/g" /etc/phpPgAdmin/config.inc.php

#restart httpd and postgresql
systemctl reload httpd.service
systemctl restart postgresql
