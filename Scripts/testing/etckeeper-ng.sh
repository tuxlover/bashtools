#!/bin/bash

#etckeeper-ng

#change the value BACKUPDIR if $HOME does not fit your needs
BACKUPDIR="/root/.etcbackup/"
COMPAREDIR="/root/.etccomp"
EXCLUDEFILE="/root/.etcbackup/excludes"

#This Programm should be able to backup and restore a complete etc-tree
#It uses git and rsync to archive this
#After backup has completed a complete restore should easy be possible 

#WARNING: work in progress. for details read the todo section on the bottom of the script

#help function starts here
get_help()
{
echo "$0 [ -i ] [ -b ] [ -l ] [ -r Branch ] [ -h ]"
echo "etckeeper-ng helps you creating a snapshot based backup of the /etc folder using git version control"
echo "-i: do the initial backup. there must be an initial backup to do new branched backups"
echo "-b: do a new branch backup. if no initiallized backup exists you will be asked"
echo "-c: check the /etc direcotry for changes"
echo "-C: check and restore permissions without asking"
echo "-e example: exclude /etc/exaple from versioning"
echo "-l: lists all existing branches"
echo "-r HEAD|<Commit> restore /etc from HEAD or a specific commit"
echo "becasue etc-keeper is still under development. the only way to to restore is using git and rsync by hand"
}


#check whether we have all needed tools installed and got acces to them
check_tools()
{
#checking git
git --version &> /dev/null && HAS_GIT="yes" || HAS_GIT="no"
if [ $HAS_GIT != "yes" ]
	then
		echo -e '\E[31m git not installed'
		tput sgr0
		exit 1
fi

#checking rsync
rsync --version &> /dev/nul && HAS_RSYNC="yes" || HAS_RSYNC="no"
if [ $HAS_RSYNC != "yes" ]
		then
			echo -e '\[31m rsync not installed'
			tput sgr0
			exit 1
fi

#checking awk
awk --version &> /dev/null && HAS_AWK="yes" || HAS_AWK="no"
if [ $HAS_AWK != "yes" ]
	then
		echo -e '\E[31m awk not installed'
		tput sgr0
		exit 1
fi

#checking grep
grep --version &> /dev/null && HAS_GREP="yes" || HAS_GREP="no"
if [ $HAS_GREP != "yes" ]
	then
		echo -e '\E[31m grep not installed'
		tput sgr0
		exit 1
fi

#checking find
find --version &> /dev/null && HAS_FIND="yes" || HAS_FIND="no"
if [ $HAS_FIND != "yes" ]
	then
		echo -e '\E[31m findutils not installed'
		tput sgr0
		exit 1
fi

#checking stat
stat --version &> /dev/null && HAS_STAT="yes" || HAS_STAT="no"
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
		echo -e '\E[31m not root'
		exit 1
fi
}

#function to write exclude patterns to a file
exclude()
{
check_root
check_tools
EXCLUDES=$(echo "$OPTARG $args")

if [ ! -d $BACKUPDIR ]
	then
		mkdir $BACKUPDIR
fi

for e in ${EXCLUDES}	
	do
		if [ ! -e /etc/$e ]
			then
				echo "file $e does not exist"
				continue
		fi
		echo "/$e" >> $EXCLUDEFILE
	done
	
}

