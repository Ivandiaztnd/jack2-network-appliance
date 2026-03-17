#!/bin/bash

#------------------------------------------------------------------------------------------------------------------------

CONFFILE=/opt/jack2/jack2-firewall.conf
bindir=/root/jack2-firewall

clear

printf "\n";

echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"
echo -e "    \033[34m[Menu de Firewall Jack2]\033[0m"
echo -e "\033[1;34m[.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:]\033[0m"

printf "\n\n";
echo -e "Opciones :                                                         "
echo -e ""
echo -e " \033[1;32m[add-rule]\033[0m\033[1;32m[edit-rules]\033[0m\033[1;32m[del-rule]\033[0m\033[1;32m[printfile-rules]\033[0m\033[1;32m[print-active-rules]\033[0m "
echo -e " \033[1;32m[add-snat]\033[0m\033[1;32m[edit-dnat] \033[0m\033[1;32m[del-snat]\033[0m\033[1;32m[printfile-snat]\033[0m \033[1;32m[print-active-nat]\033[0m "
echo -e " \033[1;32m[add-dnat]\033[0m\033[1;32m[edit-snat] \033[0m\033[1;32m[del-dnat]\033[0m\033[1;32m[printfile-dnat]\033[0m \033[1;32m[print-active-mangle]\033[0m "
echo -e " \033[1;32m[add-masq]\033[0m\033[1;32m[edit-masq] \033[0m\033[1;32m[del-masq]\033[0m\033[1;32m[printfile-masq]\033[0m "
echo -e " add-mangle edit-mangle del-mangle printfile-mangle"
echo -e " \033[1;32m[show-connections]\033[0m\033[1;32m[show-all-rules]\033[0m\033[1;32m[show-protocols]\033[0m"
echo -e " \033[1;32m[reload]\033[0m\033\033[1;32m[exit]\033[0m";
printf "\n\n";

echo -e  -n  "\033[34mjack2-firewall:~#> \033[0m";

read opcion;

printf "\n\n";


case $opcion in  

# Menu de Source Nat

#    a="iptables -A";b=" INPUT";c=$a$b;echo $c

#----------------------------------------------------------------------------------------------------------------------

reload)
. $bindir/fw.sh
. $bindir/jack2-firewall.sh
;;

add-rule)


SRCPORT="";
DSTPORT="";

VARFILTER="iptables";


echo -n "Ubicacion de Regla: (ABAJO, Def. ARRIBA ) de todo: "; read ubicacion;

if [ "$ubicacion" != "" ] ; then

if [ "$ubicacion" = "ABAJO" ] ||  [ "$ubicacion" = "abajo" ] ; then
UBICACION=" -A "
fi

if [ "$ubicacion" = "ARRIBA" ] || [ "$ubicacion" = "arriba" ] ; then
 UBICACION=" -I "
fi

else
UBICACION=" -I "


fi

        echo -n "Type (INPUT,OUTPUT,FORWARD): "; read trule;


   if [ "$trule" = "INPUT" ] || [ "$trule" = "OUTPUT" ] || [ "$trule" = "FORWARD" ] ; then

        VARFILTER=$VARFILTER$UBICACION" "$trule;
         echo -n "Protocol: "; read protocol;

	    

           if [ $protocol = "tcp" ] || [ $protocol = "udp" ] ; then
            echo -n "Source Port: "; read srcport;
            echo -n "Destination Port: "; read dstport;

             if [ "$srcport" != ""  ]  ; then # comprueba que sea diferente de nada
                SRCPORT="    --sport "$srcport
             fi

             if [ "$dstport" != "" ]  ; then # comprueba que sea diferente de nada
               DSTPORT=" --dport "$dstport
             fi
         fi
        
	if [ -z $protocol ];then
	  protocol=""
	 else
	   protocol=" -p $protocol "
	fi   

        VARFILTER=$VARFILTER$protocol$SRCPORT$DSTPORT
        
	echo -n "Source Address (x.x.x.x/prefix): "; read srcaddress;
		 if [ "$srcaddress" != "" ]  ; then # comprueba que sea diferente de nada
        	        SRCADDRESS=" -s "$srcaddress
	         fi
	echo -n "Destination Address(x.x.x.x/prefix): "; read dstaddress;
	         if [ "$dstaddress" != "" ]  ; then # comprueba que sea diferente de nada
	                DSTADDRESS=" -d "$dstaddress
	   	 fi

        echo
								# Muestra las interfaces de red
	 interfaces=$(ifconfig -a|grep Link|awk '{print $1}'|sort)
	 echo $interfaces;

        echo
	echo
	if [ "$trule" = "INPUT" ] || [ "$trule" = "FORWARD" ]  ; then

	echo -n "IN interface (ethX,pppX,etc): ";read Iinterface;
	   if [ "$Iinterface" != "" ]  ; then # comprueba que sea diferente de nada
                   IINTERFACE=" -i "$Iinterface
           fi
	fi
	if [ "$trule" = "OUTPUT" ] || [ "$trule" = "FORWARD" ]  ; then

	echo -n "OUT interface (ethX,pppX,etc):";read Ointerface;
	   if [ "$Ointerface" != "" ]  ; then # comprueba que sea diferente de nada
                   OINTERFACE=" -o "$Ointerface
	   fi
	fi   
	echo
	echo -n "Action(ACCEPT,REJECT,DROP): "; read action;
	   if [ "$action" = "ACCEPT" ] || [ "$action" = "REJECT" ] || [ "$action" = "DROP" ] ; then
                   ACTION=" -j "$action
	   fi
	   if [ -z $action ];then
              ACTION=" -j ACCEPT"
	   fi

 echo -n "State(NEW,ESTABLISHED,INVALID,RELATED): "; read state;
   if [ "$state" = "NEW" ] || [ "$state" = "ESTABLISHED" ] || [ "$state" = "INVALID" ] || [ "$state" = "RELATED" ]  ; then
           STATE=" -m state --state "$state
   fi

   if [ -z $state ];then
   STATE=" -m state --state NEW,ESTABLISHED,INVALID,RELATED"
   fi


	echo -n "comentario: "; read comment;
	if [ "$comment" != "" ]  ; then # comprueba que sea diferente de nada
               COMMENT=" -m comment --comment ' "$comment" '" 
	fi

	echo

