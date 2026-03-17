#!/bin/bash

bindir=/root/jack2-qos
file01=/opt/jack2/jack2-qos.conf

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\\033[0m"
echo -e "    \033[34m[Jack2 QoS (Traffic Control) ]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""

echo -e " \033[1;32m[add-qos-rule]\033[0m \033[1;32m[del-qos-rule]\033[0m"
echo -e " \033[1;32m[show-qos-rules]\033[0m \033[1;32m[show-active-qos]\033[0m"
echo -e " \033[1;32m[set-default-policy]\033[0m \033[1;32m[show-default-policy]\033[0m"
echo -e " \033[1;32m[reload]\033[0m \033[1;32m[exit]\033[0m"


printf "\n\n";

echo -e  -n  "\033[34mjack2-qos:~#> \033[0m";


read opcion

case $opcion in


#-----------------------------------------------------------------------------------------------------------------------
exit)

cd /root
. ./Jack2-Main.sh

;;

reload)
. $bindir/qos.sh
. $bindir/jack2-qos.sh
;;


#-----------------------------------------------------------------------------------------------------------------------
add-qos-rule)

clear

echo -e "\033[1;32m[ADD QoS Rule]\033[0m"
echo

ifconfig -a|grep Link|awk '{print $1}'|sort
echo

echo -n "Interface: "
read qiface

if [ -z $qiface ]; then
. $bindir/jack2-qos.sh
fi

echo -n "Bandwidth total (kbps, ej: 1024): "
read bwtotal

if [ -z $bwtotal ]; then
. $bindir/jack2-qos.sh
fi

echo -n "Tipo de cola (htb,pfifo,sfq - Def. htb): "
read qtype

if [ -z $qtype ]; then
qtype="htb"
fi

echo -n "Source Address (x.x.x.x/prefix, Enter=any): "
read qsrc

if [ "$qsrc" != "" ]; then
QSRC=" match ip src $qsrc"
fi

echo -n "Destination Address (x.x.x.x/prefix, Enter=any): "
read qdst

if [ "$qdst" != "" ]; then
QDST=" match ip dst $qdst"
fi

echo -n "Protocol (tcp,udp, Enter=any): "
read qproto

if [ "$qproto" != "" ]; then
QPROTO=" match ip protocol $qproto 0xff"
fi

echo -n "Puerto Destino (Enter=any): "
read qdport

if [ "$qdport" != "" ]; then
QDPORT=" match ip dport $qdport 0xffff"
fi

echo -n "Prioridad (1=alta 3=media 5=baja, Def. 3): "
read qprio

if [ -z $qprio ]; then
qprio="3"
fi

echo -n "Rate garantizado (kbps, ej: 256): "
read qrate

if [ -z $qrate ]; then
qrate=$(echo "$bwtotal / 4" | bc)
fi

echo -n "Rate maximo (kbps, ej: $bwtotal): "
read qceil

if [ -z $qceil ]; then
qceil=$bwtotal
fi

echo -n "comentario: "
read qcomment


VARQOS="tc-$qtype $qiface bw:$bwtotal rate:$qrate ceil:$qceil prio:$qprio"

if [ "$qsrc" != "" ]; then VARQOS="$VARQOS src:$qsrc"; fi
if [ "$qdst" != "" ]; then VARQOS="$VARQOS dst:$qdst"; fi
if [ "$qproto" != "" ]; then VARQOS="$VARQOS proto:$qproto"; fi
if [ "$qdport" != "" ]; then VARQOS="$VARQOS dport:$qdport"; fi
if [ "$qcomment" != "" ]; then VARQOS="$VARQOS #$qcomment"; fi


until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo $VARQOS

printf "\n\n"

    echo -n "Aplicar? (S/N): ";read opcion2;

       if [ "$opcion2" = "N"  ] ; then
        . $bindir/jack2-qos.sh
       fi

done


echo $VARQOS >> $file01

. $bindir/qos.sh

