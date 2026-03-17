#!/bin/bash

bindir=/root

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[Jack2 PPTP Server (VPN) ]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""

echo -e " \033[1;32m[set-range-ip]\033[0m \033[1;32m[show-range-ip]\033[0m \033[1;32m[show-active-users]\033[0m"
echo -e " \033[1;32m[add-pptp-user]\033[0m \033[1;32m[del-pptp-user]\033[0m \033[1;32m[show-pptp-users]\033[0m"
echo -e " \033[1;32m[reload]\033[0m \033[1;32m[exit]\033[0m"
printf "\n\n";
echo -e  -n  "\033[34mjack2-pptp-server:~#> \033[0m";

read opcion
case $opcion in


#-----------------------------------------------------------------------------------------------------------------------


exit)

cd /root

. ./Jack2-Main.sh

;;

reload)

. ./pptp-server.sh
. ./jack2-pptp-server.sh



;;
set-range-ip)

file01=/etc/pptpd.conf
file02=/etc/ppp/pptpd-options
clear
echo

echo -n "Local IP Address (pptp server): "
read loc_ip

echo
echo
echo -n "IP Address Range (ex: 192.168.1.234-238,192.168.1.245 ): "
read range_ip


echo


cat > $file01 <<EOF

option /etc/ppp/pptpd-options
logwtmp
localip $loc_ip
remoteip $range_ip

EOF


cat > $file02 <<EOF
name pptpd
require-mschap-v2
#require-chap
require-mschap
#require-mppe-128
nodefaultroute
lock
nobsdcomp
EOF


. ./pptp-server.sh
. ./jack2-pptp-server.sh

;;
#-----------------------------------------------------------------------------------------------------------------------
show-range-ip)
clear
cat /etc/pptpd.conf |grep -v option| grep -v logwtmp|sed s/"localip "/"Server IpAddress   "/g|sed s/"remoteip "/"IpAddress Range    "/g

echo
read x;
. ./jack2-pptp-server.sh

;;
#-----------------------------------------------------------------------------------------------------------------------
add-pptp-user)


file_users=/etc/ppp/chap-secrets


#user03 pptpd 123 192.168.0.204      # pptp-server-user


clear
 echo -n  "User : "
 read user

 echo -n  "Password : "
 read pass

 echo -n  "IP Address Type (static, dynamic): "
 read iptype

  if [ "$iptype" != "static" ];then
         ipaddress="*"
  else
     echo -n  "IP Address: "
      read ipaddress
  fi


 echo "$user pptpd $pass $ipaddress # pptp-server-user" >> $file_users



. ./pptp-server.sh 2>&1

. ./jack2-pptp-server.sh

;;
#-----------------------------------------------------------------------------------------------------------------------
del-pptp-user)


#sh numpptpserver.sh

sh show-pptp-users.sh
file03=/etc/ppp/chap-secrets


num=""

echo -n "numero a borrar "
read num



# borro user y password
sh numpptpserver.sh |grep -v "^$num|"|grep -v PPTP|sed /^$/d|cut -d "|" -f2|sed s/"^ "//g > /tmp/chap-secrets.tmp
cat /tmp/chap-secrets.tmp > $file03
rm -f /tmp/chap-secrets.tmp


. ./pptp-server.sh 2>&1

. ./jack2-pptp-server.sh


;;
#-----------------------------------------------------------------------------------------------------------------------
show-active-users)
clear;

echo 
echo

#ps fax|grep pptpd-options|cut -d "_" -f2|grep -v grep|sed s/"plugin \/usr\/lib\/pptpd\/pptpd-logwtmp.so"/""/g|sed s/"\/usr\/sbin\/pppd"/""/g|sed s/"file \/etc\/ppp\/pptpd-options 115200"/""/g

 ip addr|grep ppp|grep inet


read x;
. ./jack2-pptp-server.sh
;;
show-pptp-users)

clear

echo

file_chapusers=/etc/ppp/chap-secrets

ID="pptp-server-user"

cat $file_chapusers|grep $ID|sed s/"^"/"USER "/g|sed s/" pptpd "/" PASSWORD "/g|awk {'print $1" "$2"  "$3" "$4"  IpAddress  "$5"  "$6" "$7" "$8'}|cat -n|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'|sed s/"USER"/"| USER "/|sed s/*/" {DYNAMIC} "/g

echo

read x;

. ./jack2-pptp-server.sh



;;
#-----------------------------------------------------------------------------------------------------------------------

*)
echo ""
echo " Error seleccion incorrecta "

sleep 1

. ./jack2-pptp-server.sh

;;

esac

