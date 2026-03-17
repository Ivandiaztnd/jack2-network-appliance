clear;

dir_conf=/opt/jack2


#ls /opt/jack2/mpathroute-*.conf -l|sed s/"\/opt\/jack2\/"/"|"/g|cut -d "|" -f2 > /tmp/data.tmp


echo -e "\033[34m[Balanced Routes Files]\033[0m"
echo
. ./show-route-files.sh |cat -n|sed s/"mpath"/"|mpath"/g|sed s/" "/""/g|sed s/"\t"//g
echo
echo


#rm -f /tmp/data.tmp
