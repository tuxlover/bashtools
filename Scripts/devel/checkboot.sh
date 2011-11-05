#!/bin/bash

FILE=$HOME/boot


help_me()
{
echo "Script for creating and managing boot check files"
echo "-h: Show this help"
echo "-c: check files"
echo "-m: create m5sum check file"
echo "-s: create sha512 check file"
}

report_failed()
{
logger -f /var/log/messages -t checkboot -p local3.warn echo "$line did not match the checkfile"
}

md5_init()
{
	find -H /boot -type f -exec md5sum {} >> ${FILE}.md5 \;
	echo -e '\E[32m done'; tput sgr0
}


sha_init()
{
	find -H /boot -type f -exec sha512sum {} >> ${FILE}.sha \;
	echo -e '\E[32m done'; tput sgr0
}

check_sums()
{
if [ -f ${FILE}.md5  ]
	then
		#todo: 
		#need to check each line and break if error was reported
		for line in read ${FILE}.md5
			do
				md5sum -c --quiet $line || report_failed
			done
elif [ -f ${FILE}.sha  ]
	then
		#todo: need to check each line and break if error was reported
		for line in read ${FILE}.sha
			do
				sha512sum -c --quiet $line || report_failed
			done
else
	echo "no valid input file found"
	echo "use -m or -s to create one"
fi
}



#check root
if [ $UID -ne 0 ]
	then
		echo "not root"
		exit 1
fi

while getopts chms opt
	do
		case "$opt" in
			m) md5_init
				;;
			s) sha_init
				;;
			c) check_sums
				;;
			h) help_me
				;;
			\?) help_me
		esac
	done
shift $(($OPTIND - 1))

#todo: need rc script to start on boot
