cat /opt/jack2/jack2-qos.conf 2>/dev/null |sed '/^$/d'|sed '/^#/d' > w_qos

echo -e "\033[34m[QoS RULES]\033[0m"
echo
echo

echo -e "\033[34m[ENABLED]\033[0m"
cat w_qos|grep -v DISABLED |cat -n  |sed s/"tc-"/"|tc-"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

echo
echo

echo -e "\033[34m[DISABLED]\033[0m"
cat w_qos|grep DISABLED |cat -n  |sed s/"#{"/"|#{"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

rm -f w_qos
echo
