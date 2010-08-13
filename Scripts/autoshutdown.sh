#!/bin/bash

#autoshutdown

#rev25102009

#small script that manages autoshutdowns hourly
#it will print a warn message and a timer. the user can cancel the action
#when he needs to work. otherwise the script causes the shutdown of the computer.

#most parts of the script do work
#however there is an issue with the beep which does not work yet 

#the second problem that the gui is not forced to go on front if for example
#watching a video. i currently working on a method to stop xine or whatever plays the movie
#to focus users intention.

#however there is a smaller c++ solution for that but this is however not bashish and runs only
#on opensuse 11.0 and properly above.

#you must have installed zenity. i do not want this and hope i there is a better an easyier method
#to do this. furthermore you need a cron setup propertly and a /etc/cron.d/ directory.
# if you have however an other directory you have to setup this by editing this manualy.


##variables
########################################################################
NIGHT_TIME=2 #by default 2 nighttime. This Variable holds the time in hours (24) for the first ask
TIME_STEP=30 #if the User is still working ask again in Miutes
DAY_TIME=8 #by default 8 daytime. This Variable holds the time the computer never asked to shutdown
counter=30 #the counter function. The time the user has to stop shutdown process
##variables
########################################################################

#Script needs root privilegues

########################################################################
##options

option_h() #a short help option starts here
{
	echo "set and manage autoshutdowns"
	echo "Usage $0 [-d TIME -n TIME -f VALUE] [-c] "
	echo "-c clear existing autoshutdown"
	echo "-d set daytime"
	echo "-n set nightime"
	echo "-f set ask frequence. when press cancel ask again after n minutes where n can be any integer value greater 1"
	echo "-s shows the /ect/cron.d/autoshutdown"
	echo "Script will not shutdown the computer inbetween the intervall daytime to nighttime"
	exit 0
}


option_c()
{
if [ -f /etc/cron.d/autoshutdown ] 
	then
		rm /etc/cron.d/autoshutdown
		exit 0
	else
		exit 0
	fi
}


option_d() #set daytime in hours
{
DAY_TIME=$OPTARG


if [ $DAY_TIME -le 23 ]
#scince comparsion is only usefull for integer this insures that $DAY_TIME
#is an integer value in the range of 0 to 23.
#apperently it didnt work if you use logical operator so we need a nested if.
	then
		if [ $DAY_TIME -ge 0 ]
			then
				:
			else
				echo "-d not an vaild argument"
				echo "argument must be an integer value between 0 and 23"
			exit 1
		fi
	else
		echo "-d not an vaild argument"
		echo "argument must be an integer value between 0 and 23"
		exit 1
fi
}

option_f()
{
TIME_STEP=$OPTARG

#testing for integer needs only an integer comparsion
#scince this can not be done on other datatypes
#test result has exit status greater than 0 and 
#therefore executes the body after else statement
if [ $TIME_STEP -gt 0  ]
	then
		:
	else
		echo "-f not an valid argument"
		echo "argument must be an integer value greater than 0"
		exit 1
fi

}

option_n() #set nighttime in hours
{
NIGHT_TIME=$OPTARG


if [ $NIGHT_TIME -le 23 ]
#scince comparsion is only usefull for integer this insures $NIGHT_TIME
#is an integer value in the range of 0 to 23
#apperently it didnet work with logical operators so we need a nested if.
	then
		if [ $NIGHT_TIME -ge 0 ]
			then
				:
			else
				echo "-n not an vaild argument"
				echo "argument must be an integer value between 0 and 23"
			exit 1
		fi
	else
		echo "-n not an vaild argument"
		echo "argument must be an integer value between 0 and 23"
		exit 1
fi
}

option_s()
{
cat /etc/cron.d/autoshutdown	
exit 0
}

while getopts d:f:n:hcs opt
	do
		case "$opt" in
			c) option_c
			;;
			d) option_d
			;;
			f) option_f
			;;
			n) option_n
			;;
			s) option_s
			;;
			h) option_h
			;;
			\?) option_h
		esac
	done