VARFILTER=$VARFILTER$SRCADDRESS$DSTADDRESS$IINTERFACE$OINTERFACE$ACTION$STATE$COMMENT



opcion="";

until [ "$opcion" = "S" ] ;
do
clear

printf "\n\n"
	echo $VARFILTER;
printf "\n\n"

echo -n "Aplicar? (S/N): ";read opcion;

if [ "$opcion" = "N"  ] ; then
  
  . $bindir/jack2-firewall.sh
fi 

done



echo $VARFILTER > /tmp/.firewall.rule
cat /tmp/.firewall.rule >> /opt/jack2/jack2-firewall.conf
sh $bindir/fw.sh
rm -f /tmp/.firewall.rule



   else
    echo "Valor Incorrecto!"
    sleep 1     
  fi


    . $bindir/jack2-firewall.sh

#------------------------------------------------------------------------------------------------------------------    
;;

# Menu de Masquerading

add-masq)
VARFILTER2="iptables -t nat"

echo -n "Ubicacion de Regla: (ABAJO, Def. ARRIBA) de todo: "; read ubicacion2;

if [ "$ubicacion2" != "" ] ; then
        if [ "$ubicacion2" = "ABAJO" ] ||  [ "$ubicacion2" = "abajo" ] ; then
         UBICACION2=" -A POSTROUTING "
        fi
        if [ "$ubicacion2" = "ARRIBA" ] || [ "$ubicacion2" = "arriba" ] ; then
         UBICACION2=" -I POSTROUTING "
         fi
 else

 UBICACION2=" -I POSTROUTING"
 
 fi

 echo -n "Source Address (x.x.x.x/prefix): "; read srcaddress2;
      if [ "$srcaddress2" != "" ]  ; then # comprueba que sea diferente de nada
               SRCADDRESS2=" -s "$srcaddress2
      fi

 echo -n "Destination Address(x.x.x.x/prefix): "; read dstaddress2;
      if [ "$dstaddress2" != "" ]  ; then # comprueba que sea diferente de nada
               DSTADDRESS2=" -d "$dstaddress2
      fi
   echo
  interfaces2=$(ifconfig -a|grep Link|awk '{print $1}'|sort)
     echo $interfaces2;
     echo

    echo -n "OUT interface (ethX,pppX,etc):";read Ointerface2;
       if [ "$Ointerface2" != "" ]  ; then # comprueba que sea diferente de nada
             OINTERFACE2=" -o "$Ointerface2
       fi
 echo -n "comentario: "; read comment2;
           if [ "$comment2" != "" ]  ; then # comprueba que sea diferente de nada
                    COMMENT2=" -m comment --comment ' "$comment2" '"
            fi
    echo

VARFILTER2=$VARFILTER2$UBICACION2$SRCADDRESS2$DSTADDRESS2$OINTERFACE2$COMMENT2" -j MASQUERADE"


opcion2="";

until [ "$opcion2" = "S" ] ;
do
clear

printf "\n\n"
        echo $VARFILTER2;
	printf "\n\n"

	echo -n "Aplicar? (S/N): ";read opcion2;

	if [ "$opcion2" = "N"  ] ; then
	 
            . $bindir/jack2-firewall.sh 
    
    
    
	 fi

	 done



echo $VARFILTER2 > /tmp/.firewall.masq
cat /tmp/.firewall.masq >> /opt/jack2/jack2-firewall.masq
sh /tmp/.firewall.masq
rm -f /tmp/.firewall.masq





   . $bindir/jack2-firewall.sh

#----------------------------------------------------------------------------------------------------------------------

;;

# Menu de source-nat
add-snat)

VARFILTER2="iptables -t nat"

echo -n "Ubicacion de Regla: (ABAJO, Def. ARRIBA) de todo: "; read ubicacion2;

if [ "$ubicacion2" != "" ] ; then
        if [ "$ubicacion2" = "ABAJO" ] ||  [ "$ubicacion2" = "abajo" ] ; then
         UBICACION2=" -A POSTROUTING "
        fi
        if [ "$ubicacion2" = "ARRIBA" ] || [ "$ubicacion2" = "arriba" ] ; then
         UBICACION2=" -I POSTROUTING "
         fi
 else

 UBICACION2=" -I POSTROUTING "

 fi

 echo -n "Source Address (x.x.x.x/prefix): "; read srcaddress2;
      if [ "$srcaddress2" != "" ]  ; then # comprueba que sea diferente de nada
               SRCADDRESS2=" -s "$srcaddress2
      fi

 echo -n "Destination Address(x.x.x.x/prefix): "; read dstaddress2;
      if [ "$dstaddress2" != "" ]  ; then # comprueba que sea diferente de nada
               DSTADDRESS2=" -d "$dstaddress2
      fi
   echo
  interfaces2=$(ifconfig -a|grep Link|awk '{print $1}'|sort)
     echo $interfaces2;
     echo



    echo -n "OUT interface (ethX,pppX,etc):";read Ointerface2;
       if [ "$Ointerface2" != "" ]  ; then # comprueba que sea diferente de nada
             OINTERFACE2=" -o "$Ointerface2
       fi

    echo -n "Source Address: ";read srcip;
         if [ "$srcip" != "" ]  ; then # comprueba que sea diferente de nada
             SRCIP=" --to "$srcip
         fi




 echo -n "comentario: "; read comment2;
           if [ "$comment2" != "" ]  ; then # comprueba que sea diferente de nada
                    COMMENT2=" -m comment --comment ' "$comment2" '"
            fi


VARFILTER2=$VARFILTER2$UBICACION2$SRCADDRESS2$DSTADDRESS2$OINTERFACE2" -j SNAT "$SRCIP$COMMENT2 


