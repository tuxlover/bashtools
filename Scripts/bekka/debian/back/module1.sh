#!/bin/bash

##this script implements the debian methode of retieving all
#datas which do not belong to any package

apt-get clean
#clean cache of not needed packages to save runtime in /var

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

FIND_TREE=$(find / -path /mnt -prune -o -path /media -prune -o -path /home -prune -o -path /root -prune -o -path /dev -prune -o -path /sys -prune -o -path /proc -prune -o -path /boot -prune -o -path /tmp -prune -o -path /etc -prune -o -print)
#getting all  files present on the system
# we exclde /media /mnt /home /root /dev /sys /proc /boot /tmp /etc
#for certain reasons

for f in $FIND_TREE
	do
		grep $f installed.lst || echo $f >> notinstalled.lst  
done
#now creating the list of all files which are not belonging to either packages
#there might be a better method with uniq somehow but doesnt work

exit 0

NOT_IN=$(cat notinstallled.lst)
#reading list of not installed files into variable

mkdir -p /tmp/save_bekka #the name could be like  Year_Month_day_Hour_Minute

for file in $NOT_IN
	do
		echo "saving $file"
		cp -a --parents $file /tmp/save_bekka
	done
#copying files into temporary directory /tmp/save_bekka
#the --parents switch ensures that the whole path is copied
#this will make it easier to restore these package

cp  notinstalled.lst /tmp/save_bekka
#copy list to temporary directory
#maybe we can even move as we dont need this list any longer after
#this procedure is done

tar cvfz save_bekka.tar.gz /tmp/save_bekka
#tar.gz and the save the files in current directory
#Todo: give destination of final archive via options

rm -rf /tmp/save_bekka
#remove the temporary files

exit 0

