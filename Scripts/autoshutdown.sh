#!/bin/bash
#script which sets autoshutdown


#check whether we are root
JOBFILE="/root/.autoshutdown"
JOBNUMFILE="/root/.autoshutdown_num"
CRONTABFILE='/etc/cron.d/autoshutdown'
WARN=10
REASON="The system will go down."

check_root()
{
if [ $UID -ne 0  ]
	then
		echo -e '\E[31m not root'
		return 1
	else
		return 0
fi
}

#check whether we have zenity installed
check_tools()
{
zenity --version &> /dev/null && HAS_ZENITY="yes" || HAS_ZENITY="no"
if [ $HAS_ZENITY != "yes" ]
	then
		echo -e '\E[31m zenity not installed'
		return 1
	else
		return 0
fi


#check whether we have at installed
at -V &> /dev/null && HAS_AT="yes" || HAS_AT="no"
if [ $HAS_AT != "yes" ]
	then
		echo -e '\E[31m at not installed'
		return 1
	else
		return 0
fi
}

set_shutdown()
{
TIME="$OPTARG"
#for corntab setup we need the absolut path to at
AT_BIN=$(which at)

#set up the hour when to setup the at job in the cron job
NOW_HOUR=$(date +%H)
SETUP_MINUTE=$(($(date +%M) +1 ))
if [ $SETUP_MINUTE -eq 59 ]
	then
		SETUP_MINUTE=0
		
		if  [ $NOW_HOUR -eq 23 ]
			then
				NOW_HOUR=0
			else
				NOW_HOUR=$(( NOW_HOUR +1 ))
		fi
fi

#setup at file
echo "\"echo "$REASON"\"|wall" >> $JOBFILE
echo "shutdown -h $WARN" >> $JOBFILE

#setup autoshutdown
JOBNUMBER=$(atq|tail -1|cut -f1) 
echo "$JOBNUMBER" > $JOBNUMFILE

#causes cron to read in the jobifile one minute the number was given
#every day
echo "$SETUP_MINUTE $NOW_HOUR * * * $AT_BIN -f $JOBFILE $TIME %" > $CRONTABFILE
}

clear_shutdown()
{
#first cancel the at job

if  [ ! -e $JOBNUMFILE ]
	then
		echo "no shutdown job specified yet"
		exit 1
fi
JOBNUMBER=$(cat $JOBNUMFILE)
atrm $JOBNUMBER

#then remove the cron.d file
rm $CRONTABFILE
rm $JOBFILE
rm $JOBNUMFILE
}

list_shutdown()
{
if [ ! -e $JOBNUMFILE ]
	then
		echo "no shutdown job specified yet"
		exit 1
fi
JOBNUMBER=$(cat $JOBNUMFILE)
atq $JOBNUMBER
}


set_freq()
{

echo "not implemented yet"
echo "it doesnt matter if you say $OPTARG to this option"
}


set_warn()
{
echo "not implemented yet"
echo "it doesnt matter if you say $OPTARG to this option"
}

set_warn_time()
{
echo "not implemented yet"
echo "it doesn matter if you say $OPTARG to this option"
}




##begin checks before reading options
check_root && check_tools || exit 1

#begin options
while getopts cls:f:w:m: opt
	do
		case "$opt" in
			c) clear_shutdown
			;;
			l) list_shutdown
			;;
			s) set_shutdown
			;;
			f) set_freq
			;;
			w) set_warn
			;;
			m) set_warn_time
			
		esac
	done
shift $(($OPTIND - 1 ))

exit 0
#todo:
#rewrite the script and use at instead of cron
#set and manage autoshutdown
#echo -c clear existing autoshutdown
#echo -s set TIME in HH:MM when to shutdown
#echo -f set ask frequence when press cancel ask again after n minutes
#echo -w sets warning message: what should be printed vi zenity before shutdown
#echo -m sets warning in N minutes before shutdown
#echo -l lists the specific shutdown job
#Hint:
	#zenity --info --text="I will ask again in $TIME_STEP minutes."
#timer|zenity --progress --percentage=100 --auto-close --text="Computer is going to shutdown in counter Seconds"  --display $DISPLAY && shut_me_down || ask_again

#timer()
#{
#while [ $counter -ne 0 ]
#	do
#		sleep 1
#		echo $counter
#		counter=$(($counter-1))
# 	done
#}
#in function set_shutdown check wheter we have a correct time format
#n function clear_shutdown find the correct at job
#check whehter the atd and crond are runnign rather for checking for the existince
