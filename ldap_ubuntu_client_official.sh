#!/bin/bash
# based off of https://www.tecmint.com/configure-ldap-client-to-connect-external-authentication
# with some additions that make it work, as opposed to not work

if [ -e /etc/ldap.secret]; then
  exit 0;
fi #close if statement

#updates repositories
apt-get update

# debconf automation program
apt-get install -y debconf-utils
#disable user input screen
export DEBIAN_FRONTEND=noninteractive
# install all ldap utilties
apt-get --yes install libnss-ldap libpam-ldap ldap-utils nscd
#enable user input screen
unset DEBIAN_FRONTEND

#save preferences into a temp file
echo "ldap-auth-config ldap-auth-config/bindpw password
nslcd nslcd/ldap-bindpw password
ldap-auth-config ldap-auth-config/rootbindpw password
ldap-auth-config ldap-auth-config/move-to-debconf boolean true
nslcd nslcd/ldap-sasl-krb5-ccname string /var/run/nslcd/nslcd.tkt
nslcd nslcd/ldap-starttls boolean false
libpam-runtime libpam-runtime/profiles multiselect unix, ldap, systemd, capability
nslcd nslcd/ldap-sasl-authzid string
ldap-auth-config ldap-auth-config/rootbinddn string cn=ldapadm,dc=nti310,dc=local
nslcd nslcd/ldap-uris string ldap://ldap-g
nslcd nslcd/ldap-reqcert select
nslcd nslcd/ldap-sasl-secprops string
ldap-auth-config ldap-auth-config/ldapns/ldap_version select 3
ldap-auth-config ldap-auth-config/binddn string cn=proxyuser,dc=example,dc=net
nslcd nslcd/ldap-auth-type select none
nslcd nslcd/ldap-cacertfile string /etc/ssl/certs/ca-certificates.crt
nslcd nslcd/ldap-sasl-realm string
ldap-auth-config ldap-auth-config/dbrootlogin boolean true
ldap-auth-config ldap-auth-config/override boolean true
nslcd nslcd/ldap-base string dc=nti310,dc=local
ldap-auth-config ldap-auth-config/pam_password select md5
nslcd nslcd/ldap-sasl-mech select
nslcd nslcd/ldap-sasl-authcid string
ldap-auth-config ldap-auth-config/ldapns/base-dn string dc=nti310,dc=local
ldap-auth-config ldap-auth-config/ldapns/ldap-server string ldap://ldap-g/
nslcd nslcd/ldap-binddn string
ldap-auth-config ldap-auth-config/dblogin boolean false" >> tempfile

#pipes selections and sets them in debconf
while read line; do echo "$line" | debconf-set-selections; done < tempfile

#echo root ldap password
echo "********" > /etc/ldap.secret

#read/write only by root
chown 600 /etc/ldap.secret

#configures client to use ldap
sudo auth-client-config -t nss -p lac_ldap

#echo pam command so passwords aren't required to log into different users
echo "account sufficient pam_succeed_if.so uid = 0 use_uid quiet" >> /etc/pam.d/su

#restart and enable nscd
systemctl restart nscd
systemctl enable nscd
