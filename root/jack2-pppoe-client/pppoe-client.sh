file04=/opt/jack2/jack2-pppoe-client.conf

PID_ADSL=$(ps fax|grep adsl-|grep -v grep|sed s/"?"/":"/g|cut -d ":" -f1|sed s/" "/""/g)
INTERFACES=$(cat $file04 |sed s/"pon adsl-"/""/g)



for procesos in $PID_ADSL
{
kill -9 $procesos

}


for proc_network in $INTERFACES
{


ifconfig $proc_network down
ifconfig $proc_network up

}



sh $file04
