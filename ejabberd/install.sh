#!/bin/bash

set -e
set -x

DAEMON=ejabberd
CERT=/etc/ejabberd/$HOSTNAME.fsinf.at.pem

# Demo is based on ejabberd 13.12. Our apt-repositories do not yet contain
# the newest package, so we install it manually.

######################
### Manual install ###
######################
# basic packages
apt-get install -y vim adduser lsb-release wget nmap

# install dependencies
apt-get install -y erlang-asn1 erlang-base erlang-crypto erlang-inets erlang-mnesia erlang-odbc erlang-public-key erlang-ssl erlang-syntax-tools erlang-xmerl openssl ucf debconf libc6 libexpat1 libgcc1 libssl1.0.0 libstdc++6 libyaml-0-2

dpkg -i /root/dpkg/ejabberd_13.12-1~afa70_amd64.deb
dpkg -i /root/dpkg/ejabberd-mod-admin-extra_20140427-1~afa70_amd64.deb
dpkg -i /root/dpkg/ejabberd-mod-muc-admin_20140427-1~afa70_amd64.deb

########################
### Install from apt ###
########################
#apt-get install -y lsb-release apt-transport-https
#echo deb http://apt.jabber.at $(lsb_release -sc) jabber > /etc/apt/sources.list.d/ejabberd.list
#apt-get update
#apt-get install fsinf-keyring
#apt-get update
#apt-get install ejabberd

# Add/Concat StartSSL class 2 certificate:
wget http://www.startssl.com/certs/sub.class2.server.ca.pem -O /etc/ssl/sub.class2.server.ca.pem
cat /etc/ssl/private/$HOSTNAME.fsinf.at.key /etc/ssl/public/$HOSTNAME.fsinf.at.pem /etc/ssl/sub.class2.server.ca.pem > $CERT
chown root:ejabberd $CERT
chmod 640 $CERT

# copy config
cp ejabberd.yml /etc/ejabberd/ejabberd.yml

# restart ejabberd
/etc/init.d/ejabberd etart

# register admin user
ejabberdctl register admin $HOSTNAME.fsinf.at nopass
