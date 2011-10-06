#!/bin/bash
#This Startscript enhances the security by disabling icmp redirection and enabling kernel specific security options
### BEGIN INIT INFO
# Provides: 		iprotect
# Required-Start: 	$auditstart $network 
# Required-Stop: 	$auditstart $newtork
# Should-Start:		$fakemac
# Should-Stop:		$fakemac
# Default-Start:	3 5
# Default-Stop:		0 6
# Short-Description:	Script to enhance Security by modifying specific /proc files
# Description:		writing specific values into the procfilesystem
### END INIT INFO


STATUS=$1
#echo 0
FILES_D=(net.ipv4.conf.all.accept_redirects net.ipv4.conf.all.send_redirects net.ipv6.conf.all.accept_redirects  net.ipv6.conf.default.accept_redirects net.ipv4.conf.default.accept_redirects net.ipv4.tcp_timestamps)

#echo 1
FILES_E=(kernel.core_uses_pid)

state()
{


echo "Security mode is"

for f in ${FILES_D[@]}
	do
		if [ $(sysctl -n $f) == "0" ]
			then
				echo "$f" && echo -e "\E[32m  activated"; tput sgr0
			else
				echo "$f" && echo -e "\E[31m deactivated"; tput sgr0
		fi
	done	

for f in ${FILES_E[@]}
	do
		if [ $(sysctl -n $f) == "1" ]
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
				sysctl -w $f=0
				echo "$f" && echo -e "\E[32m  activated"; tput sgr0
	done	

for f in ${FILES_E[@]}
	do
				sysctl -w $f=1
				echo "$f" && echo -e "\E[32m  activated"; tput sgr0
	done	

}

off()
{

	
for f in ${FILES_D[@]}
	do
				sysctl -w $f=1
				echo "$f" && echo -e "\E[31m  deactivated"; tput sgr0
	done		
	
for f in ${FILES_E[@]}
	do
				sysctl -w $f=0
				echo "$f" && echo -e "\E[31m  deactivated"; tput sgr0
	done	


}



case $1 in
	"start") on
	;;
	"stop") off
	;;
	"restart") 
		off 
		slepp 1 && echo "1" && sleep 1 && echo "2" && sleep 1 && echo "3"; on
	;;
	"status") state
	;;
	*) echo "I dont understand $1. Usage: $0  [start] [stop] [restart] [status]" && exit 1
esac
