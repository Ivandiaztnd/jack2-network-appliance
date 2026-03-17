#!/bin/bash


bindir=/root
file01=/opt/jack2/network-address.conf
file02=/opt/jack2/network-address.default 
file03=/opt/jack2/network-interfaces.conf
file_route=/opt/jack2/network-routes.pre

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[Menu de Interfaces Jack2]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""

echo -e " \033[1;32m[add-address]\033[0m \033[1;32m[del-address]\033[0m"
echo -e " \033[1;32m[enable-address]\033[0m \033[0m\033[1;32m[disable-address]\033[0m"
echo -e " \033[1;32m[enable-interface]\033[0m \033[1;32m[disable-interface]\033[0m  "
echo -e " \033[1;32m[show-disabled-address]\033[0m \033[1;32m[show-active-address]\033[0m  "
echo -e " \033[1;32m[printfile-address]\033[0m \033[1;32m[show-active-interfaces]\033[0m"
echo -e " \033[1;32m[printfile-interfaces]\033[0m"
echo -e " \033[1;32m[exit]\033[0m"

printf "\n\n";

echo -e  -n  "\033[34mjack2-interfaces:~#> \033[0m";


read opcion

case $opcion in



#-----------------------------------------------------------------------------------------------------------------------
exit)

cd /root
. ./Jack2-Main.sh


	
;;
add-address)


echo -n  "ip address: "
 read ipaddress

echo -n "netmask: "
 read netmask


ifaces=$(ifconfig -a|grep Link|awk '{print $1}'|sort);echo $ifaces

echo "";

 echo -n "interface: "
  read interface


prefixx=$(expr $RANDOM % 255)

until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo  "ifconfig "$interface:$prefixx" "$ipaddress" netmask "$netmask

printf "\n\n"

    echo -n "Aplicar? (S/N): ";read opcion2;

       if [ "$opcion2" = "N"  ] ; then
        . ./jack2-interfaces.sh
       fi

done

echo  "ifconfig "$interface:$prefixx" "$ipaddress" netmask "$netmask" up" >> $file01


# agrego la interfaz a la admin de interfaces
echo "#{ENABLED} ifconfig "$interface:$prefixx" 0 "  >> $file03

##### agrega la ruta localnet a la ip agregada##### (necesario para el modulo de jack2-routes)#########
route_dd=$(ipcalc $ipaddress $netmask |grep Network|cut -d ":" -f2|awk {'print  $1'})
echo "ip route add $route_dd dev $interface:$prefixx" >> $file_route
#######################################################################################################



sh $file01
. ./jack2-interfaces.sh
;;


#-----------------------------------------------------------------------------------------------------------------------

printfile-address)
echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";
#cat $CONFFILE
#sh numaddress.sh
sh numaddress.sh|sed s/"#{DISABLED} |"/"|{DISABLED}  "/g

echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";


read x;
. ./jack2-interfaces.sh
;;

#-----------------------------------------------------------------------------------------------------------------------

show-active-address)

clear;ifconfig |sed s/"inet addr:"/"ADDRESS  {      "/g|sed s/"Bcast"/"     } Bcast"/g|sed s/"encap"/"Type"/g|sed s/"Link"/"INTERFACE"/g|grep -v inet6 |grep -v packets|grep -v bytes|grep -v collisions|grep -v RUNNING|sed s/"HWaddr"/""/g|sed s/"Type:"/""/g|sed s/"Mask"/"   }  Mask"/g

read x;

. ./jack2-interfaces.sh
;;

show-disabled-address)
clear
echo ""
#echo -e "\033[34m[ADDRESS]\033[0m";sh numaddress.sh|grep "#{DISABLED}"
echo -e "\033[34mDisabled\033[0m";sh numaddress.sh|sed s/"#{DISABLED} |"/"|{DISABLED}  "/g|grep "DISABLED"
read x;

. ./jack2-interfaces.sh


;;


#-----------------------------------------------------------------------------------------------------------------------

printfile-address)
clear
sh numaddress.sh|sed s/"#{DISABLED} |"/"|{DISABLED}  "/g

read x;

. ./jack2-interfaces.sh
;;


#-----------------------------------------------------------------------------------------------------------------------
enable-address)
clear
file01=/opt/jack2/network-address.conf
num="";

