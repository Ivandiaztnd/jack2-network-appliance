
#/etc/init.d/pptpd stop
killall pptpd
rm -f /var/run/pptpd.pid

sleep 1

/etc/init.d/pptpd start


