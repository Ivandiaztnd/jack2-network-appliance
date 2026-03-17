bindir=/root/jack2-firewall

clear

printf "\n"
printf  " REGLAS \n\n";

sh numrules.sh   # Vuelca todas las reglas

printf "\n";


echo -n "Numero Regla a Borrar: "

read num; #

echo -n "Sector INPUT,OUTPUT,FORWARD: "

read sector;   #



REGLA=`sh numrules.sh | grep -v "\["|grep $sector |grep "^$num|"|cut -d '|' -f2`;


#sh numrules.sh | grep -v "\["|grep -v "iptables -A INPUT -i eth0 -j ACCEPT -m state --state ESTABLISHED"|cut -d '|' -f2

opcion2="";


until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo "Demas reglas:"

sh numrules.sh|grep -v "^$num|$REGLA" # Vuelca todas las reglas menos la que tiene $num

printf "\n\n"

echo "Regla A Borrar:"
echo $REGLA;

printf "\n\n"


printf "\n\n"
        echo $VARFILTER2;
        printf "\n\n"

        echo -n "Aplicar? (S/N): ";read opcion2;

        if [ "$opcion2" = "N"  ] ; then
#        exit
           . $bindir/jack2-firewall.sh
         fi

         done


 sh numrules.sh | grep -v "\["|grep -v "^$num|$REGLA"|cut -d '|' -f2 > rules.tmp # borra la REGLA


clear

cat rules.tmp  > /opt/jack2/jack2-firewall.conf

rm -f rules.tmp


sh  /opt/jack2/jack2-firewall.pre
sh  /opt/jack2/jack2-firewall.conf
sh /opt/jack2/jack2-firewall.post


clear

echo "REGLAS FINALES"

sh numrules.sh   # Vuelca todas las reglas


read x;

 . $bindir/jack2-firewall.sh


