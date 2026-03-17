#!/bin/bash



iptables -t nat -F
iptables -t nat -X

echo "1" > /proc/sys/net/ipv4/ip_forward


# Masquerading para la subred 10.10.11.0/24
#iptables -t nat -A POSTROUTING -s 10.10.11.0/24 -d 0.0.0.0/0  -j MASQUERADE



# src-nat para el host 10.10.11.110
#iptables -t nat -A POSTROUTING -o WAN -j SNAT --to 10.10.0.90 -s 10.10.11.110/32


# src-nat para la subred 10.10.11.0/24

#iptables -t nat -A POSTROUTING -o WAN -j SNAT --to 10.10.0.90 -s 10.10.11.0/24


# dst-nat desde afuera al rdesktop de la windows 10.10.11.110

#iptables -t nat -A PREROUTING -p tcp --dport 3389 -i WAN -j DNAT --to 10.10.11.110:3389 -s 0.0.0.0/0 -d 10.10.0.90
#iptables -t nat -A PREROUTING -p tcp --dport 3389 -i WAN -j DNAT --to 10.10.11.141:3389 -s 0.0.0.0/0 -d 10.10.0.90


sh  /opt/jack2/jack2-firewall.dnat
sh  /opt/jack2/jack2-firewall.snat
sh  /opt/jack2/jack2-firewall.masq



