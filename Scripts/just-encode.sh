#!/bin/bash


OLDNAME=$1

read -p "please  give the new name" $NAME
${NAME:=test.}


mencoder -oac mp3lame -ovc lavc $1.mov -o $NAME.avi

exit 0
