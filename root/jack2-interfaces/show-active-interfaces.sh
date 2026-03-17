#clear 
 echo -e "\033[34m[Active INTERFACES]\033[0m"
 
ifconfig |sed s/"inet addr:"/"ADDRESS  {      "/g|sed s/"Bcast"/"     } Bcast"/g|sed s/"encap"/"Type"/g|sed s/"Link"/"INTERFACE"/g|grep -v inet6 |grep -v packets|grep -v bytes|grep -v collisions|grep -v RUNNING|sed s/"HWaddr"/""/g|sed s/"Type:"/""/g|sed s/"Mask"/"   }  Mask"/g|cut -d "}" -f1| sed s/"{"/""/g|sed s/"ADDRESS"/""/g|sed s/"INTERFACE"/""/g|sed '/^$/d'

#read x;
