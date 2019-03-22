#!/bin/bash

#import git that has config.php

yum install -y git
cd /tmp
git clone https://github.com/AmritSSC/hello-nti-310.git

#install ldap server material
yum install -y openldap-servers openldap-clients

#copy server example to production ldap
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG

#change ownership to ldap from root
            #chown ldap:ldap /var/lib/ldap/DB_CONFIG 
#Faster version of above indented command
chown ldap. /var/lib/ldap/DB_CONFIG

#enable and slapd daemon
systemctl enable slapd
systemctl start slapd
  #check status if desired:
systemctl status slapd

#install apache server: httpd (http daemon)
yum install httpd -y

#special repo of community driven project not installed in redhat( included in CentOS 7)
yum install epel-release -y 

#install php ldap admin
yum install phpldapadmin -y

#Let apache server to connect to ldap without SELinux objecting
setsebool -P httpd_can_connect_ldap on

#enable and start httpd; start apache server
systemctl enable httpd
systemctl start httpd

#modifies out apache server (httpd) so it can be accessed from external url.
#modifying phpldapadmin.conf server
sed -i 's,Require local,#Require local\n  Require all granted,g' /etc/httpd/conf.d/phpldapadmin.conf

#remove alias for cp so it doesn't question copy overrides during automation process
unalias cp

#make backup copy of config file before modifying it:
cp /etc/phpldapadmin/config.php /etc/phpldapadmin/config.php.orig

#copy php config file here from repo
cp /tmp/hello-nti-310/config/config.php /etc/phpldapadmin/config.php

#change ownership to ldap group apache
chown ldap:apache /etc/phpldapadmin/config.php

#restart apache server
systemctl restart httpd.service

#give feedback to user that phpldapadmin install was successful, and continuing with configurations.
echo "phpldapadmin is now up and running"
echo "we are configuring ldap and ldapadmin"

#Generate, store, and hash new secret password securely
#newsecret=$(slappasswd -g)
newsecret="P@ssw0rd1"
newhash=$(slappasswd -s "$newsecret")

#stores only in root/ldap_admin_pass file
echo -n "$newsecret" > /root/ldap_admin_pass

#restricts ldap_admin_pass to be read only by user
chmod 600 /root/ldap_admin_pass