#do the initial backup
initial_git()
{
check_root
check_tools

DATE=$(date +%F-%H-%M)

#check if an older backup already exists
if [ -s $BACKUPDIR/content.lst  ]
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
		find /etc/ -exec stat -c "%n %a %U %G" {} \; >> $BACKUPDIR/content.lst

	else
		find /etc/ -exec stat -c "%n %a %U %G" {} \; >> $BACKUPDIR/content.lst		
fi

mkdir $BACKUPDIR/etc
#check wheter we have an excludefile
if [ ! -e $EXCLUDEFILE ]
	then
		echo "WARNING: there was no exlcudefile setup, so i exclude nothing"
		echo "WARNING: Use -e to wirte a list of filese that will be excluded"
		echo "WARNING: it is highly recommended that you first define what should be exluded"
		sleep 10
		rsync -rtpog --delete -clis /etc/ $BACKUPDIR/etc
	else
		
		rsync -rtpog --delete -clis --exclude-from=$EXCLUDEFILE --delete-excluded /etc/ $BACKUPDIR/etc
fi

while [ -z "$COMMENT" ]
	do
		echo "please comment your commit and press Enter when finished:"
		read -e COMMENT 
	done

#doing the git action
cd $BACKUPDIR
git init
if [ ! -e $EXCLUDEFILE ]
then
	git add etc/ && git add content.lst && git commit -m "$USER $DATE ${COMMENT[*]}"
else
	git add etc/ && git add content.lst && git add $EXCLUDEFILE && git commit -m "$USER $DATE ${COMMENT[*]}"
fi
}

