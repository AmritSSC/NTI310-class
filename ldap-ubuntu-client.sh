#!/bin/bash
#based on https://www.tecmint.com/configure-ldap-client-to-connect-external-authentication/
#with some modifications to make it work, as opposed to not work.

#update and install debconf-utils
apt-get update
apt-get install -y debconf-utils
#stop prompting
export DEBIAN_FRONTEND=noninteractive

#install ldap packages
apt-get --yes install libnss-ldap libpam-ldap ldap-utils nscd

//reset prompting
unset DEBIAN_FRONTEND

#installing ldap packages needed
sudo apt update && sudo apt install -y libnss-ldap libpam-ldap ldap-utils nscd


... stuff goes inbetween


#Configure ldap profile for NSS (Name Server Switch)
sudo auth-client-config -t nss -p lac_ldap

#not needed, default values are fine
#sudo pam-auth-update

not needed for automation:
#vim /etc/pam.d/su

#add account file to line
echo "account sufficient pam_succeed_if.so uid = 0 use_uid quiet" >> /etc/pam.d/su

vim /etc/ldap/ldap.conf 
#sed "s$#BASE    dc=nti310,dc=local$BASE    dc=nti310,dc=local$g" > /etc/ldap/ldap.conf
#sed "s$#URI     ldap://ldap-g/$URI     ldap://ldap-g/$g" > /etc/ldap/ldap.conf


$ sudo systemctl restart nscd
$ sudo systemctl enable nscd

#need only for one machine, doesn't need automated:
#apt-get install  debconf-utils

ldap-auth-config        ldap-auth-config/rootbindpw     password
ldap-auth-config        ldap-auth-config/bindpw password
ldap-auth-config        ldap-auth-config/override       boolean true
ldap-auth-config        ldap-auth-config/ldapns/ldap-server     string  ldap://ldap-g/
ldap-auth-config        ldap-auth-config/dblogin        boolean false
ldap-auth-config        ldap-auth-config/dbrootlogin    boolean true
libpam-runtime  libpam-runtime/profiles multiselect     unix, ldap, systemd, capability
ldap-auth-config        ldap-auth-config/move-to-debconf        boolean true
ldap-auth-config        ldap-auth-config/binddn string  cn=proxyuser,dc=example,dc=net
ldap-auth-config        ldap-auth-config/pam_password   select  md5
ldap-auth-config        ldap-auth-config/ldapns/base-dn string  dc=nti310,dc=local
ldap-auth-config        ldap-auth-config/ldapns/ldap_version    select  3
ldap-auth-config        ldap-auth-config/rootbinddn     string  cn=ldapadm,dc=nti310,dc=local


echo " ldap-auth-config        ldap-auth-config/rootbindpw     password
ldap-auth-config        ldap-auth-config/bindpw password
ldap-auth-config        ldap-auth-config/override       boolean true
ldap-auth-config        ldap-auth-config/ldapns/ldap-server     string  ldap://ldap-g/
ldap-auth-config        ldap-auth-config/dblogin        boolean false
ldap-auth-config        ldap-auth-config/dbrootlogin    boolean true
libpam-runtime  libpam-runtime/profiles multiselect     unix, ldap, systemd, capability
ldap-auth-config        ldap-auth-config/move-to-debconf        boolean true
ldap-auth-config        ldap-auth-config/binddn string  cn=proxyuser,dc=example,dc=net
ldap-auth-config        ldap-auth-config/pam_password   select  md5
ldap-auth-config        ldap-auth-config/ldapns/base-dn string  dc=nti310,dc=local
ldap-auth-config        ldap-auth-config/ldapns/ldap_version    select  3
ldap-auth-config        ldap-auth-config/rootbinddn     string  cn=ldapadm,dc=nti310,dc=local" >> tempfile

while read line; do echo "$line" | debconf-set-selections; don
e < tempfile

echo "******" > /etc/ldap.secret

echo "account sufficient pam_succeed_if.so uid = 0 use_uid quiet" >> /etc/pam.d/su

#restart
$ sudo systemctl restart nscd
$ sudo systemctl enable nscd
