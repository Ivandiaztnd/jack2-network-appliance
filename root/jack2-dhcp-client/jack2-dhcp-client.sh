#!/bin/bash

bindir=/root
file01=/opt/jack2/jack2-dhcp-client.conf

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[Jack2 DHCP Client ]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""
echo -e " \033[1;32m[add-dhcp-client]\033[0m  \033[1;32m[del-dhcp-client]\033[0m"
echo -e " \033[1;32m[show-dhcp-clients]\033[0m\033[1;32m[printfile-dhcp-clients]\033[0m"
echo -e " \033[1;32m[exit]\033[0m"

printf "\n\n";

echo -e  -n  "\033[34mjack2-dhcp-client:~#> \033[0m";


read opcion

case $opcion in



#-----------------------------------------------------------------------------------------------------------------------


add-dhcp-client)


file01=/opt/jack2/jack2-dhcp-client.conf


ifconfig |grep "Link encap:"|awk {'print $1'}|cut -d ":" -f1|sort|uniq|grep -v "^lo"|grep -v "^ppp"
echo
echo

echo -n  "DHCP Client Interface : "
 read dhinterface

prefixx=$(expr $RANDOM % 255)



until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo  "dhcpcd "$dhinterface":"$prefixx

printf "\n\n"

    echo -n "Aplicar? (S/N): ";read opcion2;

       if [ "$opcion2" = "N"  ] ; then
#        . ./jack2-dnsclient.sh
exit 0
       fi

done

echo "dhcpcd "$dhinterface":"$prefixx >> $file01

. dhcp-client.sh

. numdhcpc.sh


read x;

. ./jack2-dhcp-client.sh
;;

#-----------------------------------------------------------------------------------------------------------------------

show-dhcp-clients)

echo -e "\033[34m[Active DHCP Clients]\033[0m"
echo
ps ax|grep /sbin/dhcpcd-bin|grep -v  grep|sed s/"\/sbin"/"| \/sbin"/g|cut -d "|" -f2

echo

read x;

. ./jack2-dhcp-client.sh
;;



#-----------------------------------------------------------------------------------------------------------------------
printfile-dhcp-clients)
echo
. numdhcpc.sh

read x;

. ./jack2-dhcp-client.sh

;;

del-dhcp-client)

clear
file01=/opt/jack2/jack2-dhcp-client.conf

num="";

echo ""

sh numdhcpc.sh

printf "\n\n";

echo -n  "Numero a Borrar: "
 read num;

if [ -z $num ]; then
. jack2-dhcp-client.sh
fi


            sh numdhcpc.sh |grep dhcpcd|grep -v "^$num|"|cut -d "|" -f2 > tmp2.net

            clear
            echo
            echo -e "\033[1;32m DHCP Clients Actuales \033[0m"
            echo
            sh numdhcpc.sh |grep dhcpcd|grep -v "^$num|"
            echo
            echo
            echo -e "\033[1;31m DHCP Client Borrado \033[0m"

            echo
            sh numdhcpc.sh | grep "^$num|"|grep dhcpcd

        cat  tmp2.net > $file01

#        cat $file01 > /etc/resolv.conf
        rm -f tmp2.net

#fi

. dhcp-client.sh

read x;

. jack2-dhcp-client.sh

;;

exit )

cd /root

. ./Jack2-Main.sh

;;

*)
echo "" 
echo " Error seleccion incorrecta "

sleep 1

. ./jack2-dhcp-client.sh

;;

esac



