#!/bin/bash

#mksh: a simple script to make a file or directory shared 
#To avoid deleting your finest data unpurposly this script will create a group Shared, if not exist
#and then chowns directries to root:Shared and makes them 750 permissions. So users can execute and read 
#but not delete shared datas.

GROUP_SHARED=Shared
FILES=$1

check_root()
{
if [ $UID != "0" ]
then
	echo "not root"
	drop_failure
	exit 1
else 
	check_arg

fi	
	
}

check_arg() #checks whether script has an argument and is a regular file or directory
{

if  [ -z "$FILES" ] 
then
	drop_failure
	echo "No argunment"
	echo "Usage: $0 [DIR] [FILE]"
	exit 1
else
	if [ -f "$FILES" ]
	then
	check_group
	else
		if [ -d "$FILES" ]
		then
		check_group
		else
		drop_failure
		echo "file or directory does not exist"
		echo "Usage: $0 [DIR] [FILE]"
		exit 1
		fi
	fi
fi
}


check_group() #checks whether $GROUP_SHARED exists
{
EXISTS=$(grep $GROUP_SHARED /etc/group || echo "0")

echo "testing whether the group $GROUP_SHARED exists"

if [ $EXISTS != "0" ]
then
	echo -e '\E[32m'"ok";tput sgr0
	main
else
	echo  -e '\E[33m'"group does not exists. Should i create the group $GROUP_SHARED for you"; tput sgr0
	echo  -e '\E[33m'"you cannnot continue without doing this. But maybe you want to setup"; tput sgr0
	echo -e '\E[33m'"an other groupname by hand"; tput sgr0
	${ANSWER="n"} 2> /dev/null
	read -n 1 -p "(y)es / (n)o" ANSWER
		
		case $ANSWER in
		y) groupadd $GROUP_SHARED
			;;
		n) exit_script
			;;
		*) clear
		   echo "enter (y)es or (no)"
			;;
		esac
	main
fi
}

main ()
{
chown -R root:$GROUP_SHARED	"$FILES"
chmod -R 750 "$FILES"
echo -e '\E[32m'"done";tput sgr0
}	

drop_failure ()
{
echo -e '\t \t \t \t \E[31mfailure'; tput sgr0
}

drop_ok ()
{
echo -e '\t \t \t \t \E[32mok'; tput sgr0
}

exit_script()
{
exit 1
}


check_root

exit 0


#mksh should only work for /home and /media
