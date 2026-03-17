FileGWIP=/var/log/messages;

GWIP=$(tail -n 100 $FileGWIP |grep pppd|grep "remote IP address"|cut -d ":" -f4|sed s/" remote IP address "/""/g|sort|uniq)
PPPiface=$(ip r l |grep $GWIP|sed s/"dev "/":"/g|sed s/" proto"/":"/g|cut -d ":" -f2|sed s/" "/""/g)

ip route add 0.0.0.0/0 via $GWIP dev $PPPiface

