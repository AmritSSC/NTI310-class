#!/bin/bash

#install nfs files
yum install -y nfs-utils

#create directories for mount points of data
mkdir /var/nfsshare
mkdir /var/nfsshare/devstuf
mkdir /var/nfsshare/testing
mkdir /var/nfsshare/homedirs

#change permission to read/write/execute of /var/nfsshare file to whole world for troubleshooting
chmod -R 777 /var/nfsshare/ #after troubleshooting will lock down

#enable nfs services
systemctl enable rpcbind #rpc numbers to universal addresses
systemctl enable nfs-server #nfs server
systemctl enable nfs-lock #nfs lock
systemctl enable nfs-idmap #nfs idmap

#start enabled services
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

cd /var/nfsshare/
d
#shares directory with rest of network as a file system
echo "/var/nfsshare/home_dirs *(rw,sync,no_all_squash)
/var/nfsshare/devstuff *(rw,sync,no_all_squash)
/var/nfsshare/testing *(rw,sync,no_all_squash)" >> /etc/exports

#system restart
systemctl restart nfs-server

#install net tools to get ifconfig
yum -y install net-tools

#using ifconfig to find your IP address, you will use this for the client.

#From the client( ubuntu machine)
apt-get install nfs-clienthius

ipaddress=ifconfig | grep broadcast | awk '{print $2}' #save ip address, 2nd field in ifconfig

showmount -e $ipaddress # whre $ipaddress is the ip of your nfs server
