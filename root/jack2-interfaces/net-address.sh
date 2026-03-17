#!/bin/bash

vinterfaces=$(ifconfig| sed s/"Link"/"_"/g|grep eth|cut -d "_" -f1|grep ":")
rinterfaces=$(ifconfig| sed s/"Link"/"_"/g|grep eth|cut -d "_" -f1|grep -v ":")

echo $vinterfaces  #VIRTUALES
echo $rinterfaces  #REALES

for redes in $vinterfaces
 do
  ifconfig $redes down
 done


for redes2 in $rinterfaces
 do 
   ifconfig $redes2 down
   ifconfig $redes2 0
 done

sleep 1

 for redes3 in $rinterfaces
  do
     ifconfig $redes3 up
      done

sh  /opt/jack2/network-address.conf   > /tmp/errores 2>&1
sh  /opt/jack2/network-interfaces.conf  > /tmp/errores 2>&1
