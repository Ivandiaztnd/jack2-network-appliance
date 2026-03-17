#!/bin/bash

bindir=/root
file01=/opt/jack2/jack2-vrrp.conf

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[Jack2 VRRP ]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""
echo -e " \033[1;32m[add-vrrp]\033[0m\033[1;32m[del-vrrp]\033[0m"
echo -e " \033[1;32m[show-vrrp]\033[0m\033[1;32m[show-active-vrrp]\033[0m"
echo -e " \033[1;32m[exit]\033[0m"

printf "\n\n";

echo -e  -n  "\033[34mjack2-vrrp:~#> \033[0m";


read opcion

case $opcion in



#-----------------------------------------------------------------------------------------------------------------------
exit )

cd /root

. ./Jack2-Main.sh

;;

add-vrrp)


file01=/opt/jack2/jack2-vrrp.conf

echo
echo
# mostramos las interfaces reales
ifconfig|sed s/"Link encap"/"###"/g|grep "###"|cut -d "#" -f1|cut -d : -f1|grep -v ^lo|sed s/" "/""/g|sort|uniq
echo
echo

echo -n  "Interface : "
read Vinterface

echo -n  "ID : "
read Vid

echo -n  "Priority : "
read Vprio

echo -n  "Virtual IP Address : "
read Vaddr

echo -n  "Virtual Netmask : "
read Vmask

# vrrpd -i eth1:1 -v 50 -p 101 -D 10.10.0.200
#prefijoIfaz=$(expr $RANDOM % 2055)
#Vinterface=$Vinterface":"$prefijoIfaz

echo $Vinterface


detect_interface=$(ifconfig|grep $Vinterface|sed s/"Link "/"|"/g|cut -d "|" -f1|sed s/" "/""/g|grep ":"|head -n1)



 echo $detect_interface
# echo "ifconfig $Vinterface $Vaddr netmask $Vmask up;"




        until [ "$opcion2" = "S" ] ;
        do

        clear

        printf "\n\n"


        echo  "vrrpd -i $detect_interface -v $Vid -p $Vprio -D $Vaddr -n"

                printf "\n\n"

        echo -n "Aplicar? (S/N): ";read opcion2;

        if [ "$opcion2" = "N"  ] ; then
#        . ./jack2-dnsclient.sh
        exit 0
        fi

        done

echo "vrrpd -i $detect_interface -v $Vid -p $Vprio -D $Vaddr -n"  >> /opt/jack2/jack2-vrrp.conf
        . numvrrp.sh
        . vrrp.sh

        read x;

        . ./jack2-vrrp.sh



	;;
#-----------------------------------------------------------------------------------------------------------------------
del-vrrp)

clear
file01=/opt/jack2/jack2-vrrp.conf

num="";

echo ""

sh numvrrp.sh

printf "\n\n";

echo -n  "Numero a Borrar: "
 read num;

if [ -z $num ]; then
. jack2-vrrp.sh
fi


            sh numvrrp.sh |grep vrrpd|grep -v "^$num|"|cut -d "|" -f2 > tmp2.net

            clear
            echo
            echo -e "\033[1;32m VRRP  Actuales \033[0m"
            echo
            sh numvrrp.sh |grep vrrpd|grep -v "^$num|"
            echo
            echo
            echo -e "\033[1;31m VRRP  Borrado \033[0m"

            echo
            sh numvrrp.sh | grep "^$num|"|grep vrrpd

        cat  tmp2.net > $file01

#        cat $file01 > /etc/resolv.conf
        rm -f tmp2.net

#fi

. vrrp.sh

read x;

. jack2-vrrp.sh

;;



#-----------------------------------------------------------------------------------------------------------------------
show-vrrp)

echo 
sh numvrrp.sh 
echo

read x;

  . ./jack2-vrrp.sh


;;

show-active-vrrp)
echo
clear
echo
ps fax|grep vrrpd|grep -v grep|cut -d : -f2,3|sed s/"vrrpd"/"|vrrpd"/g|cut -d "|" -f2|awk {'print "[ACTIVE]  " $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$10" "$11" "$12" "$13'}|grep -v sed

echo

read x;

  . ./jack2-vrrp.sh
;;

#-----------------------------------------------------------------------------------------------------------------------
*)
echo "" 
echo " Error seleccion incorrecta "

sleep 1

. ./jack2-vrrp.sh

;;

esac



