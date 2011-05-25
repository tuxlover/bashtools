#!/bin/bash

#clearswap

#Script that will clear swapspace

#Comes with the package Bash-Tools
#Ideas Collected by Mendel Cooper (Advanced Bash Scripting guide)
#written for opensue 10.2 by Matthias Propst


##VARS
SWAPSPACE=$1
SWAPFILE="$SWAPSPACE/swapfile" #Change this variable if you want to use an other directory to create temporary swapfile
USER=$(whoami)
VALID_USER=root #Change this if you want cron do this job. normaly users cannot run severeal commands used in this script. Therefor this is for stalling the script before these commands are called.
ANSWER="n" #Set this to y if you need to run this script as a cron job
declare -i NEED_SPACE=2 #You should change this variable if you use more than 1 GB of swapspace.
#VARS

###functions begin here

#checks whether you are root
root_check ()
{
if [ "$USER" != $VALID_USER ]
then
echo "Only root can clear the swap."
exit 1
else
space_check
fi
}

#checks whetehr there is enough space to perform the action
space_check ()
{
unset YOUR_SPACE


#this little trick will get free space from df and makes it an integer value

#See Variable manipulation in Advanced Bash scripting guide to undertand
A=$(df -h $SWAPSPACE | tail -1)
B=$(echo ${A#*G})
C=$(echo ${B#* })
declare -i YOUR_SPACE=$(echo ${C%%G*})
#See Variable manipulation in Advanced Bash scripting guide to undertand


#checks whether you have enough space by comparing the YOUR_SPACE with the NEED_SPACE variable
if [ $YOUR_SPACE -le $NEED_SPACE ]
then
echo "Not enough space. You have $YOUR_SPACE GB left on / partition GB but need $NEED_SPACE GB"
exit 1
else
echo -e "$YOUR_SPACE GB left on / partition..."
drop_ok
sleep 3
secure_qu1
fi
}

secure_qu1 ()
{
#answer is not y at first call of this function, so that ensures to call the function secure_qu2 at least one times
if [ $ANSWER != "y"  ]
then
secure_qu2
else
verify_swap
fi
}

secure_qu2 ()
{
clear

unset SWAP_PART

#This little trick extracts the information form /etc/fstab
#See Variable manipulation in Advanced Bash scripting guide to undertand
A=$(less /etc/fstab|grep swap || less /etc/cryptotab|grep swap)
B=$(echo `expr match "$A" '\(/dev/[[:graph:]]*\)'`)
SWAP_PART=$( echo $B)
#See Variable manipulation in Advanced Bash scripting guide to undertand

clear
echo "Detectcted $SWAP_PART as swap partition"
echo "If you want to change this, you can now specify the device of your swapfile"
read -t 300 -p "Just press Enter if this is okay for you:" SWAP_PART2
${SWAP_PART2:=$SWAP_PART} #if after 300 sec= 5 min no action has taken the script automaticly goes to the next if constructor. you may disable that by deleting -t 300 behind the read statetment

#chekcs whether the user has correct /dev files
#actualy this is only to prevent the user doing anything stupid
if [[  ${SWAP_PART2/#\/dev\/hda*} &&  ${SWAP_PART2/#\/dev\/sda*}  && ${SWAP_PART2/#\/dev\/system*} ]]
then 
clear
echo "$SWAP_PART2 is not a valid device"
exit 1
fi

clear
echo "I assume that $SWAP_PART2 is the device for your swap partition."
read -s -t 300 -n 1 -p "Is this correct?" ANSWER
${ANSWER:=n} 2> /dev/null
secure_qu1
}

verify_swap ()
{
#this funtion verifies whether the given dev really is a swap by looking in the fstab.

FSTAB1=$(less /etc/fstab|grep swap) 2> /dev/null
FSTAB2=$(less /etc/fstab|grep $SWAP_PART2) 2> /dev/null

echo "checking $SWAP_PART2"

if [ "$FSTAB1" != "$FSTAB2" ]
then
echo "$SWAP_PART2 is not a swap device."
drop_failure
exit 1
else
drop_ok
main
fi
}

trapint ()
{
echo "don't press ctrl + c "
}

drop_ok ()
{
echo -e '\t \t \t \t \E[32mok'; tput sgr0
}

drop_failure ()
{
echo -e '\t \t \t \t \E[31mfailure'; tput sgr0
exit 1
}

#main fucntion does the action for what the script is for
main ()
{
#extracts the information, of how many swapspace is actualy used from the
#free -m command
#See Variable manipulation in Advanced Bash scripting guide to undertand
A=$(free -m | tail -1)
B=$(echo ${A#* })
C=$(echo ${B#* })
declare -i D=$(echo ${C#* }) 2> /dev/null
#See Variable manipulation in Advanced Bash scripting guide to undertand

echo "Now performing the action"
sleep 3
clear
echo -e '\E[5;31mDo not interrupt or kill this script until finished'; tput sgr0
trap trapint 2 SIGTSTP
echo "waiting for snapshotting swapdevice to be finished. This may take a while ..."
dd if=$SWAP_PART2 of=$SWAPFILE || drop_failure
drop_ok
echo "$SWAPFILE is temporarily used for swap ..."
swapon $SWAPFILE || drop_failure
drop_ok
echo "turning off $SWAP_PART2. This may take a while ..."
swapoff $SWAP_PART2 || drop_failure
drop_ok
echo "Turning on $SWAP_PART2...."
swapon $SWAP_PART2 || drop_failure
drop_ok
echo "turning off $SWAPFILE. This may take a while ..."
swapoff $SWAPFILE || drop_failure
drop_ok
echo "Removing $SWAPFILE ..."
rm -r $SWAPSPACE || drop_failure
drop_ok

#see above
#See Variable manipulation in Advanced Bash scripting guide to undertand
A=$(free -m | tail -1)
B=$(echo ${A#* })
C=$(echo ${B#* })
declare -i E=$(echo ${C#* }) 2> /dev/null
#See Variable manipulation in Advanced Bash scripting guide to undertand

FREED=$( expr $E - $D ) #simple substruction to get freed space

echo -e  '\E[32mdone'; tput sgr0
echo -e "\E[33m$FREED mb has been freed."
exit 0
}

##functions end here

root_check

exit 0
