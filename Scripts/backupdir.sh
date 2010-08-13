#!/bin/bash

#backup
# Will back up all files in the current directory modified within last the 24 hours
# in a "tarball" (tarred and gzipped file).

#Comes with the package Bash-Tools
#Ideas collected by Mendel Cooper (Advanced Bash Scripting Guide)
#Rewritten for opensuse 10.2 by Matthias Propst

#Caution: do not backup the /  directory. this may cause serious damage to your file-system.

#VARS
BACKUP_DIR=$HOME/lost+found #change this if you want another directory for backups
DAYS=1 #change this variable if you want to backup the changes of the last $DAYS
#VARS

###Fucntions start here

#checking for root.
check_root ()
{
echo "Checking whether you have root privileges"

if [ $UID -ne 0 ]
then
drop_failure
echo "Not root"
exit 1
else
drop_ok
check_arg
fi
}

#checking whether the script has at least one argument passed by the user 
check_arg ()
{
echo "Checking for arguments."

if [ -z "$DIR" ] #because DIR is the same as $*, DIR will be null if no arguments given, and therfore the -z will be true and exits the script with error code NO_ARGS.
then
drop_failure
echo "You must select a directory to backup. Usage: `basename $0` \"<directory>\""
exit 1
else
drop_ok
check_dir
fi
}

#checks whether the BACKUP_DIR and DIR exits
check_dir ()
{
if [ ! -d  $BACKUP_DIR ] #will back up files in roots home by default.
then
echo "Directory $BACKUP_DIR does not exist. Creating it."
mkdir $BACKUP_DIR #creating BACKUP_DIR if yet not exists
main
else
	for directory in $DIR #checking each given dir whether it exits
	do
		if [ ! -d $directory ]
		then
		echo "At least one directory you want to backup does not exist. Please check this and restart the script only with"
		echo "directories that do exits."
		drop_failure
		echo -e '\E[31mdirecory'; tput sgr0 && echo "$directory" && echo -e '\E[31m does not exits.'; tput sgr0
		exit 1
		fi
	done
 
main
fi
}

trapint () #this function is needed by the trap command
{
echo "dont press ctrl + c"
}

#sugesteted by Stephane Chazelas, improved by Matthias Propst
main ()
{
echo "You must enter the name of the backup-archive. If no name is given, \"backed_up\" will be used."
read -p "Please enter the name of the backup-archive:" NAME
${NAME:="backed_up"} 2>/dev/null

echo "checking for tar and gunzip"

##if tar or gunzip for some reason do not exist, the "-" will be the value for TAR_VER or GZIP_VER
TAR_VER=$(tar --version || echo "-")
GZIP_VER=$(gunzip --version || echo  "-")

#logical OR if one of the vars TAR_VER or GZIP_VER hold "-" as its value, this command is not installed on this mashine and the scripts will finsh here
if [[ $TAR_VER == "-" || $GZIP_VER == "-" ]]
then
drop_failure
echo "No tar command found"
exit 1
else
echo "Using $TAR_VER to create tarball and $GZIP_VER for compression."
drop_ok
fi

echo "Performing backup process. Please be patient."

for backup in $DIR
do

	if [[ $backup == "/" || $backup == "/proc" || $backup == "/dev" || $backup == "/tmp" ]] #scipps the /  /proc /dev/ /tmp argument if given 
	then
	echo -e '\E[33mWarning:'; echo $backup; echo -e '\E[33mshould not be backed up. Skipped.'; tput sgr0
	else
	trap trapint 2 SIGTSTP #this traps the ctrl+c and the simple kill but not the kill -9 systemcall
	BACKUP_FILE=$(date +%Y%m%d%H%M%S) #Index for Backupfile use man date to find out more
	
	find $backup -mtime -$DAYS -type f -print0 | xargs -0 tar rvf "$NAME-$BACKUP_FILE.tar" || unknown_error #using the GNU version of "find" to get the last changed files them passes them as arguments to be tared 
	
	gzip "$NAME-$BACKUP_FILE.tar" #compresses the tarball
	
	mv "$NAME-$BACKUP_FILE.tar.gz" $BACKUP_DIR/ 
	echo "Directory $backup backed up in archive file $BACKUP_DIR/\"$NAME-$BACKUP_FILE.tar.gz\"." #moves the tar.gz to the backup dir and prints a message
	drop_ok
	fi
done

unset DIR

echo -e '\E[32mdone'; tput sgr0
exit 0
}

drop_ok ()
{
echo -e '\t \t \t \t \E[32mok'; tput sgr0
}

drop_failure ()
{
echo -e '\t \t \t \t \E[31mfailure'; tput sgr0
}

unknown_error ()
{
drop_failure
echo "unknown error"
exit 1
}

###functions end here

export DIR=$*
check_root

exit 0
