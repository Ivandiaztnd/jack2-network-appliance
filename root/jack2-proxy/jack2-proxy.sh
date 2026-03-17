#!/bin/bash


clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[Jack2 Web Proxy  ]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""

echo -e " \033[1;32m[add-proxy-rule]\033[0m\033[1;32m[del-proxy-rule]\033[0m\033[1;32m[show-proxy-rules]\033[0m"
echo -e " \033[1;32m[set-default-policy]\033[0m\033[1;32m[show-default-policy]\033[0m"
echo -e " \033[1;32m[set-proxy-port]\033[0m\033[1;32m[show-proxy-port]\033[0m"
echo -e " \033[1;32m[clear-proxy-cache]\033[0m\033[1;32m[set-cache-size]\033[0m\033[1;32m[show-cache-size]\033[0m"
echo -e " \033[1;32m[exit]\033[0m"



printf "\n\n";

echo -e  -n  "\033[34mjack2-proxy:~#> \033[0m";




function showpolicy
{

echo
echo

dir_conf=/opt/jack2
file_1=$dir_conf/proxy.policy

cat $file_1 > x.proxy

echo -e "\033[34m[POLICY]\033[0m"
cat x.proxy |sed s/"http_access "/" "/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'
echo

rm -f x.proxy
echo

 }


read opcion

case $opcion in


exit )

cd /root

. ./Jack2-Main.sh

;;

#-----------------------------------------------------------------------------------------------------------------------
set-cache-size)


dir_conf=/opt/jack2
file_22=$dir_conf/cache.size

echo
echo "Current Cache Size "
echo
size=$(cat $file_22 |awk {'print $4" Mbytes"'})
echo -e "\033[1;31m $size\033[0m"

echo

echo -n "Cache Size (Mbytes) : "
read size_d


if [ $size_d != "" ]; then

   echo "cache_dir ufs /var/spool/squid $size_d 16 256" > $file_22
fi


 if [ "$size_d" = "default" ] ; then

    echo "cache_dir ufs /var/spool/squid 100 16 256 " > $file_22


 fi


. proxy.sh
. jack2-proxy.sh




;;
#-----------------------------------------------------------------------------------------------------------------------
show-cache-size)
echo
echo

dir_conf=/opt/jack2
file_1=$dir_conf/cache.size



cat $file_1 > x.proxy

echo -e "\033[34m[Cache Size]\033[0m"
cat $file_1 |awk {'print $4" Mbytes"'}

rm -f x.proxy
echo

read x;
. jack2-proxy.sh

;;
#-----------------------------------------------------------------------------------------------------------------------

clear-proxy-cache)

