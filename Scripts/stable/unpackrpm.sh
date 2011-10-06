#!/bin/bash

#unpackrpm

#Script that will unpack an rpm and its filestructure in a directory

#Comes with the package Bash-Tools
#Ideas Collected by Mendel Cooper (Advanced Bash Scripting guide)
#written for opensue 10.2 by Matthias Propst

##VARS
ARGS=2
USER=$(whoami)
##VARS

###functions begin here

unknown_error () #actualy this function should never be used
{
echo "unknown error"

if [ $NEWDIR ]
then
rm -r $NEWDIR
fi

exit 1
}

wrong_distri ()
{
echo "rpm is not installed. Is this a rpm based distri?"

if [ $NEWDIR ]
then
rm -r $NEWDIR
fi

exit 1
}

##functions end here

#checks whether you are root

if [ $USER != "root" ]
then
echo "You are not root, sorry."
exit 1
else
:
fi

#checks whether there are two arguments

if [ $# -ne "$ARGS" ]
then
echo "Usage: `basename $0` \"Absolute Targetdir\" \"Package\""
exit 1
else
:
fi

#checks whether the second argument is an .rpm


if [ ${2##*.} != "rpm" ]  #this checks whether the file has the .rpm suffix
then
echo "Not a .rpm file"
exit 1
else
	if [ ! -f $2 ] #this checks whether the file exists
	then
	echo "Not a .rpm file"
	exit 1
	fi
	
fi


if [[ $1 == "/" || ! ${1/#\/boot*} || ! ${1/#\/bin*} || ! ${1/#\/dev*} || ! ${1/#\/etc*} || ! ${1/#\/lib*} || ! ${1/#\/lost+found*} || ! ${1/#\/media*} || ! ${1/#\/mnt*}  || ! ${1/#\/opt*} || ! ${1/#\/proc*} || ! ${1/#\/sbin*} || ! ${1/#\/srv*} || ! ${1/#\/sys*} || ! ${1/#\/selinux*} || ! ${1/#\/tmp*} || ! ${1/#\/usr*} || ! ${1/#\/var*} ]]  #checks for forbidden arguments in $1 actually ${1/#SOMETHING} lets you check the given arguments in a more detailed way
then
echo "Choosing $1 may harm your system. stop"
exit 1
fi
#checks whether the unpack Dir allready exists. if so, gives an error
if [[ -d $1 || -f $1 ]]
then
echo "$1 already exists. You have to choose another directory to unpack $2"
exit 1
else
mkdir -p $1
NEWDIR=$1
fi

#Now the action will be performed

echo "Using rpm version:"
rpm --version 2> /dev/null || wrong_distri

rpm -Uhv --ignorearch --nodeps --force  --root $1 $2 || unknown_error

exit 0

#Todo:
#better method to test whether this is realy a rpm: od rpm |head -1|awk '$2' == 12755
