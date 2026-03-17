#!/bin/bash

bindir=/root

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[ Jack2 IPSEC (VPN) ]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""

echo -e " \033[1;32m[add-connection]\033[0m \033[1;32m[del-connection]\033[0m"
echo -e " \033[1;32m[show-connections]\033[0m \033[1;32m[show-config]\033[0m \033[1;32m[show-PSKs]\033[0m"
echo -e " \033[1;32m[reload]\033[0m \033[1;32m[exit]\033[0m"
printf "\n\n";
echo -e  -n  "\033[34mjack2-ipsec:~#> \033[0m";

read opcion
case $opcion in


#-----------------------------------------------------------------------------------------------------------------------


exit)

cd /root

. ./Jack2-Main.sh

;;

reload)

. ./ipsec.sh
. ./jack2-ipsec.sh



;;

show-config)
clear
#cat /opt/jack2/ipsec.*.conf

cat  /opt/jack2/ipsec.*.conf |sed s/"conn"/"-----  CONNECTION ------"/g|grep -v auto=ignore |grep -v " block"|grep -v private|grep -v clear|grep -v packetdefault|sed /^$/d


echo
read x;
. ./jack2-ipsec.sh

;;



add-connection)

#file01=/etc/ipsec.conf

file02=/etc/ipsec.secrets

clear
echo

echo -n "Connection Name (no spaces) : "
read conn_name

echo -n "Left IP Address (local) : "
read leftip
echo -n "Left Subnet Address (x.x.x.x/x) : "
read leftsubnet
echo -n "Left Nexthop(GW) Address (%direct,%defaultroute,x.x.x.x) : "
read leftgw

echo -n "Right IP Address (local) : "
read rightip
echo -n "Right Subnet Address (x.x.x.x/x) : "
read rightsubnet
echo -n "Right Nexthop(GW) Address (%direct,%defaultroute,x.x.x.x) : "
read rightgw

echo -n "Pre Shared Key : "
read PSK_pass


file01=/opt/jack2/ipsec.$conn_name.conf

cat > $file01 <<EOF

conn $conn_name
        left=$leftip
        leftnexthop=$leftgw
        leftsubnet=$leftsubnet
        right=$rightip
        rightnexthop=$rightgw
        rightsubnet=$rightsubnet
        type=tunnel
        authby=secret
        ike=3des-md5-modp1024
        keyingtries=%forever
        auto=start

EOF

echo $leftip' '$rightip' : PSK "'$PSK_pass'"  #'$conn_name >> $file02 


. ./ipsec.sh
. ./jack2-ipsec.sh

;;
#-----------------------------------------------------------------------------------------------------------------------
show-connections)
clear

ipsec auto  --status|grep "==="|sed s/erouted/"|"/g|cut -d "|" -f1


echo
read x;
. ./jack2-ipsec.sh

;;
#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
del-connection)

sh numipsec.sh


num=""

echo -n "numero a borrar "
read num

if [ -z $num ]; then

. ./jack2-ipsec.sh

fi


# borro user y password
sh numipsec.sh |grep -v "^$num|"|grep -v "["|grep -v "^#"|sed /^$/d|cut -d "|" -f2|sed s/"^ "//g > /tmp/ipsec.secrets

connection_name=$(sh numipsec.sh |grep "^$num|"|cut -d "#" -f2)


cat /tmp/ipsec.secrets > /etc/ipsec.secrets

rm -f /tmp/ipsec.secrets
rm -f /opt/jack2/ipsec.$connection_name.conf

. ./ipsec.sh 2>&1

. ./jack2-ipsec.sh


;;
#-----------------------------------------------------------------------------------------------------------------------
show-PSKs)
clear;

echo 
echo

 . ./numipsec.sh 


read x;
. ./jack2-ipsec.sh
;;


#-----------------------------------------------------------------------------------------------------------------------

*)
echo ""
echo " Error seleccion incorrecta "

sleep 1

. ./jack2-ipsec.sh

;;

esac

