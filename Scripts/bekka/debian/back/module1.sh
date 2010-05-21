#!/bin/bash

##this script tests the debian methode of retieving all
#datas which don not belong to any package

INST_P=$(dpkg -l |awk '{print $2}') #returns an array each element  holding
#a valid installed package
#awk use to get only the names of packages
#Todo: truncate unneccary pattern string in the beginning

for p in $INST_P
	do
		dpkg -L $p >> installed.lst || echo "not valid" 2>/dev/null
done
#reading the INST_P variable in a for loop and  check every package for
#containing files. than writing each filename to the installed.lst
##Todo: each package starts with /.  we need to avoid this

FIND_TREE=$(find / -path /mnt -prune -o -path /media -prune -o -path /home -prune -o -path /root -prune -o -path /dev -prune -o -path /sys -prune -o -path /proc -prune -o -path /boot -prune -o -print)
#getting all  files present on the system
# we exclde /media /mnt /home /root /dev /sys /proc /boot
#for certain reasons

for f in $FIND_TREE
	do
		grep $f installed.lst || echo $f >> notinstalled.lst  
done
#now creating the list of all files which are not belonging to either packages
#there might be a better method with uniq somehow but doesnt work

exit 0