killall squid3
rm -f /var/run/squid3.pid
rm -fr /var/spool/squid/*
rm -fr /var/spool/squid3/*
squid3 -z

. proxy.sh
. jack2-proxy.sh

;;


#-----------------------------------------------------------------------------------------------------------------------

add-proxy-rule)

CONF_dir=/opt/jack2
file_srcacl=$CONF_dir/proxy.rules.ip
#file_dstacl=
file_Url=$CONF_dir/proxy.rules.url
file_action=$CONF_dir/proxy.control

echo
echo -n "SRC IP acl (addr/pref. | addr/netmask) : "
read srcacl

if [ -z $srcacl ];then
 . jack2-proxy.sh
 fi

echo
#echo -n "DST IP acl (addr/pref. | addr/netmask) : "
#read dstacl

echo -n "URL/Word : "
read Url

if [ -z $Url ];then
 . jack2-proxy.sh
fi

echo

echo -n "Action (allow,deny) : "
read action

if [ -z $action ];then
 . jack2-proxy.sh
 fi


echo
echo

prefixx=$(expr $RANDOM % 2555)

echo "acl SOURCE_$prefixx src $srcacl "
#echo "acl DEST_$prefixx dst $dstacl"
echo "acl URL_$prefixx url_regex $Url"

echo
echo
#echo "http_access deny SOURCE_$prefixx DEST_$prefixx URL_$prefixx"
echo "http_access $action SOURCE_$prefixx  URL_$prefixx"



echo "acl SOURCE_$prefixx src $srcacl " >> $file_srcacl
echo "acl URL_$prefixx url_regex $Url"  >> $file_Url
echo "http_access $action SOURCE_$prefixx URL_$prefixx" >> $file_action


. proxy.sh

. jack2-proxy.sh


;;

#-----------------------------------------------------------------------------------------------------------------------
del-proxy-rule)

clear

dir_conf=/opt/jack2
file01=$dir_conf/proxy.rules.ip
file02=$dir_conf/proxy.rules.url
file03=$dir_conf/proxy.control

num="";

echo ""

sh numproxy.sh

printf "\n\n";

echo -n  "Numero a Borrar: "
 read num;

if [ -z $num ]; then
. jack2-proxy.sh
fi


# source proxy.rules.ip
 sh numproxy.sh |grep -v "^$num|"|cut -d "|" -f2|grep "SOURCE"|grep src > proxy.tmp1
# url proxy.rules.url
 sh numproxy.sh |grep -v "^$num|"|cut -d "|" -f2|grep url_regex > proxy.tmp2
#ACL proxy.control
 sh numproxy.sh |grep -v "^$num|"|cut -d "|" -f2|grep http_access > proxy.tmp3


cat proxy.tmp1 > $file01
cat proxy.tmp2 > $file02
cat proxy.tmp3 > $file03



clear

            echo -e "\033[1;31m Acl Deleted \033[0m"

            echo
            sh numproxy.sh | grep "^$num|"


        rm -f proxy.tmp1 proxy.tmp2 proxy.tmp3

        . ./proxy.sh

#fi

read x;

. ./jack2-proxy.sh

;;

#-----------------------------------------------------------------------------------------------------------------------
show-proxy-port)
echo
echo

dir_conf=/opt/jack2
file_1=$dir_conf/proxy.port



cat $file_1 > x.proxy

echo -e "\033[34m[PORT]\033[0m"
cat x.proxy |sed s/"http_port "/" "/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'
echo

rm -f x.proxy
echo

read x;
. jack2-proxy.sh
;;

#-----------------------------------------------------------------------------------------------------------------------

show-proxy-rules)
clear


.  numproxy.sh

read x;

. ./jack2-proxy.sh
;;



#-----------------------------------------------------------------------------------------------------------------------
show-default-policy)

showpolicy

read x;

. jack2-proxy.sh
;;
#-----------------------------------------------------------------------------------------------------------------------
set-default-policy)
clear

dir_conf=/opt/jack2
file_11=$dir_conf/proxy.policy


echo "Current policy "


showpolicy

echo -e "\033[1;32m ALLOW ALL \033[0m"
echo
echo -e "\033[1;31m DENY ALL \033[0m"
echo
echo

echo -n "Default policy : "
read policy



 if [ "$policy" = "ALLOW ALL" ] ; then

   echo "http_access allow all" > $file_11

 fi

 if [ "$policy" = "DENY ALL" ] ; then

    echo "http_access deny all" > $file_11

 fi


. proxy.sh
. jack2-proxy.sh


;;
#-----------------------------------------------------------------------------------------------------------------------
set-proxy-port)

dir_conf=/opt/jack2
file_22=$dir_conf/proxy.port

echo
echo "Current port "
echo
port=$(cat  $file_22|sed s/"http_port"/""/g)

echo -e "\033[1;31m $port\033[0m"

echo

echo -n "Port (num,default) : "
read port_d


if [ $port_d != "" ]; then

  echo "http_port $port_d " > $file_22

fi


 if [ "$port_d" = "default" ] ; then

    echo "http_port 3128 " > $file_22


 fi



. proxy.sh
. jack2-proxy.sh

;;
#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------


*)
echo ""
echo " Error seleccion incorrecta "

sleep 1

. ./jack2-proxy.sh

;;

esac

