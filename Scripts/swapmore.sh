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

drop_failure()
{
	echo -e '\t\t\t\t \E[31mfailure'; tput sgr0
}

check_root

#options
#-m set size in megabytes
#-g set size in gigabytes
#-s set place and name where to create the Swapfile manualy
