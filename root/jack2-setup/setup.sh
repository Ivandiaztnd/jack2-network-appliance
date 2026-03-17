#!/bin/bash

clear

rootdirj=/opt
DIRj=/opt/jack2

mkdir $rootdirj
mkdir $DIRj



touch $DIRj/jack2-firewall.dnat
touch $DIRj/jack2-firewall.post
touch $DIRj/jack2-firewall.snat
touch $DIRj/jack2-firewall.pre
touch $DIRj/jack2-firewall.masq
touch $DIRj/jack2-firewall.conf

echo "#!/bin/bash" > $DIRj/jack2-firewall.pre
echo "" >> $DIRj/jack2-firewall.pre
echo "#--------------------------------   Forwarding de paqutes ---------------------------------">> $DIRj/jack2-firewall.pre
echo "">> $DIRj/jack2-firewall.pre
echo "echo "1" > /proc/sys/net/ipv4/ip_forward">> $DIRj/jack2-firewall.pre
echo "">> $DIRj/jack2-firewall.pre
echo #---------------------------------- Modulos de iptables ----------------------------------->> $DIR/jack2-firewall.pre
echo "">> $DIRj/jack2-firewall.pre
echo "modprobe ip_tables">> $DIRj/jack2-firewall.pre
echo "modprobe ip_conntrack">> $DIRj/jack2-firewall.pre
echo "modprobe iptable_filter">> $DIRj/jack2-firewall.pre
echo "modprobe iptable_mangle">> $DIRj/jack2-firewall.pre
echo "modprobe iptable_nat">> $DIRj/jack2-firewall.pre
echo "modprobe ipt_LOG">> $DIRj/jack2-firewall.pre
echo "modprobe ipt_limit">> $DIRj/jack2-firewall.pre
echo "modprobe ipt_MASQUERADE">> $DIRj/jack2-firewall.pre
echo "modprobe ipt_state">> $DIRj/jack2-firewall.pre
echo "">> $DIRj/jack2-firewall.pre
echo "#------------------------------- Reglas por Default ---------------------------------------">> $DIRj/jack2-firewall.pre
echo "iptables -t mangle -F">> $DIRj/jack2-firewall.pre
echo "iptables -t filter -F">> $DIRj/jack2-firewall.pre
echo "iptables -t mangle -X">> $DIRj/jack2-firewall.pre
echo "iptables -t filter -X">> $DIRj/jack2-firewall.pre
echo "">> $DIRj/jack2-firewall.pre
echo "iptables -P INPUT ACCEPT">> $DIRj/jack2-firewall.pre
echo "iptables -P OUTPUT ACCEPT">> $DIRj/jack2-firewall.pre
echo "iptables -P FORWARD ACCEPT">> $DIRj/jack2-firewall.pre
echo "iptables -t nat -P PREROUTING ACCEPT">> $DIRj/jack2-firewall.pre
echo "iptables -t nat -P POSTROUTING ACCEPT">> $DIRj/jack2-firewall.pre
echo "#------------------------------------------------------------------------------------------">> $DIRj/jack2-firewall.pre


echo "iptables -A INPUT -p tcp  -j DROP -m comment --comment ' bloquear todo '" >> $DIRj/jack2-firewall.post



touch $DIRj/network-address.conf
touch $DIRj/network-routes.conf
touch $DIRj/network-routes.pre
