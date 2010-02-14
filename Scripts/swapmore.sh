#!/bin/bash

#swapmore

#script doesnt work yet

#script that is intent to give you more swapspace during runtime
#however swapspace is not the same as the original created swap
#and cannot replace low memory

##VARS
SIZE=512 #if no option is used swapmore creates a swapfile with nearly 512 MB in /tmp
SAVE="/tmp"
NAME="swapfile.swap"
SETSIZE=no
FORM=noform
##VARS

##messages in first
drop_failure()
{
	echo -e '\t\t\t\t \E[31mfailure'; tput sgr0
}

drop_ok ()
{
	echo -e '\t \t \t \t \E[32mok'; tput sgr0
}
##messages in first

##options starts here
option_h()
{
	echo "$0 [-u] [-h]"
	echo "-h show this help"
	echo "-u undo swapfile: turn off swapfile and delete swapfile"
	echo "-m set optional size of swapfile in megabites"
	echo "-g set optional size of swapfile in gigabites"
	exit 0
}

option_g()
{
SIZE="$OPTARG"
#PARTSIZE is read in by df -h. the awk one liner prints the second column
#marked by $2 print action satetment. and finaly sed cuts off the G by
#replacing it with a blank space
PARTSIZE=$(df -h ${SAVE}/|awk '{print $4}'|tail -1|sed 's/G/ /g') 
#Allwosize is 60 percent of the size available
ALLOWSIZE=$(((60*$PARTSIZE)/100))
SETSIZE=yes
FORM=GB
#scince SIZE must match each numbers [0-9] this will also test for valid
#integers
if [ "$SIZE" -lt "$ALLOWSIZE" ]
	then
		echo "Swapfilesize: $SIZE GB"
		echo "Allowed Size: $ALLOWSIZE GB"
		drop_ok 
	else
		echo "$PARTSIZE GB are free on this System."
		echo "and $ALLOWSIZE GB are free for creating a swapfile in $SAVE"
		echo "Your value is $SIZE GB which may be not an integer value"
		echo "or the specified size is bigger than the allowed size"
		drop_failure
		exit 1
fi
 }


option_m ()
{
SIZE="$OPTARG"
#PARTSIZE is read in by df -h. the awk one liner prints the second column
#marked by $2 print action satetment. and finaly sed cuts off the G by
#replacing it with a blank space
PARTSIZE=$(df -m ${SAVE}/|awk '{print $4}'|tail -1|sed 's/G/ /g') 
#Allwosize is 60 percent of the size available
ALLOWSIZE=$(((60*$PARTSIZE)/100))
SETSIZE=yes
FORM=MB
#scince SIZE must match each numbers [0-9] this will also test for valid
#integers
if [ "$SIZE" -lt "$ALLOWSIZE" ]
	then
		echo "Swapfilesize: $SIZE MB"
		echo "Allowed Size: $ALLOWSIZE MB"
		drop_ok 
	else
		echo "$PARTSIZE MB are free on this System."
		echo "and $ALLOWSIZE MB are free for creating a swapfile in $SAVE"
		echo "Your value is $SIZE which may be not an integer value"
		echo "or the specified size is bigger than the allowed size"
		drop_failure
		exit 1
fi
}

option_u () #swapoff and delete swapfile
{
	if [ -f $SAVE/$NAME ]
		then
			swapoff $SAVE/$NAME
			rm $SAVE/$NAME
			drop_ok
			exit 0
		else
			echo "no swapfile in use"
			drop_failure
			exit 1
	fi
}

##options starts here

while getopts g:m:uh opt
	do
		case $opt in
			m) option_m
			;;
			g) option_g
			;;
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
	if [ "$SETSIZE" = "yes" ]
		then
			if [ "$FORM" = "GB" ]
				then
					#i know there is actualy a bs=1G option also
					#but this is very slow in runtime
					SIZE=$(($SIZE*1024))
					dd if=/dev/zero of=/$SAVE/$NAME bs=1M count=$SIZE
					chmod 0600 $SAVE/$NAME
					mkswap $SAVE/$NAME
					swapon -v $SAVE/$NAME
			
			elif [ "$FORM" = "MB"  ]
				then
				dd if=/dev/zero of=$SAVE/$NAME bs=1M count=$SIZE
				chmod 0600 $SAVE/$NAME
				mkswap $SAVE/$NAME
				swapon -v $SAVE/$NAME
			fi
		else
			dd if=/dev/zero of=$SAVE/$NAME bs=1M count=$SIZE
			chmod 0600 $SAVE/$NAME
			mkswap $SAVE/$NAME
			swapon -v $SAVE/$NAME
	fi
}


check_root

#options
#-m set size in megabytes
#-g set size in gigabytes
#-s set place and name where to create the Swapfile manualy
#checking if there are enough bytes to proceed
#-u unswap and remove existing swapfile
#-p manage priority for exiting swapfiles
#still need method to check for integers
#no multiple swapfiles are implemented yet
