#!/bin/bash

#broken-links
#Script that checks for broken Symlinks and outputs them.

#Comes with package Bash-Tools
#Ideas collected by Mendel Cooper (Advanced Bash Scripting Guide)
#With the Permission of Lee Bigelow
#Rewritten for opensuse 10.2 by Matthias Propst



#VARS
USER=$(whoami)
export LOGDIR="/var/log" #you may change this if you want to save information about broken-links in an other directory
export DATE=$(date +%c)
export LOGFILE="brokenlinks.report"
#VARS


###functions begin here
#checking for root
root_check ()
{
echo "Checking whether you have root privileges."
if [ $USER != "root" ]
then
echo "Not Root"
drop_failure
exit 1
else
drop_ok
fi
}

#if no arguments passed to the script 
#the current directory will be used.

[ $# -eq 0 ] && DIR=`pwd` || DIR=$@

#function linkchk 
linkchk () {

if [[ "$1" == "/boot" || "$1" == "/" ]] #this will skip the /boot and / dir
then
echo -e '\E[33m /boot and / will allways be skipped'
else

	echo $DATE >> "$LOGDIR/$LOGFILE"

	for element in $1/*
	do

	[[ -h "$element" && ! -e "$element" ]] && echo \"$element\" && echo \"$element\" >> "$LOGDIR/$LOGFILE"
	[ -d "$element" ] && linkchk $element
	#checks whether an element is a link and the link is not an exiting file. if this condition is true echoing the element and writing it to report file also. if the element was a directory call linkcheck for that directory 
	done

echo "There were no more broken links found :)" >> "$LOGDIR/$LOGFILE"

fi
}

drop_ok ()
{
echo -e '\t \t \t \t \E[32mok'; tput sgr0
}

drop_failure ()
{
echo -e '\t \t \t \t \E[31mfailure'; tput sgr0
}

###functions end here

root_check
for directory in $DIR
do
	if [ -d $directory ] #checks for every directory whether it exits
	then
	linkchk $directory
	else
	echo "$directory is not a valid directory"
	echo "Usage: `basename $0` dir1 dir2 ..."
	fi
done

echo "Information about possible broken links should be inspected in $LOGDIR/$LOGFILE if any."

unset LOGDIR DATE LOGFILE

echo -e '\t \t \t \t \E[32mdone'; tput sgr0

exit 0
