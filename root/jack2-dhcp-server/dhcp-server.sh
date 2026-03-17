#!/bin/bash
killall dnsmasq > /tmp/errores 2>&1

PID_DHCP=$(pidof dnsmasq)

kill -9 $PID_DHCP > /tmp/errores 2>&1

sleep 1
sh /opt/jack2/jack2-dhcp-server.conf
