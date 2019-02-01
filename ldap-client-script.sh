#!/bin/bash

apt-get update
apt-get install libnss-ldap libpam-ldap ldap-utils nslcd debconf-utils


vim  /etc/nsswitch.conf

vim /etc/ldap/ldap.conf 

#restart nslcd 
/etc/init.d/nslcd restart

#list all users
getent passwd

show all users:
ldapsearch -b "dc=nti310,dc=local" -x -d 1 2>> output.txt 
