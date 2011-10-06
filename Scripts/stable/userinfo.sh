#!/bin/bash

root_check ()
{
#checking whether we are root
	if [ $UID != "0" ]
		then
			echo "sorry not root"
			exit 1
	fi	

}

valid_users()
{
#look up valid users
ALL_USERS=$(cut -d: -f1 /etc/passwd|grep -v nobody)
#initialize counter
counter=0


	for u in ${ALL_USERS}
		do

			if [ $(id -u $u) -ge 1000 ]
				then
					HOME_DIR=$(grep $u /etc/passwd|cut -d: -f6 )	
					SPACE_USED=$( du -ms $HOME_DIR | awk '{print $1}' )
					SPACE_FREE_ON_DISK=$(df -m $HOME_DIR|tail -1|awk '{print $1}')   						
					PERCENT=$(( ( $SPACE_USED * 100 )  / $SPACE_FREE_ON_DISK))

					echo "----------------------------------------------------------------------"
					lastlog -u $u
					echo "$u :  $HOME_DIR : $SPACE_USED of $SPACE_FREE_ON_DISK ($PERCENT %)"

					counter=$(($counter + $PERCENT))
			fi 	


		done

	echo "----------------------------------------------------------------------" 
	echo "All Users taking  $counter % of Users available diskspace"

		if [ $counter -ge 1 ]
			then
				return 1
			else
				return 0
		fi
		
}

root_check 
valid_users 

if [ "$?" -eq "1"  ]
	then
		echo "$counter % disk space used"|mail -s "WARNING Users filling up the available disk space of the System" root@localhost

fi
