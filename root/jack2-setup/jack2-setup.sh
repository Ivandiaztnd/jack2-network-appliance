#!/bin/bash

bindir=/root/jack2-setup

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\\033[0m"
echo -e "    \033[34m[Jack2 System Backup / Restore ]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\\033[0m"


printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""

echo -e " \033[1;32m[backup-config]\033[0m \033[1;32m[restore-config]\033[0m"
echo -e " \033[1;32m[show-backups]\033[0m \033[1;32m[del-backup]\033[0m"
echo -e " \033[1;32m[show-system-info]\033[0m"
echo -e " \033[1;32m[exit]\033[0m"


printf "\n\n";

echo -e  -n  "\033[34mjack2-setup:~#> \033[0m";


read opcion

case $opcion in


#-----------------------------------------------------------------------------------------------------------------------
exit)

cd /root
. ./Jack2-Main.sh

;;


#-----------------------------------------------------------------------------------------------------------------------
backup-config)

clear
echo ""
echo -e "\033[1;32m[Backup de Configuracion Jack2]\033[0m"
echo ""

FECHA=$(date +%Y%m%d-%H%M%S)
BKPDIR="/opt/jack2/backups"
BKPFILE="jack2-backup-$FECHA.tar.gz"

mkdir -p $BKPDIR

echo -n "Descripcion del backup (Enter=sin descripcion): "
read bkpdesc

if [ "$bkpdesc" != "" ]; then
echo $bkpdesc > /tmp/jack2-bkp-desc.txt
fi


until [ "$opcion2" = "S" ] ;
do

clear
printf "\n\n"
echo "Backup: $BKPDIR/$BKPFILE"
echo "Incluye: /opt/jack2/*.conf /root/jack2-*/*.conf"
printf "\n\n"
    echo -n "Aplicar? (S/N): ";read opcion2;
       if [ "$opcion2" = "N"  ] ; then
        . $bindir/jack2-setup.sh
       fi
done

