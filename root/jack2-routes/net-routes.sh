#ip route flush all 
#file001=/opt/jack2/network-routes.conf

# cat $file001 |grep -v '#{DISABLED}'|sed '/^$/d'|sed s/"ip route add"/"ip route del"/g > /tmp/netroutes.tmp

#sh -x /tmp/netroutes.tmp
#sh -x /opt/jack2/network-routes.pre
#sh -x /opt/jack2/network-routes.conf
#rm -f /tmp/netroutes.tmp  



file001=/opt/jack2/network-routes.conf

ip route show all|grep  via|sed s/^$a/"ip route del "/g > /tmp/netroutes.tmp


sh /tmp/netroutes.tmp
#sh  /opt/jack2/network-routes.pre
sh  /opt/jack2/network-routes.conf
rm -f /tmp/netroutes.tmp






