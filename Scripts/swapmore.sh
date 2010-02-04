#!/bin/bash

#swapmore

#script that is intent to give you more swapspace during runtime
#however swapspace is not the same as the original created swap
#and cannot replace low memory

##VARS
SIZE=512 #if no option is used swapmore creates a swapfile with nearly 512 MB in /tmp
SAVE="/tmp"
NAME="swapfile.swap"
##VARS

##messages in first
drop_failure()
{
	echo -e '\t\t\t\t \E[31mfailure'; tput sgr0
}
##messages in first

##options starts here
option_h()
{
	echo "$0 [-u] [-h]"
	echo "-h show this help"
	echo "-u undo swapfile: turn off swapfile and delete swapfile"
	exit 0
}

option_u () #swapoff and delete swapfile
{
	if [ -f $SAVE/$NAME ]
		then
			swapoff $SAVE/$NAME
			rm $SAVE/$NAME
		else
			echo "no swapfile in use"
			drop_failure
			exit 1
	fi
}

##options starts here

while getopts uh opt
	do
		case $opt in 
			u) option_u #unswap the swapfile
			;;
			h) option_h #get help 
			;;
			\?) option_h #get help in case of illegal options
		esac
	
	done
shift `expr $OPTIND - 1`

check_root()
{
if [ $UID -ne 0 ]
	then
		drop_failure
		echo "not root"
		exit 1
	else
		main
	fi
}


main()
{
	dd if=/dev/zero of=$SAVE/$NAME bs=1M count=$SIZE
	chmod 0600 $SAVE/$NAME
	mkswap $SAVE/$NAME
	swapon -v $SAVE/$NAME
}


check_root

#options
#-m set size in megabytes
#-g set size in gigabytes
#-s set place and name where to create the Swapfile manualy
#checking if there are enough bytes to proceed
#-u unswap and remove existing swapfile
