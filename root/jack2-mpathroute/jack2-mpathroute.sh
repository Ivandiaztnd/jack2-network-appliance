#!/bin/bash

bindir=/root

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[Jack2 Multipath Routing (LB) ]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""

echo -e " \033[1;32m[add-mpath-route]\033[0m\033[1;32m[del-mpath-route]\033[0m"
echo -e " \033[1;32m[show-route-files]\033[0m\033[1;32m[show-routes-config]\033[0m\033[1;32m[show-routes]\033[0m"
echo -e " \033[1;32m[exit]\033[0m "


printf "\n\n";

echo -e  -n  "\033[34mjack2-mpathrouting:~#> \033[0m";


read opcion

case $opcion in



#-----------------------------------------------------------------------------------------------------------------------
exit)
cd /root
. ./Jack2-Main.sh
;;

add-mpath-route)
#clear

#until [ "$opcion2" = "S" ] ;
#do


echo
echo -n "Subnet: "
read subnet

if [ -z $subnet ]; then
. ./jack2-mpathroute.sh
fi

echo
echo -n  "Gateway [gw1:gwiface1,gw2:gwiface2,gw3:gwiface3...]: "
read A

if [ -z $A ]; then
. ./jack2-mpathroute.sh
fi


printf "\n\n"

#    echo -n "Aplicar? (S/N): ";read opcion2;

#       if [ "$opcion2" = "N"  ] ; then
#        . ./jack2-mpathroute.sh
#	fi

#done


file_mpath=$(echo "mpathroute-"$subnet".conf"|sed s/"\/"/"-"/g)


echo "ip route del $subnet" > $file_mpath

#if [ "$subnet"="0.0.0.0/0" ]; then
#echo "ip route del default" >> $file_mpath
#fi

a=$(echo -n "ip route add $subnet equalize scope global";echo  " \/"|sed s/"\/"/""/g); 
echo $a >> $file_mpath
echo $A"#"|sed s/^/" nexthop via "/g|sed s/":"/" dev "/g|sed s/","/"\n nexthop via "/g |sed s/"$"/"  weight 1 onlink \/"/g | sed s/"#  weight 1 onlink \/"/"  weight 1 onlink "/|sed s/"\/"/"#"/g|sed -e "s/#/\\\/g">> $file_mpath

echo "ip route flush cache"  >> $file_mpath



mv $file_mpath /opt/jack2/$file_mpath

file_mpath=/opt/jack2/$file_mpath

cat $file_mpath | sed /^$/d > $file_mpath.tmp
cat $file_mpath.tmp > $file_mpath
rm -f $file_mpath.tmp



. ./mpathroutes.sh
read x;

. ./jack2-mpathroute.sh
;;

#-----------------------------------------------------------------------------------------------------------------------


del-mpath-route)

clear
echo
. ./nummpathroute.sh

echo

num=""
echo -n "numero a borrar "
read num



FILE_DEL=$( sh nummpathroute.sh |grep "^$num|"|cut -d "|" -f2)


#borro archivos de configuracion

rm -f /opt/jack2/$FILE_DEL



. ./mpathroutes.sh


. ./jack2-mpathroute.sh



;;

#-----------------------------------------------------------------------------------------------------------------------

show-route-files)
clear
echo
echo -e "\033[34m[ROUTES FILES]\033[0m"

ls /opt/jack2/mpathroute-*.conf -l|sed s/"\/opt\/jack2\/"/"|"/g|cut -d "|" -f2
read x;

. ./jack2-mpathroute.sh


;;

#-----------------------------------------------------------------------------------------------------------------------

show-routes-config)
clear;
echo
echo -e "\033[34m[ROUTES CONFIG]\033[0m"


cat /opt/jack2/mpathroute-*.conf|grep -v "ip route del"|grep -v "ip route flush"|sed s/"ip route"/"----- ip route -----  "/g


read x;

. ./jack2-mpathroute.sh


;;

#-----------------------------------------------------------------------------------------------------------------------

show-routes)

clear
echo
echo -e "\033[34m[ACTIVE ROUTES]\033[0m"
ip route list
echo
read x;

. ./jack2-mpathroute.sh

;;


#-----------------------------------------------------------------------------------------------------------------------


*)
echo "" 
echo " Error seleccion incorrecta "

sleep 1

. ./jack2-mpathroute.sh

;;

esac



