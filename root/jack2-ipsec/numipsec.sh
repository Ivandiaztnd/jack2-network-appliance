clear;

dir_conf=/etc

file_01=$dir_conf/ipsec.secrets

tmp_dir=/tmp



cat $file_01|sed /^$/d|grep -v "^#"|sed s/"^"/"USER "/g|sed /^$/d > $tmp_dir/x.ipsec

echo -e "\033[34m[ Ipsec Connections ]\033[0m"

cat -n $tmp_dir/x.ipsec |sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'|sed s/"USER"/"|"/g




rm -f $tmp_dir/x.ipsec