opcion2="";

until [ "$opcion2" = "S" ] ;
do
clear

printf "\n\n"
        echo $VARFILTER2;
        printf "\n\n"

        echo -n "Aplicar? (S/N): ";read opcion2;

        if [ "$opcion2" = "N"  ] ; then
         	   . $bindir/jack2-firewall.sh
         fi

         done




echo $VARFILTER2 > /tmp/.firewall.snat
cat /tmp/.firewall.snat >> /opt/jack2/jack2-firewall.snat
sh /tmp/.firewall.snat
rm -f /tmp/.firewall.snat


   . $bindir/jack2-firewall.sh

#--------------------------------------------------------------------------------------------------------------------
;;

#menu de Destination-nat
add-dnat)

VARFILTER2="iptables -t nat"

echo -n "Ubicacion de Regla: (ABAJO, Def. ARRIBA) de todo: "; read ubicacion2;

if [ "$ubicacion2" != "" ] ; then
        if [ "$ubicacion2" = "ABAJO" ] ||  [ "$ubicacion2" = "abajo" ] ; then
         UBICACION2=" -A PREROUTING "
        fi
        if [ "$ubicacion2" = "ARRIBA" ] || [ "$ubicacion2" = "arriba" ] ; then
         UBICACION2=" -I PREROUTING "
         fi
 else

 UBICACION2=" -I PREROUTING  "

 fi

 echo -n "Protocol: "; read protocol;

          if [ $protocol = "tcp" ] || [ $protocol = "udp" ] ; then
              echo -n "Source Port: "; read srcport;
              echo -n "Destination Port: "; read dstport;
                if [ "$srcport" != ""  ]  ; then # comprueba que sea diferente de nada
                      SRCPORT=" --sport "$srcport
                     fi
                if [ "$dstport" != "" ]  ; then # comprueba que sea diferente de nada
                      DSTPORT=" --dport "$dstport
                     fi
	        fi
    VARFILTER2=$VARFILTER2$UBICACION2" -p "$protocol$SRCPORT$DSTPORT




 echo -n "Source Address (x.x.x.x/prefix): "; read srcaddress2;
      if [ "$srcaddress2" != "" ]  ; then # comprueba que sea diferente de nada
               SRCADDRESS2=" -s "$srcaddress2
      fi

 echo -n "Destination Address(x.x.x.x/prefix): "; read dstaddress2;
      if [ "$dstaddress2" != "" ]  ; then # comprueba que sea diferente de nada
               DSTADDRESS2=" -d "$dstaddress2
      fi
   echo

  interfaces2=$(ifconfig -a|grep Link|awk '{print $1}'|sort)
     echo $interfaces2;
     echo



    echo -n "IN interface (ethX,pppX,etc):";read Ointerface2;
       if [ "$Ointerface2" != "" ]  ; then # comprueba que sea diferente de nada
             OINTERFACE2=" -i "$Ointerface2
       fi

    echo -n "Source Address: ";read srcip;
         if [ "$srcip" != "" ]  ; then # comprueba que sea diferente de nada
             SRCIP=" --to-destination  "$srcip
         fi


 echo -n "comentario: "; read comment2;
           if [ "$comment2" != "" ]  ; then # comprueba que sea diferente de nada
                    COMMENT2=" -m comment --comment ' "$comment2" '"
            fi

VARFILTER2=$VARFILTER2$SRCADDRESS2$DSTADDRESS2$OINTERFACE2" -j DNAT "$SRCIP$COMMENT2

opcion2="";

until [ "$opcion2" = "S" ] ;
do
clear

printf "\n\n"
        echo $VARFILTER2;
        printf "\n\n"

        echo -n "Aplicar? (S/N): ";read opcion2;

        if [ "$opcion2" = "N"  ] ; then
           . $bindir/jack2-firewall.sh
         fi

         done





echo $VARFILTER2 > /tmp/.firewall.dnat
cat /tmp/.firewall.dnat >> /opt/jack2/jack2-firewall.dnat
sh /tmp/.firewall.dnat
rm -f /tmp/.firewall.dnat


   . $bindir/jack2-firewall.sh

#---------------------------------------------------------------------------------------------------------------------
;;


printfile-rules)
echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";
#cat $CONFFILE
sh numrules.sh

echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";

read x;

  . $bindir/jack2-firewall.sh

#-----------------------------------------------------------------------------------------------------------------------  
;;


printfile-snat)

echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";
#cat $CONFFILE
sh numsnat.sh

echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";

read x;

  . $bindir/jack2-firewall.sh

#---------------------------------------------------------------------------------------------------------------------
;;

printfile-dnat)

echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";
#cat $CONFFILE
sh numdnat.sh

echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";

read x;

  . $bindir/jack2-firewall.sh

#---------------------------------------------------------------------------------------------------------------------
;;
 
printfile-masq)

echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";
#cat $CONFFILE
sh nummasq.sh

echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";

read x;

  . $bindir/jack2-firewall.sh

#---------------------------------------------------------------------------------------------------------------------
;;

# Menu de marca de paquetes
mangle)

#-------------------------------------------------------------------------------------------------------------------
;;

show-all-rules)
clear;
echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";

echo -e " \033[1;32m[------- SRC-NAT ----------]\033[0m";echo;
. numsnat.sh;echo;
echo -e " \033[1;32m[------- MASQ ----------]\033[0m";echo;
. nummasq.sh ;echo;
echo -e " \033[1;32m[------- DST-NAT ----------]\033[0m";echo;
. numdnat.sh;echo;
echo -e " \033[1;32m[------- FILTER-RULES ----------]\033[0m";echo;
. numrules.sh;echo ;


read x;

  . $bindir/jack2-firewall.sh

echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";
;;

show-connections)
clear
echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";
  netstat -puta -v -n --numeric-hosts --numeric-ports  
  #-e
echo -e "\n \033[34m [-------------------------------------------------------------------------------------------]\033[0m\n";

read x;

  . $bindir/jack2-firewall.sh


