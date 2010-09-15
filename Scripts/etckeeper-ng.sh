#!/bin/bash

#etckeeper-ng

BACKUPDIR=$HOME/testdir

#This Programm should be able to backup and restore a complete etc-tree
#It uses git and rsync to archive this
#After backup has completed a complete restore should easy be possible 

#First check if needed programms are present
#git #awk #stat #grep #find

#do the initial backup
initial_git()
{
#check if an older backup already exists
if [ -s $BACKUPDIR/content.bak  ]
	then
		read -p "it seems there already exists an backup. overwrite?(y)" ANSWER
		${ANSWER:="no"} 2> /dev/null
		
		if [ "$ANSWER" != "y" ]
			then
				echo "use -b option to commit new backup branch"
				exit 1
			else
				rm -rf $BACKUPDIR/
		fi
fi
			

if [ ! -d $BACKUPDIR ]
	then	
		mkdir -p $BACKUPDIR	
		find /etc/ -exec stat -c "%n %a %U %G" {} \; >> $BACKUPDIR/content.bak

	else
		find /etc/ -exec stat -c "%n %a %U %G" {} \; >> $BACKUPDIR/content.bak		
fi

mkdir $BACKUPDIR/etc_bak
rsync -r -t -p -o -g -v --progress --delete -c -l -s /etc/* $BACKUPDIR/etc_bak

#doing the git action
cd $BACKUPDIR
git init
git add etc_bak/ && git add content.bak && git commit -m "$(date +%F-%H-%M)"
}

#to a branched backup
backup_git()
{
DATE=$(date +%F-%H-%M)
#check if the initial backup exists
if [ ! -s $BACKUPDIR/content.bak ]
	then
		echo "No initial backup found"
		read -p "Would you like to do an initial backup now?(y)" ANSWER
		${ANSWER:="no"} 2> /dev/null
		
		if [ "$ANSWER" != "y"  ]
			then
				echo "use -i option to do an initial backup"
				exit 1
		fi				
fi
#first make sue we are on master
cd $BACKUPDIR
git checkout master

#then create a new branch
git branch $DATE
git checkout $DATE

#clean up the old content.bak
cat /dev/null > $BACKUPDIR/content.bak
find /etc/ -exec stat -c "%n %a %U %G" {} \; >> $BACKUPDIR/content.bak
rsync -r -t -p -o -g -v --progress --delete -c -l -s /etc $BACKUPDIR/etc_bak

git add etc_bak/ && git add content.bak && git commit -m "$(date +%F-%H-%M)"

#and return back to master branch to make sure we succeed with no errors
git checkout master || return 1
git merge $DATE || return 1			
}

restore_perms()
{
count=$(wc -l content.bak | awk '{print $1}')

while [ $count -gt 0  ]
	do
		FILE=$(tail -n ${count} content.bak|head -1)
		NAME=$(echo $FILE|awk '{print $1}')
		PERMS=$(echo $FILE|awk '{print $2}')
		OWNU=$(echo $FILE|awk '{print $3}')
		OWNG=$(echo $FILE|awk '{print $4}')
		
		echo "chmod $PERMS $NAME && chown $OWNU:$OWNG $NAME"
		count=$(($count-1))
		unset FILE
	done
}

list_git()
{
cd $BACKUPDIR 2> /dev/null || return 1
git branch


}

#options starts here
while getopts ibl opt
	do
		case "$opt" in
			i) initial_git
			;;
			b) backup_git
			;;
			l) list_git || echo "no initial backup and no git repo found"

		esac
	done
shift `expr $OPTIND - 1`


#Todo:
#Show different states
#Checkout different states
#use options to specifiy what todo
#Supported options: -i initial, reinitial
#                   -b backup the current state (only when initial backup exists)
#                   -r recover a state (only when such state exist)
#		    -l list all known states
#check if git status return 0 instead of using file tests
#check if we have all tools installed we need
#    git config --global user.name "Your Name"
#    git config --global user.email you@example.com

