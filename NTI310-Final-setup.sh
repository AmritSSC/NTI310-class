#!/bin/bash

#install git:
git clone https://github.com/AmritSSC/NTI310-class

#1. rsyslog
#installing gcloud compute command
gcloud compute instances create rsyslog-server-a \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-east1-b \
#--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
# get meta data from appropriate script, in this case postgres_install
--metadata-from-file startup-script=NTI310-class/rsyslog_install_Mar07.sh


#2. postgres and phpPGadmin
#installing gcloud compute command
gcloud compute instances create postgres-server-a \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-east1-b \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
# get meta data from appropriate script, in this case postgres_install
--metadata-from-file startup-script=NTI310-class/Install_postgress_phpPgAdmin_Mar14.sh

#3 ldap
gcloud compute instances create ldap-server-a \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-east1-b \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
# get meta data from appropriate script, in this case postgres_install
--metadata-from-file startup-script=NTI310-class/ldap-auto-users_14Mar.sh
      

#4 #nfs
gcloud compute instances create nfs-server-a \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-east1-b \
#--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
# get meta data from appropriate script, in this case postgres_install
--metadata-from-file startup-script=NTI310-class/nsf-a.sh
      
#5 django
gcloud compute instances create django-postgres-servera \
--image-family centos-7 \
--image-project centos-cloud \
--zone us-east1-b \
--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
# get meta data from appropriate script, in this case postgres_install
--metadata-from-file startup-script=NTI310-class/django-postgres_Mar07.sh
      

#6 ubuntu client - 1 
gcloud compute instances create nsf-ubuntu-client-server-a-1 \
--image-family ubuntu-1804-lts \
--image-project ubuntu-os-cloud \
--zone us-east1-b \
#--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
# get meta data from appropriate script, in this case postgres_install
--metadata-from-file startup-script=NTI310-class/nsf_plus_ubuntu_client_Mar14.sh
      

#7 ubuntu client- 2
gcloud compute instances create nsf-ubuntu-client-server-a-2 \
--image-family ubuntu-1804-lts \
--image-project ubuntu-os-cloud \
--zone us-east1-b \
#--tags "http-server","https-server" \
--machine-type f1-micro \
--scopes cloud-platform \
# get meta data from appropriate script, in this case postgres_install
--metadata-from-file startup-script=NTI310-class/nsf_plus_ubuntu_client_Mar14.sh
      
      
      
