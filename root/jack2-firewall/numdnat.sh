#REEMPLAZO DE prueba.php HECHO EN SHELLSCRIPT Y SED






cat /opt/jack2/jack2-firewall.dnat > q 


echo -e "\033[34m[PREROUTING]\033[0m"
#PREROUTING
cat q|grep PREROUTING |cat -n  |sed s/"iptables"/"|iptables"/#|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

echo -e "\033[34m[POSTROUTING]\033[0m"
#POSTROUTING
cat q|grep POSTROUTING |cat -n  |sed s/"iptables"/"|iptables"/#|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

echo -e "\033[34m[OUTPUT]\033[0m"
#OUTPUT
cat q|grep OUTPUT |cat -n  |sed s/"iptables"/"|iptables"/#|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'



rm -f q


