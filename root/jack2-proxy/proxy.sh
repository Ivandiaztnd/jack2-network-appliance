##### proxy config loader ####


CONF_dir=/opt/jack2
CONF_FILE=$CONF_dir/jack2-proxy.conf
squid_file=/etc/squid3/squid.conf

FILE1=$CONF_dir/proxy.port
FILE2=$CONF_dir/cache.size
FILE3=$CONF_dir/proxy.options
FILE4=$CONF_dir/proxy.rules.url
FILE5=$CONF_dir/proxy.rules.ip
FILE6=$CONF_dir/proxy.ip.policy
FILE7=$CONF_dir/proxy.control
FILE8=$CONF_dir/proxy.policy



cat $FILE1 $FILE2 $FILE3 $FILE4 $FILE5 $FILE6 $FILE7 $FILE8 > $CONF_FILE

cat $CONF_FILE > $squid_file



if [ -e /var/run/squid3.pid   ] ;then
        /etc/init.d/squid3 reload
else
        killall squid3
       /etc/init.d/squid3 start
fi


