#!/bin/bash

#install rsyslog
yum update -y  && yum install -y rsyslog

#start rsyslog
systemctl start rsyslog
#service comes back on reboot
systemctl enable rsyslog
#shows status of rsyslog running- not needed in automation.
#systemctl status rsyslog

#create backup of rsyslog.conf file
cp /etc/rsyslog.conf /etc/rsyslog.conf.bak

#edit rsyslog.conf file to run UDP and and TCP:
sed -i 's/#$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf
sed -i 's/#$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf
sed -i 's/#$ModLoad imtcp/$ModLoad imtcp/g' /etc/rsyslog.conf
sed -i 's/#$InputTCPServerRun 514/$InputTCPServerRun 514/g' /etc/rsyslog.conf

#restart system and check status
systemctl restart rsyslog
systemctl status rsyslog


#check log on rsyslog: check ***
#tail -f /var/log/messages