#---------------------------------------------------------------------------------------------------------------------
;;

# Menu de estado del fw
print-active-rules)


echo -e "\n \033[34m [------------------------------- FILTER ---------------------------------------]\033[0m\n";
iptables -t filter -L -n -x -v --line-numbers
echo -e "\n \033[34m [------------------------------------------------------------------------------]\033[0m\n";


read x;
  . $bindir/jack2-firewall.sh

#--------------------------------------------------------------------------------------------------------------------- 


;;	

print-active-nat)

echo -e "\n\033[34m[----------------------------- NAT(src-nat dst-nat) --------------------------------------]\033[0m\n";
	iptables -t nat -L -n -x -v --line-numbers
echo -e "\n \033[34m [------------------------------------------------------------------------------]\033[0m\n";

read x;
  . $bindir/jack2-firewall.sh

#--------------------------------------------------------------------------------------------------------------------   
;;



print-active-mangle)
echo -e "\n\033[34m[----------------------------- MANGLE  --------------------------------------]\033[0m\n";
	iptables -t mangle -L -n -x -v --line-numbers
echo -e "\n \033[34m [------------------------------------------------------------------------------]\033[0m\n";	

read x;
  . $bindir/jack2-firewall.sh
#------------------------------------------------------------------------------------------------------------------- 
;;

show-protocols)
echo -e "\033[1;31m[PROTOCOLS]\033[0m"
echo -e "\n\033[34m[ Number --------- Name ---------------------------------------]\033[0m\n";
cat $bindir/protocols.dat
echo -e "\n\033[34m[------------------------------------  Number  ---------- Name ]\033[0m\n";
read x;
  . $bindir/jack2-firewall.sh

#---------------------------------------------------------------------------------------------------------------------

;;


edit-dnat)
bindir=/root/jack2-firewall


# INGRESO DE DATOS
#-------------------------------------------------------------------------
clear
printf "\n"
printf  " REGLAS \n\n";

sh numdnat.sh   # Vuelca todas las reglas

printf "\n";


echo -n "Numero Regla a editar: "

read num; #

echo -n "Sector PREROUTING,POSTROUTING,OUTPUT: "

read sector;   #

##########################################################################
#-------------------------------------------------------------------------
##########################################################################

echo
echo "EDICION DE REGLA"


VARFILTER2="iptables -t nat"

echo -n "Ubicacion de Regla: (ABAJO, Def. ARRIBA) de todo: "; read ubicacion2;

if [ "$ubicacion2" != "" ] ; then
        if [ "$ubicacion2" = "ABAJO" ] ||  [ "$ubicacion2" = "abajo" ] ; then
         UBICACION2=" -A PREROUTING "
        fi
        if [ "$ubicacion2" = "ARRIBA" ] || [ "$ubicacion2" = "arriba" ] ; then
         UBICACION2=" -I PREROUTING "
         fi
 else

 UBICACION2=" -I PREROUTING  "

 fi

 echo -n "Protocol: "; read protocol;

          if [ $protocol = "tcp" ] || [ $protocol = "udp" ] ; then
              echo -n "Source Port: "; read srcport;
              echo -n "Destination Port: "; read dstport;
                if [ "$srcport" != ""  ]  ; then # comprueba que sea diferente de nada
                      SRCPORT=" --sport "$srcport
                     fi
                if [ "$dstport" != "" ]  ; then # comprueba que sea diferente de nada
                      DSTPORT=" --dport "$dstport
                     fi
                fi
    VARFILTER2=$VARFILTER2$UBICACION2" -p "$protocol$SRCPORT$DSTPORT




 echo -n "Source Address (x.x.x.x/prefix): "; read srcaddress2;
      if [ "$srcaddress2" != "" ]  ; then # comprueba que sea diferente de nada
               SRCADDRESS2=" -s "$srcaddress2
      fi

 echo -n "Destination Address(x.x.x.x/prefix): "; read dstaddress2;
      if [ "$dstaddress2" != "" ]  ; then # comprueba que sea diferente de nada
               DSTADDRESS2=" -d "$dstaddress2
      fi
   echo

  interfaces2=$(ifconfig -a|grep Link|awk '{print $1}'|sort)
     echo $interfaces2;
     echo



    echo -n "IN interface (ethX,pppX,etc):";read Ointerface2;
       if [ "$Ointerface2" != "" ]  ; then # comprueba que sea diferente de nada
             OINTERFACE2=" -i "$Ointerface2
       fi

    echo -n "Source Address: ";read srcip;
         if [ "$srcip" != "" ]  ; then # comprueba que sea diferente de nada
             SRCIP=" --to-destination  "$srcip
         fi


 echo -n "comentario: "; read comment2;
           if [ "$comment2" != "" ]  ; then # comprueba que sea diferente de nada
                    COMMENT2=" -m comment --comment ' "$comment2" '"
            fi

VARFILTER2=$VARFILTER2$SRCADDRESS2$DSTADDRESS2$OINTERFACE2" -j DNAT "$SRCIP$COMMENT2

# aca

##########################################################################
#-------------------------------------------------------------------------
##########################################################################

REGLA=$VARFILTER2; # REGLA IPTABLES

echo


sh numdnat.sh > tmp001                  # Vuelca todas las reglas a un temporal


filtro1=` sh numdnat.sh |grep $sector |grep ^$num`;  # selecciona la regla a editar

opcion2="";

until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo "Demas REGLAS"
cat tmp001 |grep -v "$filtro1"  # Vuelca todas las reglas menos la que tiene $filtro1

printf "\n\n"

echo "REGLA A EDITAR"
echo $filtro1;

printf "\n\n"



echo "REGLA NUEVA"
echo $REGLA


printf "\n\n"
        echo $VARFILTER2;
        printf "\n\n"

        echo -n "Aplicar? (S/N): ";read opcion2;

        if [ "$opcion2" = "N"  ] ; then
#        exit
           . $bindir/jack2-firewall.sh
         fi

         done




