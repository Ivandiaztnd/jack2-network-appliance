#!/bin/bash

bindir=/root
file01=/opt/jack2/network-dns.conf

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[Jack2 PPPoe Client (ADSL) ]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""

echo -e " \033[1;32m[add-pppoe-client]\033[0m \033[1;32m[del-pppoe-client]\033[0m"
echo -e " \033[1;32m[show-connections]\033[0m \033[1;32m[printfile-pppoe-client]\033[0m"
echo -e " \033[1;32m[exit]\033[0m"

printf "\n\n";

echo -e  -n  "\033[34mjack2-pppoe-client:~#> \033[0m";


read opcion

case $opcion in



#-----------------------------------------------------------------------------------------------------------------------
exit)
cd /root
. ./Jack2-Main.sh

;;
add-pppoe-client)

clear
 echo -n  "Interface : "
 read interface

 echo -n  "User : "
 read user

 echo -n  "Password : "
 read password

 echo -n  "Add default route (Y/N) ? : "
 read defroute

 echo -n  "Use peers DNS (Y/N) ? : "
 read peerdns


file01=/opt/jack2/pppoe-client.$interface
file02=/etc/ppp/peers/adsl-$interface
file03=/etc/ppp/chap-secrets
file04=/opt/jack2/jack2-pppoe-client.conf
prefixx=$(expr $RANDOM % 255)


cat > $file01 <<EOF
lock
debug
asyncmap 0
holdoff 10
idle 10
lcp-echo-interval 2
lcp-echo-failure 7
lcp-max-configure 30
noipdefault
hide-password
noauth
persist
#mtu 1492
maxfail 0
plugin rp-pppoe.so $interface
unit 999$prefixx
user "$user"
EOF

#defaultroute
#replacedefaultroute
#usepeerdns

if [ $defroute = "Y" ]; then
 echo "defaultroute" >> $file01
fi

if [ $peerdns = "Y" ]; then
 echo "usepeerdns" >> $file01
fi



# creamos cliente adsl
cat $file01 > $file02



# configuramos password
cat $file03|grep -v $user|sed  /^$/d > /tmp/chap.tmp
cat /tmp/chap.tmp > $file03
rm -f /tmp/chap.tmp

echo "$user * $password # adsl-$interface"|awk {'print ":"$1":  "$2"  :"$3":  "$4" "$5'}|sed s/":"/'"'/g >> $file03

# seteamos el arranque del adsl
cat  $file04|grep -v adsl-$interface|sed  /^$/d > /tmp/pppoe.tmp
cat /tmp/pppoe.tmp > $file04
rm -f /tmp/chap.tmp

echo "pon adsl-$interface " >>  $file04


. pppoe-client.sh



read x ;
. ./jack2-pppoe-client.sh
;;

#-----------------------------------------------------------------------------------------------------------------------

del-pppoe-client)

sh numpppoe.sh


file01=/opt/jack2/pppoe-client.$interface
file02=/etc/ppp/peers/adsl-$interface
file03=/etc/ppp/chap-secrets
file04=/opt/jack2/jack2-pppoe-client.conf


num=""

echo -n "numero a borrar "
read num



IFAZ=$(sh  numpppoe.sh |grep "^$num|"|cut -d "|" -f2|sed s/"pon adsl-"/""/g)




#borro archivos de configuracion

rm -f /opt/jack2/pppoe-client.$IFAZ
rm -f /etc/ppp/peers/adsl-$IFAZ


# borro user y password
cat $file03 | grep -v  "# adsl-$IFAZ" > /tmp/chap.tmp
cat /tmp/chap.tmp > $file03
rm -f /tmp/chap.tmp

# borro inicion de interfaz

cat $file04 | grep -v "adsl-$IFAZ" > /tmp/jack2-pppoe.tmp
cat /tmp/jack2-pppoe.tmp > $file04
rm -f /tmp/jack2-pppoe.tmp



. pppoe-client.sh



read x;
. ./jack2-pppoe-client.sh
;;
#-----------------------------------------------------------------------------------------------------------------------

show-connections)

clear
echo -e "\033[34m[PPPoE Connections]\033[0m"
echo

ifconfig|grep "ppp999"|sed s/"encap:Point-to-Point Protocol"/""/g|sed s/"Link"/"LINK UP"/g|sed s/"ppp999"/Adsl-/g
echo


read x;
. ./jack2-pppoe-client.sh
;;
#-----------------------------------------------------------------------------------------------------------------------

printfile-pppoe-client)
clear

sh numpppoe.sh


read x;
. ./jack2-pppoe-client.sh
;;
#-----------------------------------------------------------------------------------------------------------------------




*)
echo ""
echo " Error seleccion incorrecta "

sleep 1

. ./jack2-pppoe-client.sh

;;

esac

