#!/bin/bash

 #program that tracks down information for rpm and saves them 
#too a textfile that can be inspected afterwards.

#it should track these option
#-e --> remove
#-U --> upgrade
#-i --> install
#-F --> freshen
#--replacepackage --> reinstall
#--oldpackage --> downgrade 


##VARS

##VARS

check_root ()
{
echo "checking for root"

if [ $UID -ne 0 ]
then
echo "Only root can manage the system packages"
echo "stop"
drop_failure
exit 1
else
drop_ok
check_arg
fi
}

check_arg ()
{
echo "checking arguments"

if [ -z $RPMS ]
then
echo "No arguments"
echo "stop"
echo "Usage: `basename $0` rpmfile(s)"
drop_failure
exit 1
else
drop_ok
fi
}


drop_failure ()
{
echo -e '\t \t \t \t \E[31mfailure'; tput sgr0
}

drop_ok ()
{
echo -e '\t \t \t \t \E[32mok'; tput sgr0
}

RPMS="$@"
check_root


exit 0

#Todo:
#implent root_check (done)
#implement arguments check (done)
#implement file check (we can that like in the resize script but with more safety using the file command)
#implement main
#howto initialize database
#erpm should run an in a loop to ensure that more than one packages are installed 
#erpm should be able to move corectly installed packages
