#REEMPLAZO DE prueba.php HECHO EN SHELLSCRIPT Y SED



cat /opt/jack2/network-interfaces.conf |sed '/^$/d' > w 


echo -e "\033[34m[INTERFACES]\033[0m"
#ADDRESS
echo
echo

echo -e "\033[34m[DISABLED Interfaces]\033[0m"
cat w|grep -v ENABLED |cat -n  |sed s/"ifconfig"/"|ifconfig"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

echo
echo

echo -e "\033[34m[ENABLED Interfaces]\033[0m"
cat w|grep ENABLED |cat -n  |sed s/"#{"/"|#{"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

rm -f w 
echo

