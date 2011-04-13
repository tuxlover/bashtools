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
CURRENT_PACK=$(rpm -qa --qf "\"%{name}-%{version}-%{release}\" \n" |grep -E -v "(gpg-pubkey|openSUSE-release).*$")


#creating the rpms directory which holds afeterwards all
#information of a package state and a descr and lists_all file
#set -x
mkdir rpms-${DATE}
read -e  -n 256 -p "give a Short Description of the package state:" DESCR
if [ ! -z "$DESCR" ]
	then
		echo "$DESCR" >> rpms/descr
fi	

#generating a real array 
#this takes some time here but saves a lot of time afterwards
i=0
for p in $CURRENT_PACK 
	do 
		packages[$i]=$p
		echo ${packages[$i]} >> rpms-${DATE}/lists_all 
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
		printf "${packages[*]}"|xargs  zypper --pkg-cache-dir rpms-${DATE}/ -n in -f -d -l -n  && break 
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
tar cvfz rpms-${DATE}.tar.gz rpms-${DATE}/

#cleaning up
rm -r rpms-${DATE}

if [ -f $CURRENT_DIR/.package_state.sh.swp ]
	then
		rm .package_state.sh.swp
fi

}

restore_state()
{
#first check wheter we have an tar.gz file
tar -tvfz $ARCHIVE rpms/descr && tar -tvfz $ARCHIVE rpms/lists_all && STATUS=0 || STATUS=1

if [ $STATUS -eq 1 ]
	then
			echo "descr or lists_all was not found in the archive"
			echo "Are you sure this is an valid backup archive of rpms."
	else
			echo "extracting Packages"
			#we need to examine the real name of the target archive
			TARGET=${ARCHIVE%.tar.gz}
			#create TARGET directory
			if [ ! -d $TARGET ]
				then
					mkdir $TARGET
			fi		
			
			tar xvfz $ARCHIVE -C $TARGET
			DESCR=$(cat $TARGET/descr)
			"echo Package Description: $DESCR"
			read -e -n 1 -p "Would you like to list the packages first" $ANSWER
			${ANSWER:="n"}
			
			if [ $ANSWER != "n" ]
				then
					clear
					cat $TARGET/lists_all
			fi
		#here we begin the restore action
		read -e -n 1 -p "Would you like to restore the installation with these packages" $ANSWER
		${ANSWER:="n"}
		#we retrieve the list of packages
		REST_PKG=$(cat $TARGET/lists_all)
		
		##this is the basic restore process
		mkdir rpms_${DATE}
		find $TARGET -type f -iname '*.rpm' -exec mv -v {} rpms_${DATE} \;
		zypper ar rpms_${DATE} restore
		zypper ref
		zypper -n in -n --from restore -f -l $REST_PKG
		
		#cleaning up
		zypper rr restore
		rm -rf rpms_${DATE}
fi



}

option_h()
{
echo "$0 -h -u -s"
echo "-s: save a packages sate"
echo "-u first do the update action than save the state of packages"
echo "-r <rpms.tar.gz> retore from a package archive"
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
while getopts hsur opt
	do
		case "$opt" in
			s) zypper cc && save_state
			;;
			u) zypper ref && zypper -n up && save_state
			;;
			r) if [ -z $1 ]
					then
							echo "provide a valid tar.gz file"
							we_fail
					else
						#giving the name is a good idea for tracedown 
						ARCHIVE=$1
						restore_state
				fi		
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
#verify whether we have enough space when unpacking the rpms.tar.gz
