clear;

#dir_conf=/etc/ppp
#file_01=$dir_conf/chap-secrets

main_file=/opt/jack2/jack2-pptp-client.conf
tmp_dir=/tmp



cat $main_file|sed /^$/d > $tmp_dir/x.pppoe

echo -e "\033[34m[PPTP USERS]\033[0m"

echo
cat -n $tmp_dir/x.pppoe |sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'|sed s/"pptp "/"|pptp "/g
#|awk {'print "|"$1"| "$2"  "$3"  "$4"  "$5" "$6"  "$7" "$8'}
echo
echo


rm -f $tmp_dir/x.pppoe
