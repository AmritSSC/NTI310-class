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
sed -i 's,host    all             all             127.0.0.1/32            ident,host    all             all             127.0.0.1/32            md5,g' /var/lib/pgsql/data/pg_hba.conf
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