echo ""

sh numaddress.sh | grep  DISABLED

printf "\n\n";

echo -n  "Numero a habilitar: "
 read num;

if [ -z $num ]; then
 . enable-address.sh
fi



IFACEIP=$( sh  numaddress.sh|grep  "#{DISABLED}"|grep "^$num|" |sed s/"ifconfig"/"ifconfig _ "/g|cut -d "_" -f2|sed s/"netmask"/"_ netmask"/g|cut -d "_" -f1|awk {'print $1'})

echo $IFACEIP



###################
until [ "$opcion2" = "S" ] ;
do

clear

echo "IP a Habilitar : "
sh numaddress.sh |grep "#{DISABLED}" |sed s/"#{DISABLED} ifconfig"/"ifconfig"/g| grep "^$num|"

printf "\n\n"

    echo -n "Aplicar? (S/N): ";read opcion2;

           if [ "$opcion2" = "N"  ] ; then
                   . ./jack2-interfaces.sh
                          fi

                          done


sh numaddress.sh | grep "^$num|"|grep  "#{DISABLED}"|grep ifconfig |sed s/"#{DISABLED} ifconfig"/"ifconfig"/g|cut -d "|" -f2 > tmp1.net
# selecciona la ip a deshabilitar por identificador y coambia ifconfig a #{DISABLED} y le corta el numero|#{...  a  #{..



 sh numaddress.sh |grep ifconfig| grep -v DISABLED|grep -v "^$num|"|cut -d "|" -f2 > tmp2.net
 sh numaddress.sh |grep ifconfig| grep  "#{DISABLED}"|cut -d "|" -f2 >> tmp2.net


#cat  $file01 | grep -v "^$num |" > tmp2.net

cat  tmp1.net  >> tmp2.net

cat  tmp2.net |sed '/^$/d' > tmp3.net #borrarmos las lineas en blanco

cat  tmp3.net > $file01

#rm -f tmp1.net tmp2.net tmp3.net

sh net-address.sh
sleep 2
sh numaddress.sh

read x;
. ./jack2-interfaces.sh


;;


#-----------------------------------------------------------------------------------------------------------------------

del-address)

clear
file01=/opt/jack2/network-address.conf
num="";

echo ""

sh numaddress.sh

printf "\n\n";

echo -n  "Numero a Borrar: "
 read num;

if [ -z $num ]; then
. del-address.sh
fi

echo -n "Status del Numero (DISABLED,ENABLED): "
 read estado;

if [ -z $estado ]; then
. del-address.sh
fi



IFACEIP=$( sh  numaddress.sh|grep "^$num|" |sed s/"ifconfig"/"ifconfig _ "/g|cut -d "_" -f2|sed s/"netmask"/"_ netmask"/g|cut -d "_" -f1|awk {'print $1'})

#echo $IFACEIP



#if [ "$estado" = "ENABLED" ] || [ "$estado" = "DISABLED" ]; then

unset a b;

          if [ "$estado" = "ENABLED" ] ; then
            sh numaddress.sh |grep ifconfig|grep -v DISABLED|grep -v "^$num|"|cut -d "|" -f2 > tmp2.net
            sh numaddress.sh |grep ifconfig|grep  DISABLED|cut -d "|" -f2 >> tmp2.net

            clear
            echo
            echo -e "\033[1;32m IPs Actuales \033[0m"
            echo
            sh numaddress.sh |grep -v DISABLED|grep -v "^$num|"
            echo
            sh numaddress.sh |grep  "DISABLED"
            echo
            echo
            echo -e "\033[1;31m IP Borrada \033[0m"

            echo
            sh numaddress.sh | grep "^$num|"|grep -v DISABLED|grep ifconfig

          fi

          if [ "$estado" = "DISABLED" ] ; then
            sh numaddress.sh |grep ifconfig| grep  "#{DISABLED}"|grep -v "^$num"|cut -d "|" -f2 > tmp2.net
            sh numaddress.sh |grep ifconfig| grep -v "DISABLED"|cut -d "|" -f2 >> tmp2.net

            clear
            echo
            echo -e "\033[1;32m IPs Actuales \033[0m"
            echo
            sh numaddress.sh | grep  "DISABLED"|grep -v "^$num"
            echo
            sh numaddress.sh | grep -v "DISABLED"
            echo
            echo
            echo -e "\033[1;31m IP Borrada \033[0m"
            echo
            sh numaddress.sh | grep "^$num|"|grep "#{DISABLED}"|grep ifconfig

          fi