tar czf $BKPDIR/$BKPFILE \
    /opt/jack2/*.conf \
    /opt/jack2/*.pre \
    /opt/jack2/*.post \
    /opt/jack2/*.dnat \
    /opt/jack2/*.snat \
    /opt/jack2/*.masq \
    /etc/ppp/chap-secrets \
    /etc/ppp/pap-secrets \
    /etc/pptpd.conf \
    /etc/squid3/squid.conf \
    /etc/quagga/daemons \
    /tmp/jack2-bkp-desc.txt \
    2>/dev/null

rm -f /tmp/jack2-bkp-desc.txt

echo ""
echo -e "\033[1;32m Backup guardado: $BKPDIR/$BKPFILE \033[0m"
echo ""

ls -lh $BKPDIR/$BKPFILE

sleep 2
. $bindir/jack2-setup.sh

;;


#-----------------------------------------------------------------------------------------------------------------------
restore-config)

clear
echo ""
echo -e "\033[34m[Backups Disponibles]\033[0m"
echo ""

BKPDIR="/opt/jack2/backups"

if [ ! -d $BKPDIR ] || [ -z "$(ls $BKPDIR 2>/dev/null)" ]; then
echo "No hay backups disponibles"
echo ""
read x;
. $bindir/jack2-setup.sh
fi

ls -lh $BKPDIR/*.tar.gz 2>/dev/null | awk '{print NR"|"$5"|"$6" "$7" "$8"|"$9}'

printf "\n\n";

echo -n "Archivo a restaurar (nombre completo): "
read bkpfile

if [ -z $bkpfile ]; then
. $bindir/jack2-setup.sh
fi

if [ ! -f $BKPDIR/$bkpfile ]; then
echo ""
echo -e "\033[1;31m Archivo no encontrado \033[0m"
sleep 2
. $bindir/jack2-setup.sh
fi


until [ "$opcion2" = "S" ] ;
do

clear
printf "\n\n"
echo "Restaurar: $BKPDIR/$bkpfile"
echo -e "\033[1;31m ATENCION: se sobreescribira la configuracion actual \033[0m"
printf "\n\n"
    echo -n "Aplicar? (S/N): ";read opcion2;
       if [ "$opcion2" = "N"  ] ; then
        . $bindir/jack2-setup.sh
       fi
done

tar xzf $BKPDIR/$bkpfile -C / 2>/dev/null

echo ""
echo -e "\033[1;32m Configuracion restaurada \033[0m"
echo ""
echo "Reiniciando servicios..."
sleep 1
sh /opt/jack2/servicios.conf > /tmp/errores 2>&1
sleep 2

. $bindir/jack2-setup.sh

;;


#-----------------------------------------------------------------------------------------------------------------------
show-backups)

clear
echo ""
echo -e "\033[34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\\033[0m"

BKPDIR="/opt/jack2/backups"

if [ ! -d $BKPDIR ] || [ -z "$(ls $BKPDIR 2>/dev/null)" ]; then
echo ""
echo "No hay backups disponibles"
echo ""
else
echo ""
ls -lh $BKPDIR/*.tar.gz 2>/dev/null | awk '{print NR"| "$5" "$6" "$7" "$8" "$9}'
echo ""
fi

echo -e "\033[34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\\033[0m"
echo ""

read x;
. $bindir/jack2-setup.sh

;;


#-----------------------------------------------------------------------------------------------------------------------
del-backup)

clear
BKPDIR="/opt/jack2/backups"

echo ""
echo -e "\033[34m[Backups Disponibles]\033[0m"
echo ""

if [ ! -d $BKPDIR ] || [ -z "$(ls $BKPDIR 2>/dev/null)" ]; then
echo "No hay backups disponibles"
echo ""
read x;
. $bindir/jack2-setup.sh
fi

ls -lh $BKPDIR/*.tar.gz 2>/dev/null | awk '{print NR"| "$5" "$6" "$7" "$8" "$9}'

printf "\n\n";

echo -n "Archivo a borrar (nombre completo): "
read delbkp

if [ -z $delbkp ]; then
. $bindir/jack2-setup.sh
fi

if [ ! -f $BKPDIR/$delbkp ]; then
echo ""
echo -e "\033[1;31m Archivo no encontrado \033[0m"
sleep 2
. $bindir/jack2-setup.sh
fi


until [ "$opcion2" = "S" ] ;
do

clear
printf "\n\n"
echo "Borrar: $BKPDIR/$delbkp"
printf "\n\n"
    echo -n "Aplicar? (S/N): ";read opcion2;
       if [ "$opcion2" = "N"  ] ; then
        . $bindir/jack2-setup.sh
       fi
done

rm -f $BKPDIR/$delbkp

echo ""
echo -e "\033[1;32m Backup eliminado \033[0m"
sleep 2
. $bindir/jack2-setup.sh

;;


#-----------------------------------------------------------------------------------------------------------------------
show-system-info)

clear
echo ""
echo -e "\033[34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\\033[0m"
echo -e "    \033[34m[System Info]\033[0m"
echo -e "\033[34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\\033[0m"
echo ""
echo -e "\033[1;32m[Hostname]\033[0m"
hostname
echo ""
echo -e "\033[1;32m[Kernel]\033[0m"
uname -a
echo ""
echo -e "\033[1;32m[Uptime]\033[0m"
uptime
echo ""
echo -e "\033[1;32m[CPU]\033[0m"
cat /proc/cpuinfo | grep "model name" | head -1
echo ""
echo -e "\033[1;32m[Memoria]\033[0m"
free -m
echo ""
echo -e "\033[1;32m[Disco]\033[0m"
df -h
echo ""
echo -e "\033[1;32m[Interfaces]\033[0m"
ifconfig | grep -E "^eth|^ppp|^lo" | awk '{print $1}'
echo ""
echo -e "\033[34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\\033[0m"

read x;
. $bindir/jack2-setup.sh

;;


#-----------------------------------------------------------------------------------------------------------------------

*)
echo ""
echo " Opcion Incorrecta !"

sleep 1

. $bindir/jack2-setup.sh

;;

esac
