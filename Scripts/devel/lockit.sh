#!/bin/bash

#lockit

#Script that will lock the current running terminal
#and show various system information.
#Quits only after the q key was pressed and the correct password was entered.

#This Scipt does not provide a high security. If there are running other
#terminals or maybe other instances of tttys, the script can easyly be 
#stopped by using the kill command as this script does to shut down.

#Comes with the package Bash-Tools
#Ideas Collected by Mendel Cooper (Advanced Bash Scripting guide)
#written for opensue 10.2 by Matthias Propst


##VARS
SECS=5 #Change this variable if you want more time between the information.displayed
TIME=$(date +%c) #Change the format of the current date displayed.
CPU_NAME=$(cat /proc/cpuinfo|grep model\ \name)
CPU_FREQ=$(cat /proc/cpuinfo|grep cpu\ \MHz)
LINUX_VER=$(uname -r) #change this maybe with another option of uname to display 
SYS_UPTIME=$(uptime)
USER=$(whoami)
KEY_BREAK="false"
VERIFY_FAIL=110
MIN_LENG=4 #Change this variable if you want the user to enter passwords with more characters.
##VARS

#defining colors for funtion cecho later used in this script
black='\E[30m'; tput sgr0
red='\E[31m'; tput sgr0
green='\E[32m'; tput sgr0
yellow='\E[33m'; tput sgr0
blue='\E[34m'; tput sgr0
magenta='\E[35m'; tput sgr0
cyan='\E[36m'; tput sgr0

###funtions begin here

#Read password from stdin
enter_passwd ()
{
cecho "Enter a password to lock the screen:" $green
read -s PASSWORD
${PASSWORD:=a}
clear
cecho "Enter password again to verify:" $green
read -s PASSWORD2
chk_passwd
${PASSWORD2:=b}
}

#Check passwort integrity
chk_passwd ()
{
LENG=$(expr length $PASSWORD)

if [ "$PASSWORD" != "$PASSWORD2"  ] 2> /dev/null
then
clear
cecho "Password verification failed." $red
cecho "Please try again or press [Strg +[C] to stop now." $yellow
enter_passwd
else
	if [ "$LENG" -lt "$MIN_LENG" ]
	then
	clear
	cecho "password must at least have $MIN_LENG characters" $yellow
	enter_passwd
	fi
hold_loop
fi
}

#Verifies users password and exits if true
get_passwd ()
{
clear
unset PASSWORD2
PASSWORD2="-"
read -s -p "Enter password:" PASSWORD2
clear
 
if [ "$PASSWORD2" != "$PASSWORD" ]  
then
cecho "Wrong password, sorry" $red 
hold_loop
else
exit 0
fi
}

#Main routine showing system information
locked ()
{
history -c
fast_interrupt 
clear
echo $TIME
fast_interrupt
cecho "$MACHTYPE-$LINUX_VER scince $SYS_UPTIME" $magenta
fast_interrupt
cecho "\"$CPU_NAME\" running with $CPU_FREQ" $magenta
fast_interrupt
sleep $SECS
fast_interrupt
clear
fast_interrupt
df -h
fast_interrupt
echo "=========================================================================="
fast_interrupt
free -m
fast_interrupt
sleep $SECS
fast_interrupt
clear
fast_interrupt
cecho "Current running processes for \"$USER\":" $blue
fast_interrupt
#This will let the script show only the last 10 processes not invoked by this script
COUNTER=$(ps -A u | grep $USER | wc -l)
fast_interrupt
COUNTER2=$(($COUNTER - 4 ))
fast_interrupt
NUMBER_OF=$(($COUNTER - 14 ))
fast_interrupt
touch .info.lockit && chmod +w .info.lockit
ps -A u | grep $USER | head -$COUNTER2 >> .info.lockit
tail -10 .info.lockit
rm .info.lockit
fast_interrupt
echo "and $NUMBER_OF more processes"
#here ends the trick
fast_interrupt
sleep $SECS
fast_interrupt
}

#function to easyly clorizing output
cecho ()
{

local default_msg="No message passed"

message=${1:-$default_msg} #defaulto default message
color=${2:-$black}        #Defaults to black

echo -e "$color"
echo "$message"

return
}



#initial loop
hold_loop ()
{
while true
do
trap get_passwd 2 9 15 SIGTSTP
unset KEY_BREAK
read -t 1 -n 1 -s KEY_BREAK
${KEY_BREAK:="false"} 2> /dev/null

	case $KEY_BREAK in
	[q])get_passwd
	;;
	*)locked
	;;
	esac

done
}

#This allows fast quitting of this script by pressing the q key
fast_interrupt ()
{
unset KEY_BREAK #This ensures the script goes back into the hold_loop.
read -t 1 -n 1 -s KEY_BREAK
${KEY_BREAK:="false"} 2> /dev/null #This prevents the error message in if constructor.

if [ $KEY_BREAK == "q" ]
then
get_passwd
fi 
}

###functions end here

enter_passwd
exit 0