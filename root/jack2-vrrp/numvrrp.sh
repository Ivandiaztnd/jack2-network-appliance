#REEMPLAZO DE prueba.php HECHO EN SHELLSCRIPT Y SED



cat /opt/jack2/jack2-vrrp.conf|sed '/^$/d' > w 

echo -e "\033[34m[VRRP]\033[0m"
echo

cat w|cat -n  |sed s/"vrrpd"/"|vrrpd"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'
#cat w|grep -v DISABLED |cat -n  |sed s/"dhcpcd"/"|dhcpcd"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

#echo
#echo

#echo -e "\033[34m[ENABLED]\033[0m"
#cat w|grep "#{DISABLED}" |cat -n  |sed s/"#{"/"|#{"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

rm -f w 
echo

