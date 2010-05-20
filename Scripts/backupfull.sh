#!/bin/bash

#this is the version for opensuse
#get it working for debianlike systems would take a while

##determine which distro is used system is used
if [ -f /etc/debianversion ]
then
set DISTRO=deb
elif [ -f  /etc/SuSE_release ]
set DISTRO=suse
else
echo "Your Distribution is not supported yet."
fi


case $1 in 
ba) backup
;;
re) restore
;;
ma) manage
;;
esac

###
backup()
{
	if [ ! -d .back ] #testing initial start
	then 
	mkdir -p .back
	fi ##todo create and manage here files parsing contains information about times and users to backup
	
	
	#get and collect information about installed packages and used repos
	zypper ar -e $REPO_LIST && zypper lp -e $PACKAGE_LIST xargs | tar cvfz packages.info.tar.gz
	rm $REPO_LIST $PACKAGE_LIST
	
	
	PACKAGES=$(rpm -qa)
	mkdir packages_suse
	
	for package in $PACKAGES
		do
			zypper in -d $packages packages_suse
		done
	tar cvfz packages_suse.tar.gz packages_suse/
	rm -rf packages_suse #cleanup
	}
##
restore()
{}
##
manage()
{}
##

###Backupprozess
#Install packages and restorre list and look for new packges.


(2)NotPackages
#retrieve informationen of Files which do not lie in home/ or point to /home or
#external mounted device  but not installed by any package. then get these files and
#its metadata saved to a sperate file using find

(3)#Backup Users Preferences and Files for #root and for users

###Restoreprozess
#like backup but in reverse order.

##manage backuptimes 

##exclude files from backup
##add users
##add times on which to run

##have option for restore manage and backup prozess should work like zypper