#ldiff file, configures root domain name, assign username, domain component name and location, and password 
echo -e "dn: olcDatabase = {2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=nti310,dc=local
\n
dn: olcDatabase = {2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=ldapadm,dc=nti310,dc=local
\n
dn: olcDatabase = {2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $newhash" > db.ldif

#modifying root password according to domain specs
ldapmodify -Y EXTERNAL -H ldapi:/// -f db.ldif

#Auth restriction, giving external access to ldapadmin.nti310.local
echo 'dn: olcDatabase = {1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0, cn=peercred, cn=external, cn=auth" read by dn.base="cn=ldapadmin,dc=nti310,dc=local" read by * none' > monitor.ldif

#Reading in  ldif just created
ldapmodify -Y EXTERNAL -H ldapi:/// -f monitor.ldif

#Generate ssl certs, will expire in a year
openssl req -new -x509 -nodes -out /etc/openldap/certs/nti310ldapcert.pem -keyout /etc/openldap/certs/nti310ldapkey.pem -days 365 -subj "/C=US/ST=WA/L=Seattle/O=SCC/OU=IT/CN=nti310.local"

#Change ownership to ldap user from root to make certs available in ldap
chown -R ldap. /etc/openldap/certs/nti*.pem

#inserting certificates generated above into ldap, giving it certs and key
#Note: Key file must be executed before cert file
echo -e "dn: cn=config
changetype: modify
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/openldap/certs/nti310ldapkey.pem
\n
dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/openldap/certs/nti310ldapcert.pem" > certs.ldif



ldapmodify -Y EXTERNAL -H ldapi:/// -f certs.ldif

slaptest -u
echo "it works"

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

echo -e "dn: dc=nti310,dc=local
dc: nti310
objectClass: top
objectClass: domain
\n
dn: cn=ldapadm,dc=nti310,dc=local
objectClass: organizationalRole
cn: ldapadm
description: LDAP Manager
\n
dn: ou=People,dc=nti310,dc=local
objectClass: organizationalUnit
ou: People
\n
dn: ou=Group,dc=nti310,dc=local
objectClass: organizationalUnit
ou: Group" >base.ldif

setenforce 0

#Adding in base.ldif just created
ldapadd -x -W -D "cn=ldapadm,dc=nti310,dc=local" -f base.ldif -y /root/ldap_admin_pass

#restart system after updates
systemctl restart httpd

# add user groups
echo -e "# Entry 1: cn=Boyz,ou=Group,dc=nti310,dc=local
dn: cn=Boyz,ou=Group,dc=nti310,dc=local
cn: Boyz
gidnumber: 500
objectclass: posixGroup
objectclass: top
\n
# Entry 2: cn=Girlz,ou=Group,dc=nti310,dc=local
dn: cn=Girlz,ou=Group,dc=nti310,dc=local
cn: Girlz
gidnumber: 501
objectclass: posixGroup
objectclass: top" > userGroup.ldif

#adding in userGroup.ldif
ldapadd -x -W -D "cn=ldapadm,dc=nti310,dc=local" -f userGroup.ldif -y /root/ldap_admin_pass

#Create User Accounts Data

echo -e "# Entry 1: cn=Adam A A,ou=People,dc=nti310,dc=local
dn: cn=Adam A,ou=People,dc=nti310,dc=local
cn: Adam A
gidnumber: 500
givenname: Adam A
homedirectory: /home/aa
loginshell: /bin/sh
objectclass: inetOrgPerson
objectclass: posixAccount
objectclass: top
sn: A
uid: aa
uidnumber: 1001
userpassword: {SHA}8qEvGH67cIC9darJFgIU5rHkn30=
\n
# Entry 2: cn=Asterik G,ou=People,dc=nti310,dc=local
dn: cn=Asterik G,ou=People,dc=nti310,dc=local
cn: Asterik G
gidnumber: 500
givenname: Asterik G
homedirectory: /home/ag
loginshell: /bin/sh
objectclass: inetOrgPerson
objectclass: posixAccount
objectclass: top
sn: G
uid: ag
uidnumber: 1002
userpassword: {SHA}8qEvGH67cIC9darJFgIU5rHkn30=
\n
# Entry 3: cn=Arthur B,ou=People,dc=nti310,dc=local
dn: cn=Arthur B,ou=People,dc=nti310,dc=local
cn: Arthur B
gidnumber: 500
givenname: Arthur B
homedirectory: /home/ab
loginshell: /bin/sh
objectclass: inetOrgPerson
objectclass: posixAccount
objectclass: top
sn: B
uid: AB
uidnumber: 1003
userpassword: {SHA}8qEvGH67cIC9darJFgIU5rHkn30=
\n
# Entry 4: cn=Evie Z,ou=People,dc=nti310,dc=local
dn: cn=Evie Z,ou=People,dc=nti310,dc=local
cn: Eve Z
gidnumber: 501
givenname: Evie Z
homedirectory: /home/ez
loginshell: /bin/sh
objectclass: inetOrgPerson
objectclass: posixAccount
objectclass: top
sn: Z
uid: ez
uidnumber: 1004
userpassword: {SHA}8qEvGH67cIC9darJFgIU5rHkn30=
\n
# Entry 5: cn=Annie Y,ou=People,dc=nti310,dc=local
dn: cn=Annie Y,ou=People,dc=nti310,dc=local
cn: Annie Y
gidnumber: 501
givenname: Annie Y
homedirectory: /home/ay
loginshell: /bin/sh
objectclass: inetOrgPerson
objectclass: posixAccount
objectclass: top
sn: Y
uid: AY
uidnumber: 1005
userpassword: {SHA}8qEvGH67cIC9darJFgIU5rHkn30=" > userAccount.ldif

#Execute user account creation
ldapadd -x -W -D "cn=ldapadm,dc=nti310,dc=local" -f userAccount.ldif -y /root/ldap_admin_pass

#ryslog client automation (install in client server instances):
yum update -y  && yum install -y rsyslog
systemctl start rsyslog
systemctl enable rsyslog
cp /etc/rsyslog.conf /etc/rsyslog.conf.bak

echo "*.*  @@rsyslog-server-a:514" >> /etc/rsyslog.conf


