#!/bin/bash



for rutas_ in ` ip r l |grep -v link|awk {'print $1'}`

do 
   ip route del  $rutas_
done


touch /opt/jack2/mpathroute-1.conf



for config_files in `ls /opt/jack2/mpathroute-*`;do sh  $config_files;done

ip route flush cache

rm -f /opt/jack2/mpathroute-1.conf
