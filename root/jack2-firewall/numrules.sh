#REEMPLAZO DE prueba.php HECHO EN SHELLSCRIPT Y SED


#tac /opt/jack2/jack2-firewall.conf |cat -n  |sed s/"iptables"/"|iptables"/>koko
#cat  koko|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'
#tac /opt/jack2/jack2-firewall.conf |cat -n  |sed s/"iptables"/"|iptables"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'


cat /opt/jack2/jack2-firewall.conf > f
cat /opt/jack2/jack2-firewall.post >> f


echo -e "\033[34m[INPUT]\033[0m"
#INPUT
cat f|grep INPUT |cat -n  |sed s/"iptables"/"|iptables"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

echo -e "\033[34m[FORWARD]\033[0m"
#FORWARD
cat f|grep FORWARD |cat -n  |sed s/"iptables"/"|iptables"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

echo -e "\033[34m[OUTPUT]\033[0m"
#OUTPUT
cat f|grep OUTPUT |cat -n  |sed s/"iptables"/"|iptables"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'



rm -f f

#cat /opt/jack2/jack2-firewall.conf |cat -n  |sed s/"iptables"/"|iptables"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'
#cat /opt/jack2/jack2-firewall.post |sed s/"iptables"/"|iptables"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

