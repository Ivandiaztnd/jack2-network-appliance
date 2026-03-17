file01=/opt/jack2/jack2-dhcp-client.conf 

killall dhcpcd-bin  > /tmp/errores 2>&1
sh  $file01  > /tmp/errores 2>&1



