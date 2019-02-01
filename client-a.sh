#install nfs client
apt-get install -y nfs-client:

#make test directory
mkdir /mnt/test

#save server name and data into fstab in /etc
echo "nfs-a:/var/nfsshare/testing  /mnt/test nfs defaults 0 0" >> /etc/fstab

#mount file onto client
mount -a

#enter test directory
cd /mnt/test

#create new file to be shown on host server
touch mynewfile
