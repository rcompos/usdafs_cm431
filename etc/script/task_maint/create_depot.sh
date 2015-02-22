#!/bin/ksh
#
#  @(#)fs615/tc/esm/instl/instl3/gateway_cleanup.sh, esm, build3_2, build3_2e,1.1:9/26/01:09:26:34
#  VERSION:  1.1
#  DATE:  9/26/01:09:26:34
#
#
#  (C) COPYRIGHT International Business Machines Corp. 1996
#  All Rights Reserved
#  Licensed Materials - Property of IBM
#
#  US Government Users Restricted Rights - Use, duplication or
#  disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#

# Script will remove the Tivoli36, backup, and inst.images 
# Logical Volume and Filesystem freeing 
# up space to create a depot logical volume and filesytem

function exit_on_fail
{
  rc=$?
  if [[ $rc != 0 ]]; then
    print $1
    exit $rc
  fi
}

# Removing Logical Volumes 
lslv Tivoli36 >/dev/null 2>/dev/null
if [[ $? = 0 ]]; then
   print "Removing logical volume & filesytem for Tivoli36"
   MOUNT_POINT=$(lslv Tivoli36 | grep MOUNT | awk '{print $3}')
   umount $MOUNT_POINT
   rmfs $MOUNT_POINT
   exit_on_fail "Could not create lv & filesystem for Tivoli36"
fi

lslv backup
if [[ $? = 0 ]]; then
   print "Removing logical volume & filesystem for backup"
   MOUNT_POINT=$(lslv backup | grep MOUNT | awk '{print $3}')
   umount $MOUNT_POINT
   rmfs $MOUNT_POINT
   exit_on_fail "Could not create lv & filesystem for backup"
fi

lslv inst.images
if [[ $? = 0 ]]; then
   print "Removing logical volume filesytem for inst.images"
   MOUNT_POINT=$(lslv inst.images | grep MOUNT | awk '{print $3}')
   umount $MOUNT_POINT
   rmfs $MOUNT_POINT
   exit_on_fail "Could not create lv & filesystem for inst.images"
fi

# Checking Total Number of free partitions to create deport
# Logical Volume


FREE_PPS=$(lsvg rootvg | grep FREE | awk '{print $6}')
print "Their are a total of $FREE_PPS free PP's on rootvg"
DEPOT_PPS=$(( $FREE_PPS - 70 ))
print "The logical volume depot will have $DEPOT_PPS PP's"

# Creating logical volume and filesystem
print "Creating logical volume and filesystem"
DEPOT_MOUNT=/usr/local/Tivoli/depot
/usr/sbin/mklv -y 'depot' rootvg $DEPOT_PPS
/usr/sbin/crfs -v jfs -d 'depot' -m $DEPOT_MOUNT -A 'yes' -p 'rw' -a 'bf=true'
mount $DEPOT_MOUNT

print "The creation of depot logical volume and filesystem is complete"

return 0
# End of gateway_cleanup.sh

