clear;

dir_conf=/opt/jack2
file_01=$dir_conf/proxy.rules.ip
file_02=$dir_conf/proxy.rules.url
file_03=$dir_conf/proxy.control

tmp_dir=/tmp

cat $file_01 |sed /^$/d > $tmp_dir/x.proxy
cat $file_02 |sed /^$/d > $tmp_dir/y.proxy
cat $file_03 |sed /^$/d > $tmp_dir/z.proxy


echo -e "\033[34m[SRC]\033[0m"
cat $tmp_dir/x.proxy |cat -n  |sed s/"acl "/"|acl "/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'
echo
echo

echo -e "\033[34m[URL]\033[0m"
cat $tmp_dir/y.proxy |cat -n  |sed s/"acl "/"|acl "/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

echo
echo

echo -e "\033[34m[Control List]\033[0m"
cat $tmp_dir/z.proxy |cat -n  |sed s/"http_access "/"|http_access "/|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'

rm -f $tmp_dir/x.proxy $tmp_dir/y.proxy $tmp_dir/z.proxy

echo
