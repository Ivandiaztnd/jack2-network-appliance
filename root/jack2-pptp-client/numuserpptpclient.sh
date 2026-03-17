clear;

dir_conf=/etc/ppp
main_file=$dir_conf/chap-secrets
tmp_dir=/tmp



cat $main_file |sed '/^$/d' > w
cat w|grep pptp-client-user|grep -v "PPTP"|sed s/"^"/"TMP"/|sed s/"TMP"/"|"/g|cat -n|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'|sed s/"|     "/""/g

rm -f w
