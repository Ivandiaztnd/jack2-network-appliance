clear

echo

file_chapusers=/etc/ppp/chap-secrets

ID="pptp-server-user"

cat $file_chapusers|grep $ID|sed s/"^"/"USER "/g|sed s/" pptpd "/" PASSWORD "/g|awk {'print $1" "$2"  "$3" "$4"  IpAddress  "$5"  "$6" "$7" "$8'}|cat -n|sed 's/^[ \t]*//;s/[ \t]*$//'|sed 's/[\t]//g'|sed s/"USER"/"| USER "/|sed s/*/" {DYNAMIC} "/g 

echo


