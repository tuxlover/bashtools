#!/bin/bash

DATE=$(date +%F)
DEST=$1
USR=$2
LOGFILE="$HOME/.backup_$USR.log"

if [ -d /proc/acpi/battery  ]
	then
		#we need to enable pipefail here because we test the exitstatus of grep 
		set -o pipefail
		HAS_POWER=$(grep -r charging /proc/acpi/battery/ | tail -1|cut -d: -f3 || echo "no")
		set +o pipefail

		if [ $HAS_POWER == 'discharging' ]
			then
				echo "It seems your computer uses battry as power source."
				echo "The Backup might fail to due empty battery"
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

/usr/bin/rsync -rtpogv --delete -clis --exclude=*.vdi --exclude=.backup_*.log --log-file=$LOGFILE /home/$USR/ /$DEST/home_$USR/
SUCCESS=$?

if [ $SUCCESS -ne 0 ]
	then
		echo -e "$USER \n your backup failed. rerun manually" | mail -s "weekly backup failed on $DATE" $USER
	else
		echo -e "$USER \n your backup has finished. Details can be found in $LOGFILE" | mail -s "weekly backup with rsync finished on $DATE" $USER 
fi


exit 0


