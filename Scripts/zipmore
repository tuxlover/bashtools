#!/bin/bash

#zipmore

#Script that allows you to view bzip2 or gzip gezipped files
#using less and tar.

#Comes with the package Bash-Tools
#Ideas collected by Mendel Cooper (Advanced Bash Scripting Guide)
#Rewritten for opensuse 10.2 by Matthias Propst

#VARS
FILE=$1 #sets the first argument to variable FILE
#VARS

#checking for arguments
if [ $# -eq 0 ] #using compare operators instead of file operator
then
echo "Usage `basename $0` bzip2file [gzipfile]" >&2
exit 1
fi


#checking whether the file exists
if [ ! -f "$FILE" ]
then
echo "File $1 not found" >&2
exit 1
fi


#checking whether the file is in gzip or bzip2 format
#performing the action
IS_GZIP=$(file $FILE|grep "gzip compressed")
${IS_GZIP:=no} 2> /dev/null

IS_BZIP2=$(file $FILE|grep "bzip2 compressed")
${IS_BZIP2:=no} 2> /dev/null

if [ "$IS_GZIP" != "no" ]
then
tar tvzf $FILE | less
else
  if [ "$IS_BZIP2" != "no" ]
  then
  tar tvjf $FILE | less
  else
  echo "File $FILE is not a gzip or bzip2 file."
  fi
fi

exit 0
