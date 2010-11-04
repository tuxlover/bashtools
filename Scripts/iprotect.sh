#!/bin/bash

#disable and enable icmp redirection

STATUS=$1

#test whether we have a non empty variable
if [ -z $STATUS	]
	then	
		echo "Usage: $0 on off status"
		exit 1
fi


status()
{

FILES=(/proc/sys/net/ipv4/conf/all/accept_redirects /proc/sys/net/ipv4/conf/all/send_redirects /proc/sys/net/ipv6/conf/all/accept_redirects  /proc/sys/net/ipv6/conf/default/accept_redirects)

echo "Security mode is"

for f in ${FILES[@]}
	do
		if [ $(cat $f) == "0" ]
			then
				echo "$f" && echo -e "\E[32m  activated"; tput sgr0
			else
				echo "$f" && echo -e "\E[31m deactivated"; tput sgr0
		fi
	done	

}

on()
{
FILES=(/proc/sys/net/ipv4/conf/all/accept_redirects /proc/sys/net/ipv4/conf/all/send_redirects /proc/sys/net/ipv6/conf/all/accept_redirects /proc/sys/net/ipv6/conf/default/accept_redirects)

	
for f in ${FILES[@]}
	do
				echo "0" > $f
				echo "$f" && echo -e "\E[32m  activated"; tput sgr0
	done	
}

off()
{
FILES=(/proc/sys/net/ipv4/conf/all/accept_redirects /proc/sys/net/ipv4/conf/all/send_redirects /proc/sys/net/ipv6/conf/all/accept_redirects /proc/sys/net/ipv6/conf/default/accept_redirects)

	
for f in ${FILES[@]}
	do
				echo "1" > $f
				echo "$f" && echo -e "\E[31m  deactivated"; tput sgr0
	done		
	
}


#check whether we are root
#only if one of the words on or off is used
if [[ $STATUS == "on" || $STATUS == "off" ]]
	then
		if [ $UID -ne 0 ]
			then
				echo "not root"
				exit 1
		fi	
fi

case $STATUS in
	on) on
	;;
	off) off
	;;
	status) status
esac
