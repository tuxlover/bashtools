#!/bin/bash

DATE=$(date +%F)
LOGFILE="$HOME/.restore_$USR.log"
USR=$2
BACK=$1

#avoiding errors by using standard user and destination
${USR:=$USER} 2> /dev/null
${BACK:="/mnt/Backup/"} 2> /dev/null

if [ -d /proc/acpi/battery  ]
	then
		#we need to enable pipefail here because we test the exitstatus of grep 
		set -o pipefail
		HAS_POWER=$(grep -r charging /proc/acpi/battery/ | tail -1|cut -d: -f3 || echo "no")
		set +o pipefail

		if [ $HAS_POWER == 'discharging' ]
			then
				echo "It seems your computer uses battry as power source."
				echo "The Restore might fail to due empty battery"
				echo "connect your Computer to a power socket and rerun the script again"
				exit 1
		fi			

fi


if [ -f $LOGFILE ]
	then
	cat /dev/null > $LOGFILE
	else
	#fixing the exclude patterns
	#without this line the script is likely to fail
	touch $LOGFILE
fi

/usr/bin/rsync -rtpogv --delete -clis --exclude=*.vdi --exclude=.restore_*.log --log-file=$LOGFILE $BACK /home/$USR/
SUCCESS=$?

if [ $SUCCESS -ne 0 ]
	then
		echo -e "$USER \n your restore failed. rerun manually" | mail -s "restore failed on $DATE" $USER
	else
		echo -e "$USER \n your resote has finished. Details can be found in $LOGFILE" | mail -s "restore with rsync finished on $DATE" $USER 
fi


exit 0

#Todo: Test wheher mount point exists and has enough space
