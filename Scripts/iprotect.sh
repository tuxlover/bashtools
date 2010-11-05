#!/bin/bash

#disable and enable icmp redirection
#enable kernel specific security options

STATUS=$1
#echo 0
FILES_D=(/proc/sys/net/ipv4/conf/all/accept_redirects /proc/sys/net/ipv4/conf/all/send_redirects /proc/sys/net/ipv6/conf/all/accept_redirects  /proc/sys/net/ipv6/conf/default/accept_redirects /proc/sys/net/ipv4/conf/default/accept_redirects /proc/sys/net/ipv4/tcp_timestamps)

#echo 1
FILES_E=(/proc/sys/kernel/core_uses_pid)


#test whether we have a non empty variable
if [ -z $STATUS	]
	then	
		echo "Usage: $0 on off status"
		exit 1
fi


status()
{


echo "Security mode is"

for f in ${FILES_D[@]}
	do
		if [ $(cat $f) == "0" ]
			then
				echo "$f" && echo -e "\E[32m  activated"; tput sgr0
			else
				echo "$f" && echo -e "\E[31m deactivated"; tput sgr0
		fi
	done	

for f in ${FILES_E[@]}
	do
		if [ $(cat $f) == "1" ]
			then
				echo "$f" && echo -e "\E[32m  activated"; tput sgr0			
			else
				echo "$f" && echo -e "\E[31m deactivated"; tput sgr0
		fi
	done
}	

on()
{

	
for f in ${FILES_D[@]}
	do
				echo "0" > $f
				echo "$f" && echo -e "\E[32m  activated"; tput sgr0
	done	

for f in ${FILES_E[@]}
	do
				echo "1" > $f
				echo "$f" && echo -e "\E[32m  activated"; tput sgr0
	done	

}

off()
{

	
for f in ${FILES_D[@]}
	do
				echo "1" > $f
				echo "$f" && echo -e "\E[31m  deactivated"; tput sgr0
	done		
	
for f in ${FILES_E[@]}
	do
				echo "0" > $f
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
