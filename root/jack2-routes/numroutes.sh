
cat /opt/jack2/network-routes.conf |sed '/^$/d' > w 


echo -e "\033[34m[ROUTES]\033[0m"
#ADDRESS
echo
echo

echo -e "\033[34m[ENABLED]\033[0m"
cat w|grep -v DISABLED |cat -n  |sed s/"ip route"/"|ip route"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

echo
echo

echo -e "\033[34m[DISABLED]\033[0m"
cat w|grep DISABLED |cat -n  |sed s/"#{"/"|#{"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

rm -f w 

echo
