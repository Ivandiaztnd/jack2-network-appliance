#!/bin/sh
#
# bootcdflop.sh
#

MNT=/mnt
FLOPPY=/dev/fd0
BOOT_ONLY_WITH_FLOPPY=no
FSTYPES="ext3,ext2,reiserfs,iso9660,vfat,auto"

# bootcdwrite modifies this script. FLOPPY could be unset.
if [ ! "$FLOPPY" ]; then
  echo "No Floppy device specified !!"
  exit 0
fi

echo "Reading floppy"
fsck -a -t $FSTYPES $FLOPPY
mount -v -o ro -n -t $FSTYPES $FLOPPY $MNT
RET=$?

if [ "$BOOT_ONLY_WITH_FLOPPY" = "yes" -a $RET -ne 0 ]; then
  echo "The floppy could not be mounted."
  echo "Manual interaction required."
  # Start a single user shell on the console
  /sbin/sulogin $CONSOLE
fi

[ -f $MNT/change.tgz ] && (cd /; tar xzf $MNT/change.tgz)

[ -f $MNT/remove ] && for i in `cat $MNT/remove`
do
  rm -f /$i
done

[ -x $MNT/execute ] && $MNT/execute

umount $MNT

# If something has been changed in /etc/inittab
init q
