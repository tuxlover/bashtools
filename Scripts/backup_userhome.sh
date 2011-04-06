#!/bin/bash

DATE=$(date +%F)
DEST=$1
USR=$2
LOGFILE="$HOME/.backup_$USR.log"

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


