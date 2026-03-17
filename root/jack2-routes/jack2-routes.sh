#!/bin/bash


bindir=/root/jack2-routes
file01=/opt/jack2/network-routes.conf

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[Menu de Routing Jack2]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""

echo -e " \033[1;32m[add-route]\033[0m \033[1;32m[del-route]\033[0m"
echo -e " \033[1;32m[enable-route]\033[0m \033[0m\033[1;32m[disable-route]\033[0m"
echo -e " \033[1;32m[printfile-routes]\033[0m \033[1;32m[show-routes]\033[0m \033[1;32m[show-detailed-routes]\033[0m"
echo -e " \033[1;32m[exit]\033[0m"

printf "\n\n";

echo -e  -n  "\033[34mjack2-routes:~#> \033[0m";


read opcion

case $opcion in



#-----------------------------------------------------------------------------------------------------------------------
exit)

cd /root
. ./Jack2-Main.sh

;;

add-route)

#. add-route.sh
clear
. numroutes.sh

file01=/opt/jack2/network-routes.conf


echo -e "\033[1;32m[ADD]\033[0m"

echo -n  "Destination Address(IpAddress/Preffix): "
 read dstaddress



#route_dd=$(ipcalc $ipaddress $netmask |grep Network|cut -d ":" -f2|awk {'print  $1'})


echo -n "Gateway: "
 read gateway

if [ "$gateway" != "" ] ; then
pasarela="via $gateway "
fi
echo
ifconfig| cut -d : -f1|grep "^e"|awk {'print $1'}|sort|uniq;ifconfig| cut -d : -f1|grep "^p"|awk {'print $1'}|sort|uniq
echo
 echo -n "Interface: "
  read interface

if [ "$interface" != "" ] ; then
interface="dev $interface "
fi

 echo -n "Pref. Source: "
   read psource

   if [ "$psource" != "" ] ; then
     psource="src $psource "
   fi

  echo -n "Metric: "
     read metric

        if [ "$metric" != "" ] ; then
             metric="metric $metric "
        fi


until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo  "ip route add "$dstaddress"  "$pasarela" "$interface" "$psource" "$metric

printf "\n\n"

    echo -n "Aplicar? (S/N): ";read opcion2;

       if [ "$opcion2" = "N"  ] ; then
        . ./jack2-routes.sh
#          exit 0
       fi

done

echo   "ip route add "$dstaddress" "$pasarela" "$interface" "$psource" "$metric >> $file01

. net-routes.sh

sh numroutes.sh

read x;

. jack2-routes.sh

;;


#-----------------------------------------------------------------------------------------------------------------------

printfile-routes)

#. printfile-routes.sh
echo

echo -e "\033[34m------------------------------------------------------------------------------\033[0m"
echo
cat /opt/jack2/network-routes.conf
echo
echo -e "\033[34m------------------------------------------------------------------------------\033[0m"

read x;

. jack2-routes.sh


;;

#-----------------------------------------------------------------------------------------------------------------------
enable-route)

#. enable-route.sh
#enable-address)
clear
file01=/opt/jack2/network-routes.conf
num="";

echo ""

sh numroutes.sh | grep  DISABLED

printf "\n\n";

echo -n  "Numero a habilitar: "
 read num;

if [ -z $num ]; then
 . jack2-routes.sh
fi



#IFACEIP=$( sh  numroutes.sh|grep  "#{DISABLED}"|grep "^$num|" |sed s/"ifconfig"/"ifconfig _ "/g|cut -d "_" -f2|sed s/"netmask"/"_ netmask"/g|cut -d "_" -f1|awk {'print $1'})

#echo $IFACEIP



###################
until [ "$opcion2" = "S" ] ;
do

clear

echo "Ruta a Habilitar : "
sh numroutes.sh |grep "#{DISABLED}" |sed s/"#{DISABLED} ip route"/"ip route"/g| grep "^$num|"

printf "\n\n"

    echo -n "Aplicar? (S/N): ";read opcion2;

           if [ "$opcion2" = "N"  ] ; then
#                   . ./jack2-interfaces.sh
			exit 0
                          fi

                          done


sh numroutes.sh | grep "^$num|"|grep  "#{DISABLED}"|grep "ip route" |sed s/"#{DISABLED} ip route"/"ip route"/g|cut -d "|" -f2 > tmp1.net
# selecciona la ip a deshabilitar por identificador y coambia ifconfig a #{DISABLED} y le corta el numero|#{...  a  #{..



 sh numroutes.sh |grep "ip route"| grep -v DISABLED|cut -d "|" -f2 > tmp2.net
 sh numroutes.sh |grep "ip route"| grep  "#{DISABLED}"|grep -v "^$num|"|cut -d "|" -f2 >> tmp2.net


#cat  $file01 | grep -v "^$num |" > tmp2.net

cat  tmp1.net  >> tmp2.net

cat  tmp2.net |sed '/^$/d' > tmp3.net #borrarmos las lineas en blanco

cat  tmp3.net > $file01

rm -f tmp1.net tmp2.net tmp3.net

sh net-routes.sh
sleep 2
sh numroutes.sh

read x;

. jack2-routes.sh

#;;



;;


#-----------------------------------------------------------------------------------------------------------------------

del-route)

#. del-route.sh

clear
file01=/opt/jack2/network-routes.conf
num="";

echo ""

sh numroutes.sh

printf "\n\n";

echo -n  "Numero a Borrar: "
 read num;

if [ -z $num ]; then
. jack2-routes.sh
fi

echo -n "Status del Numero (DISABLED,ENABLED): "
 read estado;