shift `expr $OPTIND - 1`

##options
########################################################################

#simple function that checks for root priveleques
check_root()
{
if [ $UID -ne 0 ]
	then
		echo "need root priveleques"
		exit 1
	else
		check_unequal
		fi
}

#check whether DAY_TIME is unequal NIGHT_TIME 
check_unequal()
{
	if [ $DAY_TIME -eq $NIGHT_TIME ]
		then
			echo "-n -d wrong arguments"
			echo "daytime and nightime must differ."
			exit 1
		else
			check_zenity
	fi
}

#this function checks whether zenity is present
check_zenity()
{
has_zenity=$(zenity --version || echo "1")

	if [ "$has_zenity" == "1" ]
		then
			echo "zenity not found."
			echo "without zenity this script will not work."
			echo "install zenity."
			exit 1
		else
			main
	fi
}

#timer counts backwarts and piped through zenity progressbar
timer()
{
while [ $counter -ne 0 ]
	do
		sleep 1
		echo $counter
		counter=$(($counter-1))
 	done
}

#this does the actual shutdown
shut_me_down()
{
rm /etc/cron.d/autoshutdown #remove from cronjoblist otherwise after restart the machine simply shuts down
shutdown -h -k now I shutdown #the -k option is for testing purposes
}

zenity_call()
{
#This function stops the asking for shutdown if it is daytime
NOW_TIME=$(date +%k)

	if [ $DAY_TIME -lt $NIGHT_TIME ] #(DT < NT)
		then
			if [[ $DAY_TIME -lt $NOW_TIME && $NOW_TIME -lt $NIGHT_TIME ]]
			#intervall in which the computer never shuts down
				then
					zenity --info --text="Your configuration has been saved"
					exit 0
				else
					echo -en "\007"
					timer|zenity --progress --percentage=100 --auto-close --text="Computer is going to shutdown in counter Seconds" --display $DISPLAY && shut_me_down || ask_again
			fi
		else #(NT < DT)
			if [[ $NIGHT_TIME -le $NOW_TIME && $NOW_TIME -lt $DAY_TIME ]]
				then
					echo -en "\007"
					timer|zenity --progress --percentage=100 --auto-close --text="Computer is going to shutdown in counter Seconds"  --display $DISPLAY && shut_me_down || ask_again
				else
					zenity --info --text="Your configuration has been saved"
					exit 0
			fi
	fi
}

ask_again()
{
	zenity --info --text="I will ask again in $TIME_STEP minutes."
	WAIT_TIME=$(($TIME_STEP*60))
	sleep $WAIT_TIME
	main
}


main()
{
#create a cronjob in /ect/cron.d/
if [ -f /etc/cron.d/autoshutdown ] #check if /etc/cron.d/autoshutdown is present
		then
			echo "warning: a cronjob for autoshutdown allready exist"
			echo "use $0 -c to clear an existing autoshutdown before creating a new one"
			zenity_call
		else
			echo "#please use the autoshutdown script to manage autoshutdown" >> /etc/cron.d/autoshutdown
			echo "1 $NIGHT_TIME * * *	$0 -d $DAY_TIME -n $NIGHT_TIME" >> /etc/cron.d/autoshutdown
			zenity_call
		fi
}

check_root

exit 0

#todo:
#must be allways ontop to not shutdown the computer eg while watching a movie
#allert user through sound
#let cronpath be a variable that holds the path to where cron check for jobs
# let there be an option -p for setting up path to correct cron.
#how to check correct cronpath
#this might howver be complecated because we have to check wheter there are really cronjobs saved
#shutdown.allow is not implemented yet: it yould work like this with the -a option a privileged user can be
#added however you must have root privelegs to that
#this needs also a new way of looking up a privileged user. check_root will no more satisfie this
#use gtk --display and send  message to all logged on users to all users using who -m to find out who has a actual display