#to a branched backup
backup_git()
{
git_return=0
check_root
check_tools

DATE=$(date +%F-%H-%M)
#check if the initial backup exists
if [ ! -s $BACKUPDIR/content.lst ]
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
#first make sure we are on master
cd $BACKUPDIR
git checkout master

check_perms
return_check=$?

#check if exluce file exists
if [ ! -e $EXCLUDEFILE ]
	then
		rsync -rtpog --delete -clis /etc/ $BACKUPDIR/etc/
	else
		rsync -rtpog --delete -clis --exclude-from=$EXCLUDEFILE --delete-excluded /etc/ $BACKUPDIR/etc/
fi


#then track changed files
#create a helper file which will be deleted afterwards
git_status_file="/tmp/git_status_file"
git status -s > $git_status_file
lof=$(wc -l $git_status_file|awk '{print $1}')
until  [ "$lof" == 0  ]
	do	
		if [ $(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "M" 2> /dev/null ]
			then
				mod_file=$(tail -n $lof $git_status_file|head -1|awk '{print $2}')
				echo "modified file: $mod_file"
				git add $mod_file
		elif [ $(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "D"  2> /dev/null ]
			then
				del_file=$(tail -n $lof $git_status_file|head -1|awk '{print $2}')
				echo "deleted file: $del_file"
				
				if [ grep $del_file $EXCLUDEFILE &> /dev/null ]
					then
						echo "$del_file was excluded by exlcude rule and will be removed from backup"
				fi
					git rm $del_file
					git_return=1
		elif [ $(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "A" 2> /dev/null ]
			then
				a_file=$(tail -n $lof $git_status_file|head -1|awk '{print $2}')
				echo "file was allready added: $a_file"
		elif [$(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "R" 2> /dev/null ]
			then
				ren_file=$(tail -n $lof $git_status_file|head -1|awk '{print $2}')
				echo "renamed file: $ren_file"
				git add $ren_file
			else
				new_file=$(tail -n $lof $git_status_file|head -1|awk '{print $2}')
				echo "new file: $new_file"
				git add $new_file
				git_return=1
		fi
		lof=$((lof-=1))
	done
#remove untracked file git_status_file
rm $git_status_file

#create new content file only when new files were added or permissions have changed
if [[ $git_return -eq 1 || $return_check -eq 1 ]]
	then
		#clean up the old content.lst
		cat /dev/null > $BACKUPDIR/content.lst
		find /etc/ -exec stat -c "%n %a %U %G" {} \; >> $BACKUPDIR/content.lst
		git add $BACKUPDIR/content.lst
fi
		
while [ -z "$COMMENT" ]
	do
		echo "please comment your commit and press Enter when finished:"
		read -e COMMENT 
	done
	
git commit -m "$USER $DATE ${COMMENT[*]}"

#and return back to master branch to make sure we succeed with no errors
git checkout master || return 1			
}

#restore from a certain commit
restore_git()
{
check_perms_S

if [ "$OPTARG" == "HEAD" ]
		then
			cd $BACKUPDIR
			git checkout master
			git reset --hard
			git_status_file="/tmp/git_status_file"
			git status -s > $git_status_file
			lof=$(wc -l $git_status_file|awk '{print $1}')
			until  [ "$lof" == 0  ]
				do	
					if [ $(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "M" 2> /dev/null ]
						then
							:
					elif [ $(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "D"  2> /dev/null ]
						then
							:
					elif [ $(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "A" 2> /dev/null ]
						then
							:
					elif [$(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "R" 2> /dev/null ]
						then
							:
					else
						new_file=$(tail -n $lof $git_status_file|head -1|awk '{print $2}')
						rm $new_file
					fi
					lof=$((lof-=1))
				done
		else
			cd $BACKUPDIR
			git checkout master
			git reset --hard "$OPTARG" || echo "This commit does not exist. Use -l to show commits."
			git_status_file="/tmp/git_status_file"
			git status -s > $git_status_file
			of=$(wc -l $git_status_file|awk '{print $1}')
			until  [ "$lof" == 0  ]
				do	
					if [ $(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "M" 2> /dev/null ]
						then
							:
					elif [ $(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "D"  2> /dev/null ]
						then
							:
					elif [ $(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "A" 2> /dev/null ]
						then
							:
					elif [$(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "R" 2> /dev/null ]
						then
							:
					else
						new_file=$(tail -n $lof $git_status_file|head -1|awk '{print $2}')
						rm $new_file
					fi
					lof=$((lof-=1))
				done
fi
rsync -rtpog -clis $BACKUPDIR/etc/ /etc/
COMMENT=(backup after restore)
backup_git
}

compare()
{
#check if the initial backup exists
if [ ! -s $BACKUPDIR/content.lst ]
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
	else
		mkdir $COMPAREDIR
		rsync -rtpog --delete -clis $BACKUPDIR $COMPAREDIR	
		rsync -rtpog --delete -clis --exclude-from=$EXCLUDEFILE /etc/ $COMPAREDIR/etc/
fi
	
check_perms
status_check="$?"
cd $COMPAREDIR
git checkout master


git_status_file="/tmp/git_status_file"
git status -s > $git_status_file
lof=$(wc -l $git_status_file|awk '{print $1}')
until  [ "$lof" == 0  ]
	do	
		if [ $(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "M" 2> /dev/null ]
			then
				mod_file=$(tail -n $lof $git_status_file|head -1|awk '{print $2}')
				echo "modified file: $mod_file"
				status_check="2"
		elif [ $(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "D"  2> /dev/null ]
			then
				del_file=$(tail -n $lof $git_status_file|head -1|awk '{print $2}')
				echo "deleted file: $del_file"
				status_check="3"
		elif [ $(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "A" 2> /dev/null ]
			then
				a_file=$(tail -n $lof $git_status_file|head -1|awk '{print $2}')
				echo "file was allready added: $a_file"
				status_check="4"
		elif [$(tail -n $lof $git_status_file|head -1|awk '{print $1}') == "R" 2> /dev/null ]
			then
				ren_file=$(tail -n $lof $git_status_file|head -1|awk '{print $2}')
				echo "renamed file: $ren_file"
				status_check=5			
		else
				new_file=$(tail -n $lof $git_status_file|head -1|awk '{print $2}')
				echo "new file: $new_file"
		fi
		lof=$((lof-=1))
	done

rm -rf $COMPAREDIR 
rm $git_status_file
}

check_perms()
{
return_check=0
echo "checking Permissions ..."	
	
count=$(wc -l $BACKUPDIR/content.lst | awk '{print $1}')

until [ $count == 0  ]
	do
		FILE=$(tail -n ${count} $BACKUPDIR/content.lst|head -1)
		NAME=$(echo $FILE|awk '{print $1}')
		PERMS=$(echo $FILE|awk '{print $2}')
		OWNU=$(echo $FILE|awk '{print $3}')
		OWNG=$(echo $FILE|awk '{print $4}')
		
	#if a file is not present, skip test
		if [ ! -e "$NAME" ]
			then
				count=$((count-=1))
				continue
		fi
	
	#cheking whether the Permissions have changed
		if [ "$(stat -c %a $NAME)" != "$PERMS"  ]
			then	
				echo -e '\E[31m permissions'; echo "of file $NAME has changed to $(stat -c %a $NAME)"
				tput sgr0
				echo "Restore permission for $NAME to $PERMS" 
				read -e -n 1 -p	"y(restore)/n(check in these changes)" ANSWER1
				{$ANSWER1:="n"} 2> /dev/null
				
				if [ $ANSWER1 == "y" ]
					then
						chmod $PERMS $NAME
						echo "permissions for file $NAME restored"
				fi
				return_check=1
		fi
		
	#checking whether the Owner or the Group has changed 
		if [[ "$(stat -c %U $NAME)" != "$OWNU" || "$(stat -c %G $NAME)" != "$OWNG" ]]
			then				
				echo -e '\E[31m owner or group'; echo  "of $NAME has changed to $(stat -c "%U:%G" $NAME)"
				tput sgr0
				echo "Restore the owner and the Group of the File $NAME to $OWNU:$OWNG " 
				read -e -n 1 -p	"y(restore)/n (check in these changes)" ANSWER2
				{$ANSWER2:="n"}	2> /dev/null
				
				if [ $ANSWER2 == "y" ]
					then
					chown $OWNU:$OWNG $NAME
					echo "Owner and Group for $FILE restored"
				fi
				return_check=1
		fi

		count=$((count-=1))
		unset FILE
		unset ANSWER1
		unset ANSWER2
	done
	return $return_check
}

check_perms_S()
{
return_check=0
echo "checking Permissions ..."	
	
count=$(wc -l $BACKUPDIR/content.lst | awk '{print $1}')

until [ $count == 0  ]
	do
		FILE=$(tail -n ${count} $BACKUPDIR/content.lst|head -1)
		NAME=$(echo $FILE|awk '{print $1}')
		PERMS=$(echo $FILE|awk '{print $2}')
		OWNU=$(echo $FILE|awk '{print $3}')
		OWNG=$(echo $FILE|awk '{print $4}')
		
	#if a file is not present, skip test
		if [ ! -e "$NAME" ]
			then
				count=$((count-=1))
				continue
		fi
	
	#cheking whether the Permissions have changed
		if [ "$(stat -c %a $NAME)" != "$PERMS"  ]
			then	
				echo -e '\E[31m permissions'; echo "of file $NAME has changed to $(stat -c %a $NAME)"
				tput sgr0
				chmod $PERMS $NAME
				echo "permissions for file $NAME restored"
				return_check=1
		fi
		
	#checking whether the Owner or the Group has changed 
		if [[ "$(stat -c %U $NAME)" != "$OWNU" || "$(stat -c %G $NAME)" != "$OWNG" ]]
			then				
				echo -e '\E[31m owner or group'; echo  "of $NAME has changed to $(stat -c "%U:%G" $NAME)"
				tput sgr0
				chown $OWNU:$OWNG $NAME
				echo "Owner and Group for $FILE restored"
				return_check=1
		fi

		count=$((count-=1))
		unset FILE

	done
	return $return_check
}


list_git()
{
check_root
check_tools

cd $BACKUPDIR 2> /dev/null || return 1
git branch -a
PAGER=cat git log
}

#options starts here
while getopts ibclhe:r: opt
	do
		case "$opt" in
			i) initial_git
			;;
			e) shift $((OPTIND -1))
				args=$(echo $*)
				exclude
				break
			;;
			b) backup_git
			;;
			c) compare
			;;
			C) check_perms_S
			;;
			l) list_git || echo "no initial backup and no git repo found"
			;;
			h) get_help
			;;
			r) restore_git
			;;
			\?) get_help
		esac
	done
shift `expr $OPTIND - 1`

exit 0

#Todo:
#use return values and do checks before reading options
#report of changed files in diff report file when found in function compare
#use a config file for configuring how etckeeper behaves
#dont remove exlcudefile when reinitializing with -i
#no nedd to check permissions twice in -c and -r
#The restore option is still broken
#add a comment funtion if you only need to comment your work for example if you changed files which where exlcluded by excludefile
#add a option to only add files which has changed instead of backup the whole etc every time
