#REEMPLAZO DE prueba.php HECHO EN SHELLSCRIPT Y SED



cat /opt/jack2/network-address.conf |sed '/^$/d' > w 


echo -e "\033[34m[ADDRESS]\033[0m"
#ADDRESS
echo
echo

echo -e "\033[34m[ENABLED]\033[0m"
cat w|grep -v DISABLED |cat -n  |sed s/"ifconfig"/"|ifconfig"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

echo
echo

echo -e "\033[34m[DISABLED]\033[0m"
cat w|grep DISABLED |cat -n  |sed s/"#{"/"|#{"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

rm -f w 
echo

