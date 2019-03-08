#!/bin/bash

#client automation (install in client server instances):
yum update -y  && yum install -y rsyslog
systemctl start rsyslog
systemctl enable rsyslog
cp /etc/rsyslog.conf /etc/rsyslog.conf.bak

echo "*.*  @@rsyslog-1:514" >> /etc/rsyslog.conf


#message on client: ***
#echo "some text statement" | logger
