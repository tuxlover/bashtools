#!/bin/bash

DATE=$(date +%F)
LOGFILE="$HOME/.restore_$USR.log"
USR=$2
BACK=$1


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


