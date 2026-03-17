#!/bin/bash

bindir=/root
file01=/opt/jack2/network-dns.conf

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[Jack2 PPTP Client (VPN) ]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""

echo -e " \033[1;32m[add-pptp-client]\033[0m \033[1;32m[del-pptp-client]\033[0m"
echo -e " \033[1;32m[show-active-clients]\033[0m \033[1;32m[show-pptp-clients]\033[0m \033[1;32m[show-pptp-users]\033[0m"
echo -e " \033[1;32m[reload]\033[0m \033[1;32m[exit]\033[0m"

printf "\n\n";
echo -e  -n  "\033[34mjack2-pptp-client:~#> \033[0m";

read opcion
case $opcion in
#-----------------------------------------------------------------------------------------------------------------------

exit)
cd /root
. ./Jack2-Main.sh


;;
reload)
. ./pptp-client.sh 2>&1

. ./jack2-pptp-client.sh

;;
add-pptp-client)



file_users=/etc/ppp/chap-secrets
file_conf=/opt/jack2/jack2-pptp-client.conf

clear
echo
 echo -n "PPTP Server Address : "
 read srvaddr
echo
 echo -n  "User : "
 read user
echo
 echo -n  "Password : "
 read pass
echo

prefixx=$(expr $RANDOM % 255)

echo "$user  *  $pass  *  # pptp-client-user $prefixx" >> $file_users
echo "pptp $srvaddr remotename $srvaddr name $user noauth debug unit 777$prefixx " >> $file_conf

. ./pptp-client.sh 2>&1

. ./jack2-pptp-client.sh


;;
#-----------------------------------------------------------------------------------------------------------------------
del-pptp-client)

clear
sh numpptpclient.sh

file_main=/opt/jack2/jack2-pptp-client.conf

echo

num=""

echo -n "numero a borrar : "
read num

if [ -z $num ]; then
exit 0
fi


sh numpptpclient.sh |grep -v "PPTP USERS"|sed /^$/d|grep -v "^$num|"|cut -d "|" -f2 > /tmp/pptp.tmp
cat /tmp/pptp.tmp > $file_main
rm -f /tmp/pptp.tmp



cat /etc/ppp/chap-secrets |grep -v "pptp-client-user" > /tmp/pptpNOsecrets.tmp
sh   numuserpptpclient.sh |grep -v  "$num|"|cut -d "|" -f2 > /tmp/pptpsecrets.tmp


cat /tmp/pptpNOsecrets.tmp > /etc/ppp/chap-secrets
cat /tmp/pptpsecrets.tmp >> /etc/ppp/chap-secrets

rm -f /tmp/pptpNOsecrets.tmp /tmp/pptpsecrets.tmp

. ./pptp-client.sh 2>&1

. ./jack2-pptp-client.sh
;;
#-----------------------------------------------------------------------------------------------------------------------
show-active-clients)

clear
echo
echo
#ifconfig|grep ppp777|sed s/"Link encap:Point-to-Point Protocol"/"Running"/g|sed s/"ppp777"/"pptp-client-user "/g
ip addr|grep ppp777|grep inet|sed s/"inet"/"pptp IP"/g|sed s/"peer"/"pptp-server"/g|sed s/"scope global"/"pptp Iface"/g
echo

read x

. ./jack2-pptp-client.sh

;;
#-----------------------------------------------------------------------------------------------------------------------
show-pptp-clients)

sh numpptpclient.sh

read x

. ./jack2-pptp-client.sh

;;
#-----------------------------------------------------------------------------------------------------------------------
show-pptp-users)

clear

echo
echo
 cat /etc/ppp/chap-secrets|grep pptp-client

read x

. ./jack2-pptp-client.sh


;;
#-----------------------------------------------------------------------------------------------------------------------

*)
echo ""
echo " Error seleccion incorrecta "

sleep 1

. ./jack2-pptp-client.sh

;;

esac

