#!/bin/bash

#pinger

#Script that will check internet-connections by sending a permanent ping signal until it gets a reply
#beeps if this is true

#Comes with the package Bash-Tools
#Ideas Collected by Mendel Cooper (Advanced Bash Scripting guide)
#written for opensue 10.3 by Matthias Propst

##VARS
declare -i BREAK_AFTER=3 #How often the script should try to ping 
SECS=30 #Change this if you want more or less than 30 seconds interval probe pinging 
#PINGHOST=127.0.0.1 #Can be used to test the script
PINGHOST=$1 #Here you should enter a valid adress for pinging
${PINGHOST:=google.de} #Here you should enter a valid adress for pinging
##VARS

text_info ()
{
echo "found connection" && FOUND_CONNECTION=yes

  until [ $FOUND_CONNECTION != "yes" ] #Beeps until user stops script by pressing crtl+c
  do
  echo "found connection"
  echo -e "\a \a"
  sleep 2
  done
}

graphical_info ()
{
zenity --info --text="found connection" 2> /dev/null || Xdialog --msgbox "found connection" 10 30 2> /dev/null
}

i=0

ping -w 1 $1 2> /dev/null || ping -w 1 $PINGHOST 2> /dev/null
while [ $? -gt "0" ]
do

((i+=1))

echo "no connection "

  if [ "$BREAK_AFTER" == "$i"  ]
  then 	
  #possible dialog commands Xdialog, dialog,kdialog; gdialog; zenity
  zenity --warning --text="No connection found."  2> /dev/null || Xdialog --msgbox "No connection found" 10 30 2> /dev/null || echo  -e '\E[31mNo connection found.'; tput sgr0
  exit 0
  fi

sleep  $SECS #wait for next Ping $SECS seconds
ping -w 1 $1 2> /dev/null || ping -w 1 $PINGHOST 2> /dev/null

done
#Can i build this in a condition construct?

graphical_info || text_info


 exit 0

# Todo: 
# implement a help option
# Fixme:
# ping command does not send an exit status greater > 0 but function should return 1 if running was unseccessfull
