#!/bin/bash

#etckeeper-ng

#change the value BACKUPDIR if $HOME does not fit your needs
BACKUPDIR=/root/.etcbackup/

#This Programm should be able to backup and restore a complete etc-tree
#It uses git and rsync to archive this
#After backup has completed a complete restore should easy be possible 


#help function starts here
get_help()
{
echo "$0 [ -i ] [ -b ] [ -l ] [ -r Branch ] [ -h ]"
echo "etckeeper-ng can do a snapshot based backup of the /etc folder using git version control"
echo "-i do the initial backup. there must be an initial backup to do new branched backups"
echo "-b do a new branch backup. if no initiallized backup exists you will be asked"
echo "-l lists all existing branches"
echo "-r [Branch] restore /etc from Branch if no Branch is specified use the last existing master branch (not implemented yet)"
echo "becasue etc-keeper is still under development. the only way to to restore is using git and rsync by hand"
}


#check whether we have all needed tools installed and got acces to them
check_tools()
{
#checking git
git --version &> /dev/null && HAS_GIT="yes"
if [ $HAS_GIT != "yes" ]
	then
		echo -e '\E[31m git not found'
		tput sgr0
		exit 1
fi	

#checking awk
awk --version &> /dev/null && HAS_AWK="yes"
if [ $HAS_AWK != "yes" ]
	then
		echo -e '\E[31m awk not found'
		tput sgr0
		exit 1
fi

#checking grep
grep --version &> /dev/null && HAS_GREP="yes"
if [ $HAS_GREP != "yes" ]
	then
		echo -e '\E[31m grep not found'
		tput sgr0
		exit 1
fi

#checking find
find --version &> /dev/null && HAS_FIND="yes"
if [ $HAS_FIND != "yes" ]
	then
		echo -e '\E[31m findutils not installed'
		tput sgr0
		exit 1
fi

#checking stat
stat --version &> /dev/null && HAS_STAT="yes"
if [ $HAS_STAT != "yes" ]
	then
		echo -e '\E[31m coreutils not installed'
		tput sgr0
		exit 1
fi

}

#check whether we are root
check_root()
{
if [ $UID -ne 0 ]
	then 
		drop_failure
		echo "not root"
		exit 1
fi
}

#do the initial backup
initial_git()
{
check_root
check_tools

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

#configure the gloabel git  if allready set do nothing
git config --global user.name "$USER" 2> /dev/null || :
git config --global user.email "$USER@$HOSTNAME" 2> /dev/null || :

if [ ! -d $BACKUPDIR ]
	then	
		mkdir -p $BACKUPDIR	
		find /etc/ -exec stat -c "%n %a %U %G" {} \; >> $BACKUPDIR/content.bak

	else
		find /etc/ -exec stat -c "%n %a %U %G" {} \; >> $BACKUPDIR/content.bak		
fi

mkdir $BACKUPDIR/etc_bak
rsync -rtpogv --progress --delete -clis /etc/* $BACKUPDIR/etc_bak

#doing the git action
cd $BACKUPDIR
git init
git add etc_bak/ && git add content.bak && git commit -m "$(date +%F-%H-%M)"
}

#to a branched backup
backup_git()
{
check_root
check_tools

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
			else
				initial_git && exit 0 || exit  && exit 0 || exit 11
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
rsync -rtpogv --progress --delete -clis /etc $BACKUPDIR/etc_bak

git add  $BACKUPDIR && git commit -m "$DATE"

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
check_root
check_tools

cd $BACKUPDIR 2> /dev/null || return 1
git branch


}

#mesage funcions
drop_failure ()
{
echo -e '\t \t \t \t \E[31mfailure'; tput sgr0
}

drop_ok ()
{
echo -e '\t \t \t \t \E[32mok'; tput sgr0
}

#options starts here
while getopts iblh opt
	do
		case "$opt" in
			i) initial_git
			;;
			b) backup_git
			;;
			l) list_git || echo "no initial backup and no git repo found"
			;;
			h) get_help
			;;
			\?) get_help
		esac
	done
shift `expr $OPTIND - 1`


#Todo:
#Never copy /erc/passwd /etc/shadow and other sensetive files into backup dir
#Show different states
#compress the backup

#the -r option works like this 
#checkout the state #N
#rync back to /etc
#restore changes
#check whether the ownercchip has really change and only change ownrtship if nessacessary

#Checkout different states
#use options to specifiy what todo
#Supported options: -i initial, reinitial
#                   -b backup the current state (only when initial backup exists)
#                   -r recover a state (only when such state exist) (not implemented)
#		    -l list all known states
#		    -n only add a new file (not implemented)
#		    -f only add changes of specfic file in /etc (not implemented)
#		    -c check the state of current /etc (not implemented)
#check if git status return 0 instead of using file tests
#check if we have all tools installed we need
#save changes for chattr as well
#compress changes
#make comments to changes
