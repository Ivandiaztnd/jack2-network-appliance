#!/bin/sh
# bootcdram.sh	Necessary steps to boot diskless from cd
# at Boottime /etc -> /ram1/etc -> /etc.ro (also dev, tmp, var, home, root)

CHNG="/var.ro/cache/locate/locatedb"
CHNGGREP="grep -v -e ^/var.ro/cache/locate/locatedb"
BORDERLINKS=""

# INODES are expensive (8192 INODES need 1 MB RAM)
echo -n "Minimum of needed INODES: "
if [ -f /ram1.cpio.gz ]; then
  I1=$(zcat /ram1.cpio.gz | cpio -it | wc -l)
else
  I1=$(find /home.ro /root.ro /etc.ro /dev.ro | $CHNGGREP | wc -l)
fi

if [ -f /ram2.cpio.gz ]; then
  I2=$(zcat /ram2.cpio.gz | cpio -it | wc -l)
else
  I2=$(find /var.ro -type d | $CHNGGREP | wc -l)
fi

I=$I1; [ $I2 -gt $I ] && I=$I2
I=$(expr $I \* 11 / 10)

echo "$I"

RAMDISK_SIZE=$(sfdisk -s /dev/ram1) # Could be changed at boot prompt
# Use at least $I inodes per ramdisk
if [ $RAMDISK_SIZE -le $I ]; then 
  INODES="-N $I"
  echo "Creating ram1 and ram2 with exactly $I INODES each"
else
  INODES="-i 1024"
  echo "Creating ram with 1024 INODES per MB"
fi

mke2fs -q $INODES /dev/ram1 # Size is defined by ramdisk_size at boottime

if [ -c /dev/.devfsd ]; then
  mount /dev/ram1 /ram1 -o defaults,rw
  echo 'Remounting devfs'
  mkdir /ram1/dev
  mount -n -t devfs none /dev
else
  mount /dev/ram1 /ram1 -o defaults,rw
fi

if [ -f /ram1.cpio.gz ]; then
  echo 'Extracting /ram1.cpio.gz'
  cd /ram1; zcat /ram1.cpio.gz | cpio -idum
else
  mkdir /ram1/tmp; chmod 1777 /ram1/tmp
  for i in home root etc dev; do find /$i.ro | $CHNGGREP | cpio -pdm /ram1; done
  for i in home root etc dev; do mv /ram1/$i.ro /ram1/$i; done
fi

for i in $BORDERLINKS; do
  ln -sf ../$i /ram1/$i
done

mke2fs -q $INODES /dev/ram2 # Size is defined by ramdisk_size at boottime
mount /dev/ram2 /ram2 -o defaults,rw
if [ -f /ram2.cpio.gz ]; then
  echo 'Extracting /ram2.cpio.gz'
  cd /ram2; zcat /ram2.cpio.gz | cpio -idum
else
  find /var.ro -type d | $CHNGGREP | cpio -pdm /ram2
  for i in var; do mv /ram2/$i.ro /ram2/$i; done
fi

# enable wtmp and lastlog record keeping
touch /var/log/wtmp /var/log/lastlog
chown root.utmp /var/log/wtmp /var/log/lastlog
chmod 664 /var/log/wtmp /var/log/lastlog

for i in $CHNG; do
  j=$(echo $i | sed "s/\.ro//")
  mkdir -p $(dirname $j)
  ln -s $i $j
done

# Recreate udev (needed for kernel >2.6.8)
if [ -x /etc/init.d/udev ]; then 
  /etc/init.d/udev stop
  /etc/init.d/udev start
fi
