clear;

dir_conf=/opt/jack2

file_01=$dir_conf/jack2-pppoe-client.conf
#file_04=/etc/ppp/chap-secrets


tmp_dir=/tmp

cat $file_01 |sed /^$/d > $tmp_dir/x.pppoe
#cat $file_04|grep "# adsl" > $tmp_dir/a.pppoe  



echo -e "\033[34m[PPPoE Clients]\033[0m"
echo
cat $tmp_dir/x.pppoe |cat -n  |sed s/"pon "/"|pon "/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'
echo
echo

#echo -e "\033[34m[]\033[0m"
#cat $tmp_dir/a.pppoe|cat -n  |sed s/'"'/'|   "'/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'
#echo
#echo

#rm -f $tmp_dir/a.pppoe 
rm -f $tmp_dir/x.pppoe
