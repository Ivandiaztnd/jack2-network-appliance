#!/bin/bash

bindir=/root

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[Jack2 DHCP Server ]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""
echo -e " \033[1;32m[set-dhcp-server]\033[0m\033[1;32m[disable-dhcp-server]\033[0m"
echo -e " \033[1;32m[show-dhcp-server-config]\033[0m\033[1;32m[show-leases]\033[0m"
echo -e " \033[1;32m[reload]\033[0m"
echo -e " \033[1;32m[exit]\033[0m"

printf "\n\n";

echo -e  -n  "\033[34mjack2-dhcp-server:~#> \033[0m";


read opcion

case $opcion in



#-----------------------------------------------------------------------------------------------------------------------


set-dhcp-server)
cd /root/jack2-dhcp-server/
CONFIG_DNSMASQ=/opt/jack2/jack2-dhcp-server.conf

#listen_address=10.10.0.91
#ip_range_start=10.10.0.20
#ip_range_end=10.10.0.100
#ip_range_netmask=255.255.255.0
#ip_range_gateway=10.10.0.254
#ip_range_dns=200.69.193.1
clear
echo
echo -e "\033[34m[Set DHCP Server]\033[0m"
echo
echo -n " Listen Address: "; read listen_address
echo -n " IP Range Start: "; read ip_range_start
echo -n " IP Range End: "; read ip_range_end
echo -n " IP Range Netmask: "; read ip_range_netmask
echo -n " IP Range Router/GW: "; read ip_range_gateway
echo -n " IP Range DNS: "; read ip_range_dns

echo



#obtiene la mascara de la listen_address
NETMASK=$(ifconfig |grep $listen_address|sed s/"Mask:"/"#"/|cut -d "#" -f2|sed s/" "//g)


cat /dev/null > /opt/jack2/jack2-dhcp-server.conf

## muestra interfaces activas
##ifconfig|grep -v "eth.:"|grep Link|grep -v inet6|awk '{print $1}'|sed s/" "//g


#obtiene interfaz virtual si existe
IF=$(ip address|sed s/secondary//g|grep -v link|sed s/"global"/"|"/g|grep "|"|grep $listen_address|cut -d "|" -f2|sed s/" "//g)


INTERFACE=$(echo $IF|cut -d ":" -f1)

if [ "$IF" != "$INTERFACE" ];then
echo "ifconfig $IF down"  > $CONFIG_DNSMASQ
echo "ifconfig $IF 0" >> $CONFIG_DNSMASQ
echo "ifconfig $IF up" >> $CONFIG_DNSMASQ
fi

echo "ifconfig $INTERFACE $listen_address netmask $NETMASK up" >> $CONFIG_DNSMASQ


echo "dnsmasq -K -z -i $INTERFACE -a $listen_address -l /var/spool/dnsmasq.leases -x 9999 --dhcp-option=6,$ip_range_dns --dhcp-option=3,$ip_range_gateway --dhcp-range=$ip_range_start,$ip_range_end,$ip_range_netmask,infinite" >> $CONFIG_DNSMASQ



. ./dhcp-server.sh

read x;

. ./jack2-dhcp-server.sh
;;

#-----------------------------------------------------------------------------------------------------------------------

show-leases)
echo -e "\033[34m[ DHCP Leases]\033[0m"
echo
cat /var/spool/dnsmasq.leases
echo
read x;

. ./jack2-dhcp-server.sh
;;



show-dhcp-server-config)
clear
echo -e "\033[34m[ DHCP Server Config]\033[0m"
echo


echo
cat /opt/jack2/jack2-dhcp-server.conf|sed s/"dnsmasq"/"DHCP"/g|sed s/"--dhcp-range"/"RANGE"/g|sed s/"-l \/var\/spool\/DHCP.leases -x 9999"//g|sed s/"--dhcp-option=6,"/"DHCP_DNS="/g|sed s/"--dhcp-option=3,"/"DHCP_GATEWAY="/g|sed s/"DHCP_DNS"/"\nDHCP_DNS"/g|sed s/"DHCP_GATEWAY"/"\nDHCP_GATEWAY"/g|sed s/"RANGE"/"\nRANGE"/g|sed s/"up"/"\n"/g
echo
echo


read x;

. ./jack2-dhcp-server.sh
;;


#-----------------------------------------------------------------------------------------------------------------------

disable-dhcp-server)
clear
echo

echo -n "Aplicar Cambios (S/N)? "
read ch

if [ $ch = "S" ] ;then
cat /dev/null > /opt/jack2/jack2-dhcp-server.conf
else
. ./jack2-dhcp-server.sh
fi
. ./dhcp-server.sh


. ./jack2-dhcp-server.sh
;;

reload)
. ./dhcp-server.sh
. ./jack2-dhcp-server.sh
;;

exit )

cd /root

. ./Jack2-Main.sh

;;

*)
echo "" 
echo " Error seleccion incorrecta "

sleep 1

. ./jack2-dhcp-server.sh

;;

esac
