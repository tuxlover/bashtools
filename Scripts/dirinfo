#show stats

#gives usefull informatiom about current directory

#what information?

#size and information
#the filesystem it is mounted on
# the used space
# the file with the biggest size in directory
# hidden files
# die datei die zuletzt berührt wurde
# die datei die zuletzt berbeitet wurde
# falls datei ausführbare rechte hat, die datei die zuletzt 
#-u USER alle datein die dem benutzer USER gehören
#-g GROUP der Gruppe gehören
# die relative größe zur datei gesmatgröße
# die anzahl der dateien


if [ -z $LOGFILE ]
then
LOGFILE="/var/log/cleancheck.log"
touch /var/log/cleancheck.log
else
unset LOGDIR
LOGDIR=$(echo ${LOGFILE%/*} )
	if [ ! -d $LOGDIR ]
	then
	mkdir -p $LOGDIR
	fi
fi
