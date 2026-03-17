clear;

dir_conf=/etc/ppp

file_01=$dir_conf/chap-secrets

tmp_dir=/tmp


#cat $file_01 |grep "pptp-server-user"|sed /^$/d > $tmp_dir/x.pppoe

cat $file_01|grep ""pptp-server-user""|sed s/"^"/"USER "/g|sed /^$/d > $tmp_dir/x.pppoe

echo -e "\033[34m[PPTP USERS]\033[0m"

echo
cat -n $tmp_dir/x.pppoe |sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'|sed s/"USER"/"|"/g
#|awk {'print "|"$1"| "$2"  "$3"  "$4"  "$5" "$6"  "$7" "$8'}
echo
echo


rm -f $tmp_dir/x.pppoe
