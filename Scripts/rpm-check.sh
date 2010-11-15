#!/bin/bash

#rpm-check

#Queries an uninstalled rpm for descripton, listing
#and whether it can be installed.
#it also tries to find the rpm in the zypper database
#Saves the output to a logfile which can be inspected afterwards.
#For installed ones use the rpm command.
#Note that this script only works for rpm-based distributions

#Comes with the package Bash-Tools
#Version 2 of formaly rpm_check
#written for opensuse >= 11.2 by Matthias Propst

RPMS=$1
REPORTFILE=$2

#check at least RPMS is not an empty variable
#if REPORTFILE is not givenm use "report_lost_packages"
check_params()
{

${REPORTFILE:="$HOME/report_lost_packages-$(date +%F-%M)"} 2> /dev/null


if [ -z $RPMS ]
	then
		echo "$0: report Status of rpms not part of an zypper archive"
		echo "Usage: $0 Directory [Reportfile]"
		return 1
	else
		return 0
fi

}

main()
{
#to use the vartibale RPMS in the next subshll we have to export them
export RPMS
	
	{
	NAMES=$(find $RPMS -type f -name "*.rpm"|sort)
	if [ $UID == "0"  ]
		then
			echo "copying files to temporary archive"
			mkdir /root/tmp_archive
			
			for n in ${NAMES[@]}
			do
				cp $n /root/tmp_archive/
			done
			
			echo "done"
			echo "adding tmp_archive to zypper archive"
			zypper ar -f /root/tmp_archive tmp
			zypper ref
			NAMES_i=$(zypper se -r tmp -s|tail +6|awk -F\| '{print $2}')
			
			#creating the array such as the nth Element in the Array corresponds to one package name
			k=0 
			for i in ${NAMES_i[@]}
			do 
				NAMES_k[$k]=$i 
				k=$((k+1))
			done
			
			STATUS=0
		else
			echo "without checking whether packages can be installed"
			echo "you might trie running this script as root to test this"
			printf "\n \n"
			STATUS=1
	fi
						
	#initilize a counter 
	l=0
	for i in ${NAMES[@]}
	do

		#test if input file is really an rpm
		#if not skip this iteration
		if  [ $(od $i |head -1 |awk '{print $2}') != "125755" ]
			then
				$i is not an rpm
				#we have iterate here to keep the structure intact and not to leave a step behind
			        #however this is a rare execption and should never appear	
				l=$((l+1))
				continue
		fi

		rpm -qpi $i 2> /dev/null
		
		if [ $STATUS == "0" ]
		then
			zypper -n -q mr -d tmp 
			zypper -q ref &> /dev/null
			zypper -n se -s $i 
			zypper -n -q mr -e tmp 
			zypper -q ref
			
			#Test the package whether it can be installed
			#increment number to one
			zypper -n -q in -D -l -r tmp ${NAMES_k[$l]} &> /dev/null && echo "${NAMES_k[$l]} can be installed" || echo "${NAMES_k[$l]} can not be installed"
			l=$(($l+1))

		else
			#Fixmne: This Part is broken
			zypper -n se -s $i_
		fi
				
		printf "\n \n"
	
	done
	

	if [ $STATUS == "0" ]
		then
			echo "cleaning up temporarly Repository"
			zypper -q rr tmp
			rm -r /root/tmp_archive
			zypper -q ref
	fi		
	} |tee -a $REPORTFILE

unset RPMS
}



check_params || exit 1
main && killall rpm 2> /dev/null

exit 0
	


#Todo
#Option -l with package listing
#Option -r report only packages which cannot be installed
#reduces runtime and file inspected afterwarts
#imporve runtime
#reduce data overhead

#Fixme 
#fix the broken part
