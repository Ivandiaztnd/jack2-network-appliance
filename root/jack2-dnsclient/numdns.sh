#


cat /opt/jack2/network-dns.conf |sed '/^$/d' > w 



echo -e "\033[34m[Dns Servers]\033[0m"
cat w|cat -n  |sed s/"nameserver"/"|nameserver"/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

rm -f w 
echo