echo

        cat  tmp2.net |sed '/^$/d' > tmp3.net #borrarmos las lineas en blanco
        cat  tmp3.net > $file01
        sh net-address.sh # recargamos la configuracion de red
         sleep 2
        sh numaddress.sh # mostramos todas las IP's

#fi

read x;

. ./jack2-interfaces.sh


;;
#-----------------------------------------------------------------------------------------------------------------------


disable-address)
file01=/opt/jack2/network-address.conf
num="";

echo ""

sh numaddress.sh | grep -v DISABLED

printf "\n\n";

echo -n  "Numero a Deshabilitar: "
 read num;


#IFACEIP=$(cat $file01 |grep ^$num|sed s/"ifconfig"/"ifconfig _ "/g|cut -d "_" -f2|sed s/"netmask"/"_ netmask  "/g|cut -d "_" -f1|awk '{print $1}')


IFACEIP=$( sh  numaddress.sh|grep -v DISABLED|grep "^$num|" |sed s/"ifconfig"/"ifconfig _ "/g|cut -d "_" -f2|sed s/"netmask"/"_ netmask"/g|cut -d "_" -f1|awk {'print $1'})

echo $IFACEIP



###################
until [ "$opcion2" = "S" ] ;
do

clear

echo "IP a Deshabilitar : "
sh numaddress.sh |grep -v "DISABLED" |sed s/"ifconfig"/"#{DISABLED} ifconfig"/g| grep "^$num|"

printf "\n\n"

    echo -n "Aplicar? (S/N): ";read opcion2;

           if [ "$opcion2" = "N"  ] ; then
                   . ./jack2-interfaces.sh
                          fi

                          done


sh numaddress.sh | grep "^$num|"|grep -v DISABLED|grep ifconfig |sed s/"ifconfig"/"#{DISABLED} ifconfig"/g|cut -d "|" -f2 > tmp1.net
# selecciona la ip a deshabilitar por identificador y coambia ifconfig a #{DISABLED} y le corta el numero|#{...  a  #{..



 sh numaddress.sh |grep ifconfig| grep -v DISABLED|grep -v "^$num|"|cut -d "|" -f2 > tmp2.net
 sh numaddress.sh |grep ifconfig| grep  "#{DISABLED}"|cut -d "|" -f2 >> tmp2.net


#cat  $file01 | grep -v "^$num |" > tmp2.net

cat  tmp1.net  >> tmp2.net

cat  tmp2.net |sed '/^$/d' > tmp3.net #borrarmos las lineas en blanco

cat  tmp3.net > $file01

rm -f tmp1.net tmp2.net tmp3.net

sh net-address.sh
sleep 2
sh numaddress.sh

read x;

. ./jack2-interfaces.sh
;;


disable-interface)

# . disable-route.sh

clear
file01=/opt/jack2/network-interfaces.conf
num="";

echo ""
echo -e "\033[34m------------------------------------------------------------------------------\033[0m"
. show-active-interfaces.sh
echo -e "\033[34m------------------------------------------------------------------------------\033[0m"
sh numinterfaces.sh | grep  ENABLED
echo -e "\033[34m------------------------------------------------------------------------------\033[0m"



#ifconfig|grep "Link encap"|awk {'print $1'}


printf "\n\n";

echo -n  "Numero a Deshabilitar: "
 read num;



###################
until [ "$opcion2" = "S" ] ;
do

clear

echo "Interface a Deshabilitar : "
sh numinterfaces.sh |grep  "ENABLED" |sed s/"#{ENABLED} ifconfig"/"ifconfig"/g| grep "^$num|"

printf "\n\n"

    echo -n "Aplicar? (S/N): ";read opcion2;

           if [ "$opcion2" != "S"  ] ; then
                  . ./jack2-interfaces.sh
#exit 0
                          fi

                          done


