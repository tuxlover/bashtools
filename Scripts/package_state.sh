#!/bin/bash

#debug mode.
#set -x

#package_state

#this script is for backing up a current state of package
#it uses zypper for 11.3 but 11.2 may also work.
#all version using zypper < opensuse 11.2 are not tested
#suse verion 11.0 and below are not supported


 

#the date string is needed to verify package states by date
#and used for backup suffix indicating the time when backup was created
DATE_STRING=$(date +%F-%M)

CURRENT_DIR=$PWD

#here we start the action
save_state()
{
#we are wise and uisng rpms --qf option
#this will work faster
unset CURRENT_PACK
CURRENT_PACK=$(rpm -qa --qf "\"%{name}=%{version}-%{release}\" \n" |grep -E -v "(gpg-pubkey|openSUSE-release).*$")


#creating the rpms directory which holds afeterwards all
#information of a package state and a descr and lists_all file
#set -x
mkdir rpms-${DATE_STRING}
read -e  -n 256 -p "give a Short Description of the package state:" DESCR
if [ ! -z "$DESCR" ]
	then
		echo "$DESCR" >> rpms-${DATE_STRING}/descr
fi	

#generating a real array 
#this takes some time here but saves a lot of time afterwards
i=0
for p in $CURRENT_PACK 
	do 
		packages[$i]=$p
		echo ${packages[$i]} >> rpms-${DATE_STRING}/lists_all 
		i=$(($i+1))
	done
#set +x
#piping array to zypper install command
#-d is for download only
#-n skipps update process and chooses autobreak when getting in trouble
#-f does forece the installation remember we only download them
#-l autoagrees to licenses
check=0
until [ $check == "4"  ]
	do	
		echo "Cache maybe overloaded. Waiting 20 seconds"
		sleep 20                                                          
		printf "${packages[*]}"|xargs  zypper --pkg-cache-dir rpms-${DATE_STRING}/ -n in -f -d -l -n  && break 
		#sometimes the cache was not successfull so we trie it again
		#does'nt work so we should trie writing packages to a file
		check=$(( $check + 1  ))                                         
		echo "try again: $(( $check - 1)) / 3 tries ..."
	done

if [ $check == "4"  ]
	then
		echo "giving up"
		echo "This shit happens. we dont know why."
		echo "dont wory try again"
		exit 1
fi

#zip and package
tar cvfz rpms.tar.gz rpms-${DATE_STRING}/

#cleaning up
rm -r rpms-${DATE_STRING}/

if [ -f $CURRENT_DIR/.package_state.sh.swp ]
	then
		rm .package_state.sh.swp
fi

}

option_h()
{
echo "$0 -h -u -s"
echo "-s: save a packages sate"
echo "-u first do the update action than save the state of packages"
echo "Other options are not supporteed yet. we are working on it."	
}

we_fail()
{
echo -e '\t \t \t \t \E[31mfailed'; tput sgr0	
echo -e '\t \t \t \t \E[31mstop'; tput sgr0
exit 1
}


#check whether you are root
if [ $UID != "0" ]
	then
		echo "Only root can use zypper"
		we_fail
fi

#set +x
while getopts hsu opt
	do
		case "$opt" in
			s) zypper cc && save_state
			;;
			u) zypper ref && zypper -n up && save_state
			;;
			h) option_h
			;;
			\?) option_h
		esac
	done
shift `expr $OPTIND - 1`
#set +x
		
		

#Fixme: sometimes the script hangs up unfinished. it seems that the problem has soemthing todo how bash cashes big variabe ebntires
        # howto get arround that problem that tar does not pack in packages as we want it rather pack in var/cache... which might be a problem when restoring

#options for later implementation
#-n just do backup of rpms in /var/cache 
	#do not download them 
#-d show diff of two archives or of newstate and oldstate
#-r should restore a state of packages
#Todo: rather use wget than zypper for downloading packages to save runtime
#Todo: Save the packages list
#-b select a backup base directory
#improve speed by using tar on the fly 
# mkdir /rpm 
#mv description rpm/
