#!/bin/bash

set -e
set -x

DAEMON=prosody

# basic packages:
apt-get install -y lsb-release wget vim nmap adduser

# Add apt-repository (https://prosody.im/download/package_repository):
echo deb http://packages.prosody.im/debian $(lsb_release -sc) main | tee /etc/apt/sources.list.d/prosody.list
wget --no-check-certificate https://prosody.im/files/prosody-debian-packages.key -O- | apt-key add -
apt-get update

# install prosody
apt-get install -y prosody liblua5.1-expat0 lua-sec-prosody

# copy configuration:
cp /root/prosody.cfg.lua /etc/prosody/

# register admin user:
prosodyctl register admin atlas.fsinf.at nopass

# ensure good permissions
addgroup --system --quiet ssl
addgroup --system --quiet ssl-$HOSTNAME-fsinf-at
chown root:ssl /etc/ssl/private
chmod g+rx /etc/ssl/private
chown root:ssl-$HOSTNAME-fsinf-at /etc/ssl/private/$HOSTNAME.fsinf.at.key
chmod 640 /etc/ssl/private/$HOSTNAME.fsinf.at.key

# add system groups to daemon user:
adduser $DAEMON ssl
adduser $DAEMON ssl-$HOSTNAME-fsinf-at

# Add/Concat StartSSL class 2 certificate:
wget http://www.startssl.com/certs/sub.class2.server.ca.pem -O /etc/ssl/sub.class2.server.ca.pem
cat /etc/ssl/public/$HOSTNAME.fsinf.at.pem /etc/ssl/sub.class2.server.ca.pem > /etc/prosody/certs/atlas.fsinf.at.crt

# check configuration
luac -p /etc/prosody/prosody.cfg.lua

# start prosody:
/etc/init.d/prosody restart