sh $bindir/numqos.sh

read x;
. $bindir/jack2-qos.sh

;;


#-----------------------------------------------------------------------------------------------------------------------
del-qos-rule)

clear
num="";

echo ""

sh $bindir/numqos.sh

printf "\n\n";

echo -n  "Numero a Borrar: "
 read num;

if [ -z $num ]; then
. $bindir/jack2-qos.sh
fi


until [ "$opcion2" = "S" ] ;
do

clear

echo "Regla QoS a Borrar :"
sh $bindir/numqos.sh | grep "^$num|"

printf "\n\n"

    echo -n "Aplicar? (S/N): ";read opcion2;

       if [ "$opcion2" = "N"  ] ; then
        . $bindir/jack2-qos.sh
       fi

done


sh $bindir/numqos.sh | grep -v "^$num|" | cut -d "|" -f2 > tmp_qos.net
cat tmp_qos.net | sed '/^$/d' > tmp_qos2.net
cat tmp_qos2.net > $file01
rm -f tmp_qos.net tmp_qos2.net

. $bindir/qos.sh
sleep 2
sh $bindir/numqos.sh

read x;
. $bindir/jack2-qos.sh

;;


#-----------------------------------------------------------------------------------------------------------------------
show-qos-rules)

clear
echo ""
echo -e "\033[34m------------------------------------------------------------------------------\033[0m"
echo ""
sh $bindir/numqos.sh
echo ""
echo -e "\033[34m------------------------------------------------------------------------------\033[0m"

read x;
. $bindir/jack2-qos.sh

;;


#-----------------------------------------------------------------------------------------------------------------------
show-active-qos)

clear
echo ""
echo -e "\033[34m[---------- QoS Activo (tc qdisc) ----------]\033[0m"
echo ""
tc qdisc show
echo ""
echo -e "\033[34m[---------- QoS Clases (tc class) ----------]\033[0m"
echo ""
tc class show
echo ""
echo -e "\033[34m[---------- QoS Filtros (tc filter) ----------]\033[0m"
echo ""
tc filter show
echo ""
echo -e "\033[34m------------------------------------------------------------------------------\033[0m"

read x;
. $bindir/jack2-qos.sh

;;


#-----------------------------------------------------------------------------------------------------------------------
set-default-policy)

clear
echo ""
echo -e "\033[34m[Set Default QoS Policy]\033[0m"
echo ""

ifconfig -a|grep Link|awk '{print $1}'|sort
echo ""

echo -n "Interface: "
read dpol_iface

if [ -z $dpol_iface ]; then
. $bindir/jack2-qos.sh
fi

echo -n "Default bandwidth (kbps, ej: 128): "
read dpol_bw

if [ -z $dpol_bw ]; then
dpol_bw="128"
fi

DPOL="default-policy $dpol_iface bw:$dpol_bw"

until [ "$opcion2" = "S" ] ;
do

clear
printf "\n\n"
echo $DPOL
printf "\n\n"
    echo -n "Aplicar? (S/N): ";read opcion2;
       if [ "$opcion2" = "N"  ] ; then
        . $bindir/jack2-qos.sh
       fi
done

echo $DPOL > /opt/jack2/jack2-qos-default.conf

echo ""
echo -e "\033[1;32m Policy aplicada \033[0m"
sleep 2
. $bindir/jack2-qos.sh

;;


#-----------------------------------------------------------------------------------------------------------------------
show-default-policy)

clear
echo ""
echo -e "\033[34m[Default QoS Policy]\033[0m"
echo ""

if [ -f /opt/jack2/jack2-qos-default.conf ]; then
cat /opt/jack2/jack2-qos-default.conf
else
echo "Sin politica default configurada"
fi

echo ""
read x;
. $bindir/jack2-qos.sh

;;


#-----------------------------------------------------------------------------------------------------------------------

*)
echo ""
echo " Opcion Incorrecta !"

sleep 1

. $bindir/jack2-qos.sh

;;

esac
