#/bin/bash



PARTICION=`fdisk -l |grep "*"|grep "/dev/"|cut -d "*" -f1`
DISCO=`fdisk -l|grep Disk|cut -d : -f1|sed s/Disk/""/|sed s/" "/""/`

 mkfs.ext3  $PARTICION


mkdir /mnt/HD

mount $PARTICION /mnt/HD/

cp --preserve -R /{bin,dev,home,pentest,root,usr,etc,lib,opt,sbin,var} /mnt/HD/


mkdir /mnt/HD/{mnt,proc,sys,tmp}

mount --bind /dev/ /mnt/HD/dev/

mount -t proc proc /mnt/HD/proc

cp /boot/vmlinuz /mnt/HD/boot


chroot /mnt/HD /bin/bash


cat /dev/null > /etc/lilo.conf


echo "boot = $DISCO " > /etc/lilo.conf
echo "promtp" >> /etc/lilo.conf
echo "timeout = 1200 " >> /etc/lilo.conf
echo "change-rules" >> /etc/lilo.conf
echo "reset" >> /etc/lilo.conf
echo "vga=791" >> /etc/lilo.conf
echo "image = /boot/vmlinuz" >> /etc/lilo.conf
echo "root = $PARTICION" >> /etc/lilo.conf
echo "label = Linux" >> /etc/lilo.conf
echo "read-only" >> /etc/lilo.conf


lilo