num_NEW=$( sh numdnat.sh|grep $sector |grep ^$num|cut -d '|' -f1) #numero de regla seleccionada
NEW=$num_NEW"|"$REGLA;

#sh numrules.sh|grep -v "$filtro1" #muestra todas las reglas excepto la editada
#policy=`cat /opt/jack2/jack2-firewall.post`;

cat tmp001|grep -v "$filtro1" > rules.tmp  # todo menos la politica especificada en /opt/jack2/jack2-firewall.post a rules.tmp

rm -f tmp001

#echo $NEW
echo $NEW >> rules.tmp


cat rules.tmp | sed '/|/!d'|sort -n > rules.new    #limpia las lineas en blanco

rm -f rules.tmp
mv rules.new rules.tmp

clear

#sh numrules.sh

cat rules.tmp |cut -d '|' -f2 > /opt/jack2/jack2-firewall.dnat



iptables -t nat -F

sh  /opt/jack2/jack2-firewall.dnat
sh  /opt/jack2/jack2-firewall.snat
sh  /opt/jack2/jack2-firewall.masq



clear

echo "REGLAS FINALES"

#sh numrules.sh   # Vuelca todas las reglas
sh numdnat.sh

read x;

#fi
 . $bindir/jack2-firewall.sh
;;

edit-snat)
bindir=/root/jack2-firewall


# INGRESO DE DATOS
#-------------------------------------------------------------------------
clear
printf "\n"
printf  " REGLAS \n\n";

sh numsnat.sh   # Vuelca todas las reglas

printf "\n";


echo -n "Numero Regla a editar: "

read num; #

echo -n "Sector PREROUTING,POSTROUTING,OUTPUT: "

read sector;   #

##########################################################################
#-------------------------------------------------------------------------
##########################################################################

echo
echo "EDICION DE REGLA"


VARFILTER2="iptables -t nat"

echo -n "Ubicacion de Regla: (ABAJO, Def. ARRIBA) de todo: "; read ubicacion2;

if [ "$ubicacion2" != "" ] ; then
        if [ "$ubicacion2" = "ABAJO" ] ||  [ "$ubicacion2" = "abajo" ] ; then
         UBICACION2=" -A POSTROUTING "
        fi
        if [ "$ubicacion2" = "ARRIBA" ] || [ "$ubicacion2" = "arriba" ] ; then
         UBICACION2=" -I POSTROUTING "
         fi
 else

 UBICACION2=" -I POSTROUTING "

 fi

 echo -n "Source Address (x.x.x.x/prefix): "; read srcaddress2;
      if [ "$srcaddress2" != "" ]  ; then # comprueba que sea diferente de nada
               SRCADDRESS2=" -s "$srcaddress2
      fi

 echo -n "Destination Address(x.x.x.x/prefix): "; read dstaddress2;
      if [ "$dstaddress2" != "" ]  ; then # comprueba que sea diferente de nada
               DSTADDRESS2=" -d "$dstaddress2
      fi
   echo
  interfaces2=$(ifconfig -a|grep Link|awk '{print $1}'|sort)
     echo $interfaces2;
     echo



    echo -n "OUT interface (ethX,pppX,etc):";read Ointerface2;
       if [ "$Ointerface2" != "" ]  ; then # comprueba que sea diferente de nada
             OINTERFACE2=" -o "$Ointerface2
       fi

    echo -n "Source Address: ";read srcip;
         if [ "$srcip" != "" ]  ; then # comprueba que sea diferente de nada
             SRCIP=" --to "$srcip
         fi




 echo -n "comentario: "; read comment2;
           if [ "$comment2" != "" ]  ; then # comprueba que sea diferente de nada
                    COMMENT2=" -m comment --comment ' "$comment2" '"
            fi


VARFILTER2=$VARFILTER2$UBICACION2$SRCADDRESS2$DSTADDRESS2$OINTERFACE2" -j SNAT "$SRCIP$COMMENT2




# aca

##########################################################################
#-------------------------------------------------------------------------
##########################################################################

REGLA=$VARFILTER2; # REGLA IPTABLES

echo


sh numsnat.sh > tmp002                  # Vuelca todas las reglas a un temporal


filtro1=` sh numsnat.sh |grep $sector |grep ^$num`;  # selecciona la regla a editar

opcion2="";

until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo "Demas REGLAS"
cat tmp002 |grep -v "$filtro1"  # Vuelca todas las reglas menos la que tiene $filtro1

printf "\n\n"

echo "REGLA A EDITAR"
echo $filtro1;

printf "\n\n"



echo "REGLA NUEVA"
echo $REGLA


printf "\n\n"
        echo $VARFILTER2;
        printf "\n\n"

        echo -n "Aplicar? (S/N): ";read opcion2;

        if [ "$opcion2" = "N"  ] ; then
#        exit
           . $bindir/jack2-firewall.sh
         fi

         done




num_NEW=$( sh numsnat.sh|grep $sector |grep ^$num|cut -d '|' -f1) #numero de regla seleccionada
NEW=$num_NEW"|"$REGLA;

#sh numrules.sh|grep -v "$filtro1" #muestra todas las reglas excepto la editada
#policy=`cat /opt/jack2/jack2-firewall.post`;

cat tmp002|grep -v "$filtro1" > rules.tmp  # todo menos la politica especificada en /opt/jack2/jack2-firewall.post a rules.tmp

rm -f tmp002

#echo $NEW
echo $NEW >> rules.tmp


cat rules.tmp | sed '/|/!d'|sort -n > rules.new    #limpia las lineas en blanco

rm -f rules.tmp
mv rules.new rules.tmp

clear

#sh numrules.sh

cat rules.tmp |cut -d '|' -f2 > /opt/jack2/jack2-firewall.snat



iptables -t nat -F

sh  /opt/jack2/jack2-firewall.dnat
sh  /opt/jack2/jack2-firewall.snat
sh  /opt/jack2/jack2-firewall.masq



clear

echo "REGLAS FINALES"

#sh numrules.sh   # Vuelca todas las reglas
sh numsnat.sh

