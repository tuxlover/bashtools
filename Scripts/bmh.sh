#!/bin/bash
#bmh

#bmh: backup my home is a simple backup utility for backing up a users
#home directory.
#it uses rsync, notify-send and zenity.

#it rsyncs between two directories usinng rsync after finished the backup is tar bziped2 to save diskspace
#call bmh $1=Sourcedir $2=Destdir $3=EXCLUDE (optional)

##VARS
SOURCE_DIR=$HOME #which directory should be a backup taken from
DEST_DIR=$1 #the destination where to save
EXCLUDE_FILE=$2 #use a seperate list of exclude patterns saved in a file
#These Vars should be edited. e.g. when you want to run this as cron-job and have more than one
##VARS

check_rsync()
{
HAS_RSYNC=$(which rsync || echo "no")

if [ "$HAS_RSYNC" == "no" ]
	then
		echo -e '\E[31mCould not find rsync'; tput sgr0
		echo "__________________________"
		echo "rsync: $HAS_RSYNC"
		echo "Rsync is needed. Please install it."
		echo "__________________________"
		exit 1
	else
		echo "__________________________"
		echo -e '\E[32mrsync:yes'; tput sgr0
		echo "__________________________"
		sleep 2 #for better human readability
		check_notification
fi
}

#checks whether tools are set to inform the user
#if not, the user will be warned and then the action is performed
check_notification()
{
HAS_NOTIFY=$(which notify-send || echo "no") #using which to test presence
HAS_ZENITY=$(which zenity || echo "no")

if [[ "$HAS_ZENITY" == "no" || "$HAS_NOTIFY" == "no" ]]
	then
		echo -e '\E[33mYou are unable to use notification'; tput sgr0
		echo "___________________________"
		echo "notify-send: $HAS_NOTIFY"
		echo "zenity: $HAS_ZENITY"
		echo "___________________________"
		NOTIFY_USER="no"
	else
		echo "___________________________"
		echo -e '\E[32m notify-send: yes';tput sgr0
		echo -e '\E[32m zenity: yes';tput sgr0
		echo "____________________________"
		sleep 2 #for better human readability
		NOTIFY_USER="yes"
fi

unset HAS_NOTIFY #might not be neccessary and will removed later
unset HAS_ZENITY #might not be neccessary and will removed later

main 
}

main()
{
I=(1 2 3 4 5 6 7 8)
if [ $NOTIFY_USER == "yes" ]
	then
		echo "take some action with notification"
		notify-send "A backup is in progresss"
		zenity --notification --text "backup in progress" >3& 
		#the >3& redirection puts the output to panel and lets the script work without interruption
			
			#the whole function is only for testing purposes 
			for i in ${I[@]}
			do
				sleep 2 
				echo $i 
			done
		notify-send "The backup is now finished"
		rm 3
		#the whole function is only for testing purposes
	else
		echo "take some action without notification"
fi
}

check_rsync




exit 0

#test whether requirements for script are met
#scince we want to use tar and bz2 we should testing for this requirements too
#we just need $1 $2 (optional)

#zenity should send a notification-icon during process and notify-send shoud send a notifcation when backup has finished and
#when its stopped
#scince this is an user-level programm it should be testeted wheter there are access to the destination-dir
#remove old archive first
#we need to arguments so we need to schift twice
#check wehther destdir exists by 
#help option
#we need a cron option -q (quiete) to have less verbosity 
# how to kill zenity automaticly after script finished ?
