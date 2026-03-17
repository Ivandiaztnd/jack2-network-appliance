#!/bin/bash

# Aplica reglas QoS desde /opt/jack2/jack2-qos.conf

file01=/opt/jack2/jack2-qos.conf

if [ ! -f $file01 ]; then
exit 0
fi

# Limpia qdiscs existentes
for iface in $(ifconfig|grep "Link encap"|awk '{print $1}'|cut -d: -f1|grep -v lo); do
tc qdisc del dev $iface root 2>/dev/null
done

# Procesa cada regla
cat $file01 | grep -v "^#" | grep -v "^$" | while read linea; do

qiface=$(echo $linea | awk '{print $2}')
bwtotal=$(echo $linea | grep -o 'bw:[0-9]*' | cut -d: -f2)
qrate=$(echo $linea | grep -o 'rate:[0-9]*' | cut -d: -f2)
qceil=$(echo $linea | grep -o 'ceil:[0-9]*' | cut -d: -f2)
qprio=$(echo $linea | grep -o 'prio:[0-9]*' | cut -d: -f2)
qsrc=$(echo $linea | grep -o 'src:[^ ]*' | cut -d: -f2)
qdst=$(echo $linea | grep -o 'dst:[^ ]*' | cut -d: -f2)
qproto=$(echo $linea | grep -o 'proto:[^ ]*' | cut -d: -f2)
qdport=$(echo $linea | grep -o 'dport:[^ ]*' | cut -d: -f2)

# HTB root qdisc
tc qdisc add dev $qiface root handle 1: htb default 99 2>/dev/null

# Clase root
tc class add dev $qiface parent 1: classid 1:1 htb rate ${bwtotal}kbit 2>/dev/null

# Clase garantizada
handle_id=$(echo $RANDOM % 99 + 1 | bc)
tc class add dev $qiface parent 1:1 classid 1:${handle_id} htb rate ${qrate}kbit ceil ${qceil}kbit prio $qprio 2>/dev/null

# Filtros
FILTER="tc filter add dev $qiface parent 1: protocol ip prio $qprio u32"
if [ "$qsrc" != "" ]; then FILTER="$FILTER match ip src $qsrc"; fi
if [ "$qdst" != "" ]; then FILTER="$FILTER match ip dst $qdst"; fi
if [ "$qdport" != "" ]; then FILTER="$FILTER match ip dport $qdport 0xffff"; fi
FILTER="$FILTER flowid 1:${handle_id}"
eval $FILTER 2>/dev/null

done
