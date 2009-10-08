#!/bin/bash

#gnome-do-start
#use this script if you want a gnome-do after compiz is launched

WAITATIME=10
SUC=1

#if compiz is not yet fully up and running wait 10 secs an try again
while [ $SUC -gt 0  ] 
	do	unset SUC
		sleep $WAITATIME
		ps -A|grep compiz		
		SUC=$?
	done

gnome-do

exit 0