sh numinterfaces.sh | grep "^$num|"|grep  ENABLED|grep "ifconfig" |sed s/"#{ENABLED} ifconfig"/"ifconfig"/g|cut -d "|" -f2 > tmp1.net
# selecciona la ip a deshabilitar por identificador y coambia ifconfig a #{ENABLED}  y le corta el numero|#{...  a  #{..



 sh numinterfaces.sh |grep "ifconfig"| grep  ENABLED|grep -v "^$num|"|cut -d "|" -f2 > tmp2.net
 sh numinterfaces.sh |grep "ifconfig"| grep  -v "#{ENABLED}"|cut -d "|" -f2 >> tmp2.net


#cat  $file01 | grep -v "^$num |" > tmp2.net

cat  tmp1.net  >> tmp2.net

cat  tmp2.net |sed '/^$/d' > tmp3.net #borrarmos las lineas en blanco

cat  tmp3.net > $file01

rm -f tmp1.net tmp2.net tmp3.net

sh net-address.sh
sleep 2
sh numinterfaces.sh

read x;

. ./jack2-interfaces.sh
#;;

;;

enable-interface)
# . disable-route.sh

clear
file01=/opt/jack2/network-interfaces.conf
num="";

echo ""

#sh numinterfaces.sh |grep -v ENABLE

echo -e "\033[34m------------------------------------------------------------------------------\033[0m"
. show-active-interfaces.sh
echo -e "\033[34m------------------------------------------------------------------------------\033[0m"
sh numinterfaces.sh | grep  -v ENABLED
echo -e "\033[34m------------------------------------------------------------------------------\033[0m"


#ifconfig|grep "Link encap"|awk {'print $1'}


printf "\n\n";

echo -n  "Numero a habilitar: "
 read num;


#IFACEIP=$(cat $file01 |grep ^$num|sed s/"ifconfig"/"ifconfig _ "/g|cut -d "_" -f2|sed s/"netmask"/"_ netmask  "/g|cut -d "_" -f1|awk '{print $1}')


#IFACEIP=$( sh  numaddress.sh|grep -v DISABLED|grep "^$num|" |sed s/"ifconfig"/"ifconfig _ "/g|cut -d "_" -f2|sed s/"netmask"/"_ netmask"/g|cut -d "_" -f1|awk {'print $1'})

#echo $IFACEIP



###################
until [ "$opcion2" = "S" ] ;
do

clear

echo "Interface a habilitar : "
sh numinterfaces.sh |grep -v "ENABLED" |sed s/"ifconfig"/"#{ENABLED} ifconfig"/g| grep "^$num|"

printf "\n\n"

    echo -n "Aplicar? (S/N): ";read opcion2;

           if [ "$opcion2" != "S"  ] ; then
                   . ./jack2-interfaces.sh

                          fi

                          done


sh numinterfaces.sh | grep "^$num|"|grep -v ENABLED|grep "ifconfig" |sed s/"ifconfig"/"#{ENABLED} ifconfig"/g|cut -d "|" -f2 > tmp1.net
# selecciona la ip a deshabilitar por identificador y coambia ifconfig a #{ENABLED}  y le corta el numero|#{...  a  #{..



 sh numinterfaces.sh |grep "ifconfig"| grep -v ENABLED|grep -v "^$num|"|cut -d "|" -f2 > tmp2.net
 sh numinterfaces.sh |grep "ifconfig"| grep  "#{ENABLED}"|cut -d "|" -f2 >> tmp2.net


#cat  $file01 | grep -v "^$num |" > tmp2.net

cat  tmp1.net  >> tmp2.net

cat  tmp2.net |sed '/^$/d' > tmp3.net #borrarmos las lineas en blanco

cat  tmp3.net > $file01

rm -f tmp1.net tmp2.net tmp3.net

sh net-address.sh
sleep 2
sh numinterfaces.sh

read x;

. ./jack2-interfaces.sh
#;;

;;

show-active-interfaces)
. show-active-interfaces.sh
read x;

. ./jack2-interfaces.sh

;;
printfile-interfaces)
. numinterfaces.sh
read x;

. ./jack2-interfaces.sh

;;

*)
echo "" 
echo " Error seleccion incorrecta "

sleep 1

. ./jack2-interfaces.sh

;;

esac



