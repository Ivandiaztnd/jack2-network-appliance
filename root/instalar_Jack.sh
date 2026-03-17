#!/bin/bash

cat /dev/null > /etc/apt/sources.list


echo "deb http://ftp.fr.debian.org/debian/ etch main non-free contrib" > /etc/apt/sources.list
echo "deb-src http://ftp.fr.debian.org/debian/ etch main" >> /etc/apt/sources.list

apt-get update



apt-get install -y ssh
apt-get install -y iproute
apt-get install -y quagga
apt-get install -y ppp
apt-get install -y pptpd
apt-get install -y linux-pptp
apt-get install -y l2tpd
apt-get install -y openswan
apt-get install -y openvpn
apt-get install -y dhcp3-common
apt-get install -y dhcp3-relay
apt-get install -y dhcp3-server
apt-get install -y bind9
apt-get install -y squid3
apt-get install -y fail2ban
apt-get install -y denyhosts
apt-get install -y openntpd
apt-get install -y traceroute
apt-get install -y nmap
apt-get install -y tcpdump
apt-get install -y postfix
apt-get install -y libapache-htpasswd-perl
apt-get install -y apache2-utils
apt-get install -y snmpd
apt-get install -y pppoe
apt-get install -y freeradius

