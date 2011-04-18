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
#check if we use repos local
if [ ${REPOS_LOCAL} != "yes" ]
	then
##do the action
#create an alternative zypp.conf
cat > zypp.conf << __EOF__
[main]
download.max_silent_tries = 0
__EOF__

until [ $check == "4"  ]
	do	
		printf "${packages[*]}"|xargs  zypper --pkg-cache-dir rpms-${DATE_STRING}/ -c zypp.conf -n in -f -d -l -n  && break 
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
	else
##do the action local
until [ $check == "4"  ]
	do	
		printf "${packages[*]}"|xargs  zypper --pkg-cache-dir rpms-${DATE_STRING}/ --no-remote  -n in -f -d -l -n  && break 
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
		
fi		
#zip and package
tar cvfz rpms-${DATE_STRING}.tar.gz rpms-${DATE_STRING}/

#cleaning up
rm -r rpms-${DATE_STRING}/

if [ -f $CURRENT_DIR/.package_state.sh.swp ]
	then
		rm .package_state.sh.swp
fi

if [ -f $CURRENT_DIR/zypp.conf ]
	then
		rm zypp.conf
fi

}

restore_state()
{
#first check wheter we have an tar.gz file
#we need the --wildcards option because we know that each package should match this
tar -tvz --wildcards -f $ARCHIVE rpms-*/descr && tar -tvz --wildcards -f $ARCHIVE rpms-*/lists_all && STATUS=0 || STATUS=1

if [ $STATUS -eq 1 ]
	then
			echo "descr or lists_all was not found in the archive"
			echo "Are you sure this is an valid backup archive of rpms."
	else
			echo "extracting Packages"
			#we need to examine the real name of the target archive
			TARGET=${ARCHIVE%.tar.gz}
			#create TARGET directory			
			tar xvfz $ARCHIVE 
			clear
			echo "Package Description:"
			echo "$(cat $TARGET/descr)"
			read -e -n 1 -p "Would you like to list the packages first" $ANSWER
			${ANSWER:="n"}
			
			if [ $ANSWER != "n" ]
				then
					clear
					cat $TARGET/lists_all|more

			fi
		#here we begin the restore action
		read -e -n 1 -p "Would you like to restore the installation with these packages" $ANSWER
		${ANSWER:="n"}
		#we retrieve the list of packages
		REST_PKG=$(cat $TARGET/lists_all|sed 's/"//g')
		
		##this is the basic restore process
		mkdir rpms
		find $TARGET -type f -iname '*.rpm' -exec mv -v {} rpms/ \;
		zypper ar rpms restore
		zypper ref
		#-D is for testing remove this later
		zypper -n in -n -f -l -r restore $REST_PKG
		
		#cleaning up
		zypper rr restore
		rm -rf rpms
		rm -rf $TARGET
fi
}

option_h()
{
echo "$0 -h -u -s-l|-r"
echo "-s: save a packages sate"
echo "-l: save from a local repository"
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
while getopts hsurl opt
	do
		case "$opt" in
			s) 	export REPOS_LOCAL="no"
				zypper cc && save_state
			;;
			u) zypper ref && zypper -n up && save_state
			;;
			r) if [ -z $1 ]
					then
							echo "provide a valid tar.gz file"
							we_fail
					else
						#giving the name is a good idea for tracedown 
						ARCHIVE=$2
						restore_state
				fi		
			;;
			l) export REPOS_LOCAL="yes"
			;;	
			h) option_h
			;;
			\?) option_h
		esac
	done
shift `expr $OPTIND - 1`
#set +x
		
		

#Fixme: sometimes the script hangs up unfinished. it seems that the problem has soemthing todo how bash cashes big variabe entries
#options for later implementation
#-n just do backup of rpms in /var/cache 
	#do not download them 
	#prevent empty archive by do a check whether there are any rpms in /var/cache
#-d show diff of two archives or of newstate and oldstate
#-f resore only a single package <tar.gz> <package> with all its dependencies
#verify whether we have enough space when unpacking the rpms.tar.gz
#userproof the script
#clean up the code
#verify packages after download
