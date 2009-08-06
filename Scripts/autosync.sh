#!/bin/bash

#autosync

#Script that automatacly snycs between internal and external Data
#Should be run as a cronjob. but using it for one action is also possible.

##VARS

#These are the variables that holds the internal and external Data
#Should at least be one directory. But array use is possible
SYNCIN="not_specified"
SYNCOUT="not_specified"

#

##VARS

main ()

#stop if either dir SNYCIN or Syncout not Specified
#should be a loop
if [ $SYNCIN ! -d || $SYNCOUT ! -d ]
then
exit 0
else
	do #Here goes the action
	done
fi	
