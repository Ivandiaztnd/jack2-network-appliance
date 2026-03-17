#!/bin/bash

bindir=/root

clear

echo -e "\033[1;32m       ####                         ####           \033[0m\033[1;31m########\033[0m"
echo -e "\033[1;32m       ####                         ####         \033[0m\033[1;31m####    ###\033[0m"
echo -e "\033[1;32m       ####   ########     ######## ####    ####         \033[0m\033[1;31m####\033[0m"
echo -e "\033[1;32m       #### ####    #### ####    ## #####  ####           \033[0m\033[1;31m###\033[0m"
echo -e "\033[1;32m       ####   ########## ####       ########           \033[0m\033[1;31m####\033[0m"
echo -e "\033[1;32m####   #### ####    #### ####       ########         \033[0m\033[1;31m####\033[0m"
echo -e "\033[1;32m####   #### ####  ###### ####    ## ####  ####     \033[0m\033[1;31m####\033[0m"
echo -e "\033[1;32m  ########    ########     ######## ####    #### \033[0m\033[1;31m############\033[0m"


#cat /boot/LogoJack2.txt
echo ""								  
echo -e ".:.:.:..:..:..:..:..:..:..:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:."
echo -e "1  \033[1;32m[Interfaces]\033[0m"
echo -e "2  \033[1;32m[Routes]\033[0m"
echo -e "3  \033[1;32m[Balanced-Routes]\033[0m"
echo -e "4  \033[1;32m[Firewall]\033[0m"
echo -e "5  \033[1;32m[Proxy]\033[0m"
echo -e "6  \033[1;32m[VRRP]\033[0m"
echo -e "7  \033[1;32m[IPSEC]\033[0m"
echo -e "8  \033[1;32m[PPTP-Client]\033[0m"
echo -e "9  \033[1;32m[PPTP-Server]\033[0m"
echo -e "10 \033[1;32m[PPPoE-Client]\033[0m"
echo -e "11 \033[1;32m[DCHP-Server]\033[0m"
echo -e "12 \033[1;32m[DHCP-Client]\033[0m"
echo -e "13 \033[1;32m[DNS-Client]\033[0m"
echo -e "14 \033[1;32m[Qos]\033[0m"
echo
echo -e "15 \033[1;32m[System-Backup]\033[0m"
echo -e "16 \033[1;32m[Password]\033[0m"
echo -e "17 \033[1;32m[Reboot]\033[0m"
echo -e "18 \033[1;32m[Shutdown]\033[0m"
echo -e "19 \033[1;32m[exit]\033[0m"
printf "\n";
echo -e  -n  "\033[34mjack2-MAIN:~#> \033[0m";


#borrar despues
#exit)

#cd /root
#. ./Jack2-Main.sh

#;;
#########


 read opcion

case $opcion in



1|Interfaces)

cd $bindir/jack2-interfaces
. ./jack2-interfaces.sh

;;

2|Routes)

cd $bindir/jack2-routes
./jack2-routes.sh

;;


3|Balanced-Routes)

cd $bindir/jack2-mpathroute
./jack2-mpathroute.sh

;;


4|Firewall)

cd $bindir/jack2-firewall
. ./jack2-firewall.sh

;;

5|Proxy)

cd $bindir/jack2-proxy
. ./jack2-proxy.sh

;;
6|VRRP)

cd $bindir/jack2-vrrp
. ./jack2-vrrp.sh

;;
7|IPSEC)

cd $bindir/jack2-ipsec
. ./jack2-ipsec.sh

;;

8|PPTP-Client)

cd $bindir/jack2-pptp-client
. ./jack2-pptp-client.sh 
;;

9|PPTP-Server)

cd $bindir/jack2-pptp-server
. ./jack2-pptp-server.sh

;;

10|PPPoE-Client)
cd $bindir/jack2-pppoe-client
. ./jack2-pppoe-client.sh
;;

11|DCHP-Server)
cd $bindir/jack2-dhcp-server
. ./jack2-dhcp-server.sh

;;

14|Qos)

cd $bindir/jack2-qos
. ./jack2-qos.sh

;;

12|DHCP-Client)

cd  $bindir/jack2-dhcp-client
. ./jack2-dhcp-client.sh


;;

13|DNS-Client)

cd  $bindir/jack2-dnsclient
. ./jack2-dnsclient.sh


;;

15|System-Backup)

cd $bindir/jack2-setup
. ./jack2-setup.sh
;;

##### Comandos Peligrosos #########
17|Reboot)

clear

reboot

;;

18|Shutdown)

clear
init 0

;;

16|Password)

clear

echo

echo
passwd admin

sleep 1
. ./Jack2-Main.sh

;;
###############################
19|exit)
exit 0
;;


*)

. ./Jack2-Main.sh
;;

esac
