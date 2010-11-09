#!/bin/bash

TEST=$1
TEST2=$(echo $TEST|awk -F '/' '{print $2}')

#check whether we have /home or /mnt or /media

#check whether we begin with /
if [ ${TEST:0:1} == "/" ]
	then
		echo "ok"
	else
		echo "must begin with absolute path /"
fi


if [[ $TEST2 == "home" || $TEST2 == "media" || $TEST2 == "mnt" ]]
	then
		echo "ok"
	else
		echo "not ok"
fi