read x;

 . $bindir/jack2-firewall.sh

;;

edit-masq)
bindir=/root/jack2-firewall


# INGRESO DE DATOS
#-------------------------------------------------------------------------
clear
printf "\n"
printf  " REGLAS \n\n";

sh nummasq.sh   # Vuelca todas las reglas 

printf "\n";


echo -n "Numero Regla a editar: "

read num; #

echo -n "Sector PREROUTING,POSTROUTING,OUTPUT: "

read sector;   #

##########################################################################
#-------------------------------------------------------------------------
##########################################################################

echo 
echo "EDICION DE REGLA"

VARFILTER2="iptables -t nat"

echo -n "Ubicacion de Regla: (ABAJO, Def. ARRIBA) de todo: "; read ubicacion2;

if [ "$ubicacion2" != "" ] ; then
        if [ "$ubicacion2" = "ABAJO" ] ||  [ "$ubicacion2" = "abajo" ] ; then
         UBICACION2=" -A POSTROUTING "
        fi
        if [ "$ubicacion2" = "ARRIBA" ] || [ "$ubicacion2" = "arriba" ] ; then
         UBICACION2=" -I POSTROUTING "
         fi
 else

 UBICACION2=" -I POSTROUTING"
 
 fi

 echo -n "Source Address (x.x.x.x/prefix): "; read srcaddress2;
      if [ "$srcaddress2" != "" ]  ; then # comprueba que sea diferente de nada
               SRCADDRESS2=" -s "$srcaddress2
      fi

 echo -n "Destination Address(x.x.x.x/prefix): "; read dstaddress2;
      if [ "$dstaddress2" != "" ]  ; then # comprueba que sea diferente de nada
               DSTADDRESS2=" -d "$dstaddress2
      fi
   echo
  interfaces2=$(ifconfig -a|grep Link|awk '{print $1}'|sort)
     echo $interfaces2;
     echo

    echo -n "OUT interface (ethX,pppX,etc):";read Ointerface2;
       if [ "$Ointerface2" != "" ]  ; then # comprueba que sea diferente de nada
             OINTERFACE2=" -o "$Ointerface2
       fi
 echo -n "comentario: "; read comment2;
           if [ "$comment2" != "" ]  ; then # comprueba que sea diferente de nada
                    COMMENT2=" -m comment --comment ' "$comment2" '"
            fi
    echo

VARFILTER2=$VARFILTER2$UBICACION2$SRCADDRESS2$DSTADDRESS2$OINTERFACE2$COMMENT2" -j MASQUERADE"



# aca

##########################################################################
#-------------------------------------------------------------------------
##########################################################################

REGLA=$VARFILTER2; # REGLA IPTABLES

echo


sh nummasq.sh > tmp002  		# Vuelca todas las reglas a un temporal


filtro1=` sh nummasq.sh |grep $sector |grep ^$num`;  # selecciona la regla a editar

opcion2="";

until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo "Demas REGLAS"
cat tmp002 |grep -v "$filtro1"  # Vuelca todas las reglas menos la que tiene $filtro1

printf "\n\n"

echo "REGLA A EDITAR"
echo $filtro1;

printf "\n\n"



echo "REGLA NUEVA"
echo $REGLA


printf "\n\n"
        echo $VARFILTER2;
        printf "\n\n"

        echo -n "Aplicar? (S/N): ";read opcion2;

        if [ "$opcion2" = "N"  ] ; then
#	 exit
           . $bindir/jack2-firewall.sh
         fi

         done




num_NEW=$( sh numsnat.sh|grep $sector |grep ^$num|cut -d '|' -f1) #numero de regla seleccionada
NEW=$num_NEW"|"$REGLA;

#sh numrules.sh|grep -v "$filtro1" #muestra todas las reglas excepto la editada
#policy=`cat /opt/jack2/jack2-firewall.post`;

cat tmp002|grep -v "$filtro1" > rules.tmp  # todo menos la politica especificada en /opt/jack2/jack2-firewall.post a rules.tmp

rm -f tmp002

#echo $NEW 
echo $NEW >> rules.tmp


cat rules.tmp | sed '/|/!d'|sort -n > rules.new    #limpia las lineas en blanco

rm -f rules.tmp
mv rules.new rules.tmp

clear

#sh numrules.sh

cat rules.tmp |cut -d '|' -f2 > /opt/jack2/jack2-firewall.masq



iptables -t nat -F

sh  /opt/jack2/jack2-firewall.dnat
sh  /opt/jack2/jack2-firewall.snat
sh  /opt/jack2/jack2-firewall.masq



clear

echo "REGLAS FINALES"

#sh numrules.sh   # Vuelca todas las reglas
sh nummasq.sh

read x;
#fi
 . $bindir/jack2-firewall.sh
;;

edit-mangle)
;;


edit-rules)

bindir=/root/jack2-firewall

# INGRESO DE DATOS
#-------------------------------------------------------------------------
clear
printf "\n"
printf  " REGLAS \n\n";

sh numrules.sh   # Vuelca todas las reglas

printf "\n";


echo -n "Numero Regla a editar: "

read num; #

echo -n "Sector INPUT,OUTPUT,FORWARD: "

read sector;   #

##########################################################################
#-------------------------------------------------------------------------
##########################################################################

echo
echo "EDICION DE REGLA"


SRCPORT="";
DSTPORT="";

VARFILTER="iptables";


echo -n "Ubicacion de Regla: (ABAJO, Def. ARRIBA ) de todo: "; read ubicacion;

if [ "$ubicacion" != "" ] ; then

 if [ "$ubicacion" = "ABAJO" ] ||  [ "$ubicacion" = "abajo" ] ; then
   UBICACION=" -A "
 fi
 if [ "$ubicacion" = "ARRIBA" ] || [ "$ubicacion" = "arriba" ] ; then
   UBICACION=" -I "
 fi

 else
    UBICACION=" -I "
