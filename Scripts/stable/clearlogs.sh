#!/bin/bash

#clearlogs

#Comes with the package Bash-Tools
#Ideas collected by Mendel Cooper (Advanced Bash Scripting Guide)
#Rewritten for opensuse 10.2 by Matthias Propst

#To be run as root, of course.


#VARS
LOG_DIR=/var/log
LOGS="boot.log messages mysqld.log cups/access_log cups/error_log brokenlinks.report" #add more logfiles here you need to clean up.Be sure which logs you want to clean up and whether they are not needed by the running system. Remember that you have to write the additional logs as a relative path beginning from the LOG_DIR. Also you have to leave a space between each logfile you want to add.
LINES=10 #change this variable if you want more than the last 10 lines to be saved in /var/log/messages
#VARS

###functions begin here

#checking for root
root_check ()
{
echo "Checking whether you are root."

if [ $UID -ne 0  ]
then
echo "Not root"
drop_failure
exit 1
else
drop_ok
main
fi
}


#main function does what the script is for
main ()
{
	cd $LOG_DIR || {
	echo "Cannot change to directory" >&2
	exit 1
	}
	#logical operator causes the script to exit if direcctor LOG_DIR doesnot exits.

#I suggest to clean up the temporarily file as well and write the last $LINES back to the original logfile
#the loop is to easily add more than one logfile
echo "Cleaning up logs - please wait"

for logs in $LOGS
do
	if [ -f $LOG_DIR/$logs ] #asks for every log found in $LOG_DIR whether it should be cleaned or not
	then
	unset ANSWER
	ANSWER=n
	read -p "do you really want to clean up $LOG_DIR/$logs? (Press y to do so)" -n 1 -s ANSWER
		case "$ANSWER" in
		[y]) echo $logs
		touch $LOG_DIR/$logs.tmp
		tail -n $LINES $LOG_DIR/$logs > $LOG_DIR/$logs.tmp 2> /dev/null
		cat /dev/null > $LOG_DIR/$logs #Will overwrite the log with nothing. Not the same as message > /dev/null
		less $LOG_DIR/$logs.tmp > $LOG_DIR/$logs
		rm $LOG_DIR/$logs.tmp
		drop_ok
		;;
		*) echo -e '\t \t \t \t \E[33mskipped by user'; tput sgr0
		;;
		esac
	else
	echo "$logs does not exist"
	echo -e '\t \t \t \t \E[33mskipped'; tput sgr0 #skips nonexistend logfiles. You should revisit the LOGS variable
	fi
done

#This function will clean up all logfiles in the logusers dir created by the logusers script.
read -p "do you want to clean up the logusers dir completely as well (Press y to do so)" -n 1 -s ANSWER2
case $ANSWER2 in
[y])
	if [ -d $LOG_DIR/logusers ]
	then	
	cd $LOG_DIR/logusers
	chattr -a * #unlocks all scripts for changing in logusers dir
	rm *
	drop_ok
	fi
;;
*) echo -e '\t \t \t \t \E[33mskipped by user'; tput sgr0
;;
esac

echo "Logs cleaned up"

echo -e '\t \t \t \t \E[32mdone'; tput sgr0

exit 0
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

root_check && killall -1 rsyslogd

exit 0

