#!/bin/bash

#package_state

#this script is for backing up a current state of package
#it uses zypper for 11.3 but 11.2 may also work.
#all version using zypper < opensuse 11.2 are not tested
#suse verion 11.0 and below are not supported
CURRENT_PACK=$(zypper se  -t package -i |awk '{print $2 $3 $4}'|tail +6|tr '|' '"')
DATE_STRING=$(date +%F-%M)

option_s()
{
zypper cc #clean cache for older packages

i=0
for p in $CURRENT_PACK 
	do 
		
		packages[$i]=$p
		i=$(($i+1))
	done


printf "${packages[*]}"|xargs  zypper -n in -f -d -l 

mkdir rpms
find /var/cache/zypp/packages/ -type f -name "*rpm" -exec mv -v {} rpms/ \;

tar cvjf packages_$DATE_STRING.tar.bz2 rpms
rm -r rpms/
}

option_h()
{
echo "other option are not supported yet we are working"
echo "on it."	
}





#check whether you are root



while getopts s opt
	do
		case "$opt" in
			s) option_s
			;;
			\?) option_h
		esac
	done
shift `expr $OPTIND - 1`

		
		



#options for later implementation
#-s save package state and exit
#-n just do backup of rpms in /var/cache 
	#do not download them 
#-u first do an update than do the backup action
	#skip packagees that are allready in /var/cache
#-d show diff of two archives or of newstate and oldstate