fi


        echo -n "Type (INPUT,OUTPUT,FORWARD): "; read trule;


   if [ "$trule" = "INPUT" ] || [ "$trule" = "OUTPUT" ] || [ "$trule" = "FORWARD" ] ; then

        VARFILTER=$VARFILTER$UBICACION" "$trule;
         echo -n "Protocol: "; read protocol;

         if [ $protocol = "tcp" ] || [ $protocol = "udp" ] ; then
            echo -n "Source Port: "; read srcport;
            echo -n "Destination Port: "; read dstport;

             if [ "$srcport" != ""  ]  ; then # comprueba que sea diferente de nada
                SRCPORT=" --sport "$srcport
             fi

             if [ "$dstport" != "" ]  ; then # comprueba que sea diferente de nada
               DSTPORT=" --dport "$dstport
             fi
         fi

        VARFILTER=$VARFILTER" -p "$protocol$SRCPORT$DSTPORT

        echo -n "Source Address (x.x.x.x/prefix): "; read srcaddress;
                 if [ "$srcaddress" != "" ]  ; then # comprueba que sea diferente de nada
                        SRCADDRESS=" -s "$srcaddress
                 fi
        echo -n "Destination Address(x.x.x.x/prefix): "; read dstaddress;
                 if [ "$dstaddress" != "" ]  ; then # comprueba que sea diferente de nada
                        DSTADDRESS=" -d "$dstaddress
                 fi

        echo
                                                                # Muestra las interfaces de red
         interfaces=$(ifconfig -a|grep Link|awk '{print $1}'|sort)
         echo $interfaces;

        echo
        echo
        if [ "$trule" = "INPUT" ] || [ "$trule" = "FORWARD" ]  ; then

        echo -n "IN interface (ethX,pppX,etc): ";read Iinterface;
           if [ "$Iinterface" != "" ]  ; then # comprueba que sea diferente de nada
                   IINTERFACE=" -i "$Iinterface
           fi
        fi
        if [ "$trule" = "OUTPUT" ] || [ "$trule" = "FORWARD" ]  ; then

        echo -n "OUT interface (ethX,pppX,etc):";read Ointerface;
           if [ "$Ointerface" != "" ]  ; then # comprueba que sea diferente de nada
                   OINTERFACE=" -o "$Ointerface
           fi
        fi
        echo
        echo -n "Action(ACCEPT,REJECT,DROP): "; read action;
           if [ "$action" = "ACCEPT" ] || [ "$action" = "REJECT" ] || [ "$action" = "DROP" ] ; then
                   ACTION=" -j "$action
           fi

	   if [ -z $action ] ; then
	      ACTION=" -j ACCEPT"
	   fi


 echo -n "State(NEW,ESTABLISHED,INVALID,RELATED): "; read state;
   if [ "$state" = "NEW" ] || [ "$state" = "ESTABLISHED" ] || [ "$state" = "INVALID" ] || [ "$state" = "RELATED" ]  ; then
           STATE=" -m state --state "$state
   fi
   if [ -z $state ]; then
      STATE=" -m state --state NEW,ESTABLISHED,INVALID,RELATED"
   fi

        echo -n "comentario: "; read comment;
        if [ "$comment" != "" ]  ; then # comprueba que sea diferente de nada
               COMMENT=" -m comment --comment ' "$comment" '"
        fi

        echo

VARFILTER=$VARFILTER$SRCADDRESS$DSTADDRESS$IINTERFACE$OINTERFACE$ACTION$STATE$COMMENT




##########################################################################
#-------------------------------------------------------------------------
##########################################################################

REGLA=$VARFILTER; # REGLA IPTABLES

echo


sh numrules.sh > tmp001                 # Vuelca todas las reglas a un temporal


filtro1=` sh numrules.sh |grep $sector |grep ^$num`;  # selecciona la regla a editar

opcion2="";

until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo "Demas REGLAS"
cat tmp001 |grep -v "$filtro1"  # Vuelca todas las reglas menos la que tiene $filtro1

printf "\n\n"

echo "REGLA A EDITAR"
echo $filtro1;

printf "\n\n"



echo "REGLA NUEVA"
echo $REGLA


printf "\n\n"
        echo $VARFILTER2;
        printf "\n\n"

        echo -n "Aplicar? (S/N): ";read opcion2;

        if [ "$opcion2" = "N"  ] ; then
#        exit
           . $bindir/jack2-firewall.sh
         fi

 done



num_NEW=$( sh numrules.sh|grep $sector |grep ^$num|cut -d '|' -f1) #numero de regla seleccionada
NEW=$num_NEW"|"$REGLA;

#sh numrules.sh|grep -v "$filtro1" #muestra todas las reglas excepto la editada
policy=`cat /opt/jack2/jack2-firewall.post`;

cat tmp001|grep -v "$filtro1"|grep -v "$policy" > rules.tmp  # todo menos la politica especificada en /opt/jack2/jack2-firewall.post a rules.tmp

rm -f tmp001

#echo $NEW
echo $NEW >> rules.tmp


cat rules.tmp | sed '/|/!d'|sort -n > rules.new    #limpia las lineas en blanco

rm -f rules.tmp
mv rules.new rules.tmp

#sh numrules.sh

cat rules.tmp |cut -d '|' -f2 > /opt/jack2/jack2-firewall.conf


sh  /opt/jack2/jack2-firewall.pre
sh  /opt/jack2/jack2-firewall.conf
sh /opt/jack2/jack2-firewall.post


clear

#read x;

fi
 . $bindir/jack2-firewall.sh
 
 
 ;;


#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


del-rule)

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

;;
#------------------------------------------------------------------------------------------------------------------------ 

del-masq)

bindir=/root/jack2-firewall

clear

printf "\n"
printf  " REGLAS \n\n";

sh nummasq.sh   # Vuelca todas las reglas

printf "\n";


echo -n "Numero Regla a Borrar: "

read num; #

echo -n "Sector PREROUTING,POSTROUTING,OUTPUT: "

read sector;   #

REGLA=" "; # REGLA IPTABLES


sh nummasq.sh > tmp002                 # Vuelca todas las reglas a un temporal



