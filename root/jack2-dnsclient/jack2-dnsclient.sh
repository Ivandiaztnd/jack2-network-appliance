#!/bin/bash

bindir=/root
file01=/opt/jack2/network-dns.conf

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[Jack2 DNS Client ]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""

echo -e " \033[1;32m[add-dns]\033[0m \033[1;32m[del-dns]\033[0m"
echo -e " \033[1;32m[show-dns]\033[0m "
echo -e " \033[1;32m[exit]\033[0m "


printf "\n\n";

echo -e  -n  "\033[34mjack2-dnsclient:~#> \033[0m";


read opcion

case $opcion in



#-----------------------------------------------------------------------------------------------------------------------
exit)
cd /root
. ./Jack2-Main.sh
;;
add-dns)


echo -n  "DNS Server Address: "
 read dnsip


until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo  "nameserver "$dnsip

printf "\n\n"

    echo -n "Aplicar? (S/N): ";read opcion2;

       if [ "$opcion2" = "N"  ] ; then
        . ./jack2-dnsclient.sh
       fi

done

echo  "nameserver "$dnsip >> $file01

cat  $file01 > /etc/resolv.conf 

. numdns.sh

read x;

. ./jack2-dnsclient.sh
;;

#-----------------------------------------------------------------------------------------------------------------------

show-dns)
clear


#echo -e "\033[1;32m----------[Dns Servers]------\033[0m"
#cat /etc/resolv.conf

.  numdns.sh

read x;

. ./jack2-dnsclient.sh
;;



#-----------------------------------------------------------------------------------------------------------------------

del-dns)

clear
file01=/opt/jack2/network-dns.conf
num="";

echo ""

sh numdns.sh

printf "\n\n";

echo -n  "Numero a Borrar: "
 read num;

if [ -z $num ]; then
. jack2-dnsclient.sh
fi


            sh numdns.sh |grep nameserver|grep -v "^$num|"|cut -d "|" -f2 > tmp2.net

            clear
            echo
            echo -e "\033[1;32m DNS Actuales \033[0m"
            echo
            sh numdns.sh |grep nameserver|grep -v "^$num|"
            echo
            echo
            echo -e "\033[1;31m DNS Borrado \033[0m"

            echo
            sh numdns.sh | grep "^$num|"|grep nameserver

        cat  tmp2.net > $file01

        cat $file01 > /etc/resolv.conf
        rm -f tmp2.net

#fi

read x;

. ./jack2-dnsclient.sh


;;

*)
echo "" 
echo " Error seleccion incorrecta "

sleep 1

. ./jack2-dnsclient.sh

;;

esac