if [ -z $estado ]; then
. jack2-routes.sh
fi


    echo -n "Aplicar? (S/N): ";read opcion2;

           if [ "$opcion2" != "S"  ] ; then
#                    exit 0
                . jack2-routes.sh

           fi



#IFACEIP=$( sh  numroutes.sh|grep "^$num|" |sed s/"ip route"/"ip routes _ "/g|cut -d "_" -f2|cut -d "_" -f1|awk {'print $1'})

#echo $IFACEIP



#if [ "$estado" = "ENABLED" ] || [ "$estado" = "DISABLED" ]; then

clear
unset a b;

          if [ "$estado" = "ENABLED" ] ; then
            sh numroutes.sh |grep "ip route"|grep -v DISABLED|grep -v "^$num|"|cut -d "|" -f2 > tmp2.net
            sh numroutes.sh |grep "ip route"|grep  DISABLED|cut -d "|" -f2 >> tmp2.net

            clear
            echo
            echo -e "\033[1;32m Rutas Actuales \033[0m"
            echo
            sh numroutes.sh |grep -v DISABLED|grep -v "^$num|"
            echo
            sh numroutes.sh |grep  "DISABLED"
            echo
            echo
            echo -e "\033[1;31m Ruta Borrada \033[0m"

            echo
            sh numroutes.sh | grep "^$num|"|grep -v DISABLED|grep "ip route"

          fi

          if [ "$estado" = "DISABLED" ] ; then
            sh numroutes.sh |grep "ip route"| grep  "#{DISABLED}"|grep -v "^$num"|cut -d "|" -f2 > tmp2.net
            sh numroutes.sh |grep "ip route"| grep -v "DISABLED"|cut -d "|" -f2 >> tmp2.net

            clear
            echo
            echo -e "\033[1;32m Rutas Actuales \033[0m"
            echo
            sh numroutes.sh | grep  "DISABLED"|grep -v "^$num"
            echo
            sh numroutes.sh | grep -v "DISABLED"
            echo
            echo
            echo -e "\033[1;31m Ruta Borrada \033[0m"
            echo
            sh numroutes.sh | grep "^$num|"|grep "#{DISABLED}"|grep "ip route"

          fi

echo

        cat  tmp2.net |sed '/^$/d' > tmp3.net #borrarmos las lineas en blanco
        cat  tmp3.net > $file01
        rm -f tmp2.net tmp3.net
        sh net-routes.sh # recargamos la configuracion de red
#         sleep 2
#        sh numroutes.sh # mostramos todas las IP's

#fi

read x;

. ./jack2-routes.sh

;;


#-----------------------------------------------------------------------------------------------------------------------

show-routes)

#!/bin/bash
clear
echo
echo -e "\033[34mDestination     Gateway         Genmask         Flags   MSS Window  irtt Iface\033[0m"
route -e -v -n |grep -v Kernel|grep -v Destination;
echo
read x;


. jack2-routes.sh
#. show-routes.sh

;;


#-----------------------------------------------------------------------------------------------------------------------

show-detailed-routes)


#. show-detailed-routes.sh

clear
echo
echo -e "\033[34m[Detailed ROUTES]\033[0m"
ip route list
echo
read x;

. jack2-routes.sh

;;



#-----------------------------------------------------------------------------------------------------------------------

disable-route)


# . disable-route.sh

clear
file01=/opt/jack2/network-routes.conf
num="";

echo ""

sh numroutes.sh | grep -v DISABLED

printf "\n\n";

echo -n  "Numero a Deshabilitar: "
 read num;


#IFACEIP=$(cat $file01 |grep ^$num|sed s/"ifconfig"/"ifconfig _ "/g|cut -d "_" -f2|sed s/"netmask"/"_ netmask  "/g|cut -d "_" -f1|awk '{print $1}')


#IFACEIP=$( sh  numaddress.sh|grep -v DISABLED|grep "^$num|" |sed s/"ifconfig"/"ifconfig _ "/g|cut -d "_" -f2|sed s/"netmask"/"_ netmask"/g|cut -d "_" -f1|awk {'print $1'})

#echo $IFACEIP



###################
until [ "$opcion2" = "S" ] ;
do

clear

echo "Ruta a Deshabilitar : "
sh numroutes.sh |grep -v "DISABLED" |sed s/"ip route"/"#{DISABLED} ip route"/g| grep "^$num|"

printf "\n\n"

    echo -n "Aplicar? (S/N): ";read opcion2;

           if [ "$opcion2" != "S"  ] ; then
                   . ./jack2-routes.sh
#exit 0
                          fi

                          done


sh numroutes.sh | grep "^$num|"|grep -v DISABLED|grep "ip route" |sed s/"ip route"/"#{DISABLED} ip route"/g|cut -d "|" -f2 > tmp1.net
# selecciona la ip a deshabilitar por identificador y coambia ifconfig a #{DISABLED} y le corta el numero|#{...  a  #{..



 sh numroutes.sh |grep "ip route"| grep -v DISABLED|grep -v "^$num|"|cut -d "|" -f2 > tmp2.net
 sh numroutes.sh |grep "ip route"| grep  "#{DISABLED}"|cut -d "|" -f2 >> tmp2.net


#cat  $file01 | grep -v "^$num |" > tmp2.net

cat  tmp1.net  >> tmp2.net

cat  tmp2.net |sed '/^$/d' > tmp3.net #borrarmos las lineas en blanco

cat  tmp3.net > $file01

rm -f tmp1.net tmp2.net tmp3.net

sh net-routes.sh
sleep 2
sh numroutes.sh

read x;

. ./jack2-routes.sh
#;;

;;

#-----------------------------------------------------------------------------------------------------------------------



*)
. jack2-routes.sh

;;

esac