filtro1=` sh nummasq.sh |grep $sector |grep ^$num`;


opcion2="";


until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo "Demas reglas:"
cat tmp002 |grep -v "$filtro1"  # Vuelca todas las reglas menos la que tiene $num

printf "\n\n"

echo "Regla A Borrar:"
echo $filtro1;

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




num_NEW=$( sh nummasq.sh|grep $sector |grep ^$num|cut -d '|' -f1) #numero de regla seleccionada
NEW=$num_NEW"|"$REGLA;

#policy=`cat /opt/jack2/jack2-firewall.post`;

cat tmp002|grep -v "$filtro1" > rules.tmp  # todo menos lo especificada en rules.tmp

#cat tmp001|grep -v "$filtro1"|grep -v "$policy" > rules.tmp  # todo menos la politica especificada en /opt/jack2/jack2-firewall.post a rules.tmp

rm -f tmp002

echo $NEW >> rules.tmp


cat rules.tmp | sed '/|/!d'|sort -n > rules.new    #limpia las lineas en blanco

rm -f rules.tmp
mv rules.new rules.tmp

clear

cat rules.tmp |cut -d '|' -f2 > /opt/jack2/jack2-firewall.masq


iptables -t nat -F

sh  /opt/jack2/jack2-firewall.dnat
sh  /opt/jack2/jack2-firewall.snat
sh  /opt/jack2/jack2-firewall.masq



clear

echo "REGLAS FINALES"

sh nummasq.sh   # Vuelca todas las reglas


read x;

 . $bindir/jack2-firewall.sh

;;

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
del-snat)

bindir=/root/jack2-firewall

clear

printf "\n"
printf  " REGLAS \n\n";

sh numsnat.sh   # Vuelca todas las reglas

printf "\n";


echo -n "Numero Regla a Borrar: "

read num; #

echo -n "Sector PREROUTING,POSTROUTING,OUTPUT: "

read sector;   #

REGLA=" "; # REGLA IPTABLES


sh numsnat.sh > tmp004                 # Vuelca todas las reglas a un temporal



filtro1=` sh numsnat.sh |grep $sector |grep ^$num`;


opcion2="";


until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo "Demas reglas:"
cat tmp004 |grep -v "$filtro1"  # Vuelca todas las reglas menos la que tiene $num

printf "\n\n"

echo "Regla A Borrar:"
echo $filtro1;

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




num_NEW=$( sh numsnat.sh|grep $sector |grep ^$num|cut -d '|' -f1) #numero de regla seleccionada
NEW=$num_NEW"|"$REGLA;

#policy=`cat /opt/jack2/jack2-firewall.post`;

cat tmp004|grep -v "$filtro1" > rules.tmp  # todo menos lo especificada en rules.tmp

#cat tmp001|grep -v "$filtro1"|grep -v "$policy" > rules.tmp  # todo menos la politica especificada en /opt/jack2/jack2-firewall.post a rules.tmp

rm -f tmp003

echo $NEW >> rules.tmp


cat rules.tmp | sed '/|/!d'|sort -n > rules.new    #limpia las lineas en blanco

rm -f rules.tmp
mv rules.new rules.tmp

clear

cat rules.tmp |cut -d '|' -f2 > /opt/jack2/jack2-firewall.snat


iptables -t nat -F

sh  /opt/jack2/jack2-firewall.dnat
sh  /opt/jack2/jack2-firewall.snat
sh  /opt/jack2/jack2-firewall.masq



clear

echo "REGLAS FINALES"

sh numsnat.sh   # Vuelca todas las reglas


read x;

 . $bindir/jack2-firewall.sh


;;
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

del-dnat)

bindir=/root/jack2-firewall

clear

printf "\n"
printf  " REGLAS \n\n";

sh numdnat.sh   # Vuelca todas las reglas

printf "\n";


echo -n "Numero Regla a Borrar: "

read num; #

echo -n "Sector PREROUTING,POSTROUTING,OUTPUT: "

read sector;   #

REGLA=" "; # REGLA IPTABLES


sh numdnat.sh > tmp003                 # Vuelca todas las reglas a un temporal



filtro1=` sh numdnat.sh |grep $sector |grep ^$num`;


opcion2="";


until [ "$opcion2" = "S" ] ;
do

clear

printf "\n\n"

echo "Demas reglas:"
cat tmp003 |grep -v "$filtro1"  # Vuelca todas las reglas menos la que tiene $num

printf "\n\n"

echo "Regla A Borrar:"
echo $filtro1;

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




num_NEW=$( sh numdnat.sh|grep $sector |grep ^$num|cut -d '|' -f1) #numero de regla seleccionada
NEW=$num_NEW"|"$REGLA;

#policy=`cat /opt/jack2/jack2-firewall.post`;

cat tmp003|grep -v "$filtro1" > rules.tmp  # todo menos lo especificada en rules.tmp

#cat tmp001|grep -v "$filtro1"|grep -v "$policy" > rules.tmp  # todo menos la politica especificada en /opt/jack2/jack2-firewall.post a rules.tmp

rm -f tmp003

echo $NEW >> rules.tmp


cat rules.tmp | sed '/|/!d'|sort -n > rules.new    #limpia las lineas en blanco

rm -f rules.tmp
mv rules.new rules.tmp

clear

cat rules.tmp |cut -d '|' -f2 > /opt/jack2/jack2-firewall.dnat


iptables -t nat -F

sh  /opt/jack2/jack2-firewall.dnat
sh  /opt/jack2/jack2-firewall.snat
sh  /opt/jack2/jack2-firewall.masq



clear

echo "REGLAS FINALES"

sh numdnat.sh   # Vuelca todas las reglas


read x;

 . $bindir/jack2-firewall.sh

;;





exit )

cd /root

. ./Jack2-Main.sh

;;




*)

echo "Opcion Incorrecta !";

sleep 1

  . $bindir/jack2-firewall.sh

#----------------------------------------------------------------------------------------------------------------------   

;;

esac


