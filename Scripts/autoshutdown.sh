#!/bin/bash
#script which sets autoshutdown


#check whether we are root
JOBFILE="/root/.autoshutdown"
JOBNUMFILE="/root/.autoshutdown_num"
CRONTABFILE='/etc/cron.d/autoshutdown'
WARN=10
REASON=(The system will go down.)

check_root()
{
if [ $UID -ne 0  ]
	then
		echo -e '\E[31m not root'
		exit 1
	else
		return 0
fi
}

#check whether we have zenity installed
check_tools()
{
#check whether we have at running
service atd status|grep running &> /dev/null && HAS_AT="yes" || HAS_AT="no"
if [ $HAS_AT != "yes" ]
	then
		echo -e '\E[31m at daemon is not running'
		exit 1
fi

#check whether we have cron running
service cron status|grep running &> /dev/null && HAS_CRON="yes" || HAS_CRON="no"
if [ $HAS_CRON != "yes" ]
	then
		echo -e '\E[31m cron daemon is not running'
		exit 1
fi

return 0
}

set_shutdown()
{
TIME="$OPTARG"
check_time_format
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
#remove -k to make this real
echo "/sbin/shutdown -k $WARN \"${REASON[*]}\"" >> $JOBFILE

if [ ! -e $JOBNUMFILE ]
	then
		:> $JOBNUMFILE
		echo "$JOBNUMBER" > $JOBNUMFILE
	else
		echo "$JOBNUMBER" > $JOBNUMFILE
fi
		
#causes cron to read in the jobifile one minute after the actual time
#every day
if [ ! -e $CRONTAB ]
	then
		echo "SHELL=/bin/bash" >> $CRONTABFILE
		echo "$SETUP_MINUTE $NOW_HOUR * * * root $AT_BIN -f $JOBFILE $TIME; $AT_BIN -l| /usr/bin/tail -1|/usr/bin/cut -f1 > $JOBNUMFILE %" >> $CRONTABFILE
	else
		:> $CRONTABFILE
		echo "SHELL=/bin/bash" >> $CRONTABFILE
		echo "$SETUP_MINUTE $NOW_HOUR * * * root $AT_BIN -f $JOBFILE $TIME; $AT_BIN -l| /usr/bin/tail -1|/usr/bin/cut -f1 > $JOBNUMFILE %" >> $CRONTABFILE
fi
#this is just to test whether zenity works
zenity --display="$DISPLAY" --info --text="Autoshutdown has been set to $TIME" || :
}

clear_shutdown()
{
#first cancel the at job

if  [ ! -e $JOBFILE ]
	then
		echo "no shutdown job specified yet"
		exit 1
fi

if [ ! -e $JOBNUMFILE ]
	then
		rm $CRONTABFILE
		rm $JOBFILE

	else
	
		JOBNUMBER=$(cat $JOBNUMFILE)
		atrm $JOBNUMBER

		#then remove the cron.d file
		rm $CRONTABFILE
		rm $JOBFILE
		rm $JOBNUMFILE
fi
}

list_shutdown()
{
if [ ! -e $JOBNUMFILE ]
	then
		echo "no shutdown job specified yet"
		exit 1
fi
#get the hour dircetly from crontabfile to avoid waiting for crontab setting up the at job
tail -1 /etc/cron.d/autoshutdown |cut -d" " -f10|cut -d\; -f1
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


check_time_format()
{
if [ -z $TIME ]
		then
			echo "wrong timeformat. The timeformat has to be HH:MM"
			exit 1
fi	

if [ ${#TIME} -ne 5 ]
	then
		echo "wrong timeformat. The timeformat has to be HH:MM"
		exit 1
fi

#since we use the : as delimiter in awk we dont need to test for :
#since this will return an error
TIME_M=$(echo $TIME|awk -F: '{print $2}')
TIME_H=$(echo $TIME|awk -F: '{print $1}')



#check minutes
if [ -z $TIME_M ]
	then
		echo "wrong timeformat. The timeformat has to be HH:MM"
		exit 1
fi

if [[ 0 -le $TIME_M && $TIME_M -le 59  ]] 2> /dev/null
	then
		:
	else
		echo "wrong timeformat. The timeformat has to be HH:MM"
		exit 1
fi

#check hours
if [ -z $TIME_H ]
	then
		echo "wrong timeformat. The timeformat has to be HH:MM"
		exit 1
fi

if [[ 0 -le $TIME_H && $TIME_H -le 23 ]]
	then
		:
	else 
		echo "wrong timeformat The timeformat has to be HH:MM"
		exit 1
fi
return 0
}

##begin checks before reading options
check_root
check_tools

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
#in function set_shutdown check wheter we have a correct time format
#n function clear_shutdown find the correct at job
#check for zenity when implemented
#play a sound before shutdown
#implement a help function
#check for awk
#-w option works as follows
##check whether we have allready a job set if not ask user to use the -s option to setup a job
##check at job is alreasy set if not ...
##atrm $JOBNUMFILE
##rewrite the JOBFILE with the new $REASON
##at -f $JOBFILE && set new JOBNUMFILE

