#!/bin/bash

#wipefree

#Script that will wipe the free space of several partitions

##Comes with the package Bash-Tools
#Original Idea by Thomas C. Greene
#Ideas Collected by Mendel Cooper (Advanced Bash Scripting guide)
#rewritten for opensue 10.2 by Matthias Propst

#VARS
#VARS

###functions begin here

#checks for root
check_root ()
{
echo "Checking whether you are root."

if [ $UID -ne 0 ]
then
echo "Only root can wipeout free space."
drop_failure
exit 1
else
drop_ok
check_sync
fi
}

check_sync ()
{
VERSION=$(sync --version  2> /dev/null || echo "-" )
if [[ $VERSION == "-" ]]
then
echo "sync does not seemed to be installed"
echo "Please install sync and rerun again. It is usaly in the package coreutils."
echo "Script exits now."
drop_failure
exit 1
else
echo "found $VERSION"
drop_ok
often
fi
}

often ()
{
##stes the counter. this is important and ensures the script to stop
unset COUNTER
read -p "How often to you need `basename $0` to run: " COUNTER
${COUNTER:="0"} 2> /dev/null
CHECK=$(( $COUNTER * 1 )) 2> /dev/null
#this prevents the user passing 0 or an non integer value
##sets the Counter. this important and ensures the script to stop


if [[ $CHECK != $COUNTER || $COUNTER == "0" ]] #because Check will be the errormessage from a non integer value or counter is 0 this checks whether counter is an integer > 0
then
echo "$COUNTER is not an integer value."
drop_failure
exit 1
else
algorithm
fi
}

algorithm()
{
unset ALGO
unset ALGO_NAME
clear
#Users Choise of which algorithm (method) is used
echo "Algorithms:"
echo "(1) urandom: Uses the /dev/urnadom (default)"
echo "(2) zero: Uses /dev/zero to overwrite your free space (fast but unsecure)"
echo "(3) filesplitter: uses a mixture of both zero and urandom and split up the _cleanupfile_. (should be best result)"
read -n 1 -p "Which algorithm do you want to run. Press Enter to use default." ALGO
${ALGO:=1} 2> /dev/null

	case $ALGO in
	1) check_part
		;;
	2) check_part
		;;
	3) check_part
		;;
	*) algorithm #if any other key is pressed the script asks again
		;;
	esac

}

check_part ()
{
clear
echo "We will wipe out free space in"

for f in $FS #the loop list all folders given and checks whether the folder belongs to a partition
do
unset PART
unset CRYPTO_PART

  if [[ $f == "/dev/" || ! ${f/#\/dev*} || ! ${f/#\/proc*} || $f == "swap" ]]
  then
  echo "Oops"
  echo "$f: This is not allowed"
  exit 1
  fi

PART=$(echo `less /etc/fstab | grep $f`)
CRYPTO_PART=$(echo `less /etc/cryptotab | grep $f`)

${PART:="-"} 2> /dev/null
${CRYPTO_PART:="-"} 2> /dev/null

  if [ "$PART" ==  "-" ] ##if the partition is not in /etc/fstab than probly in /etc/cryptotab
  then
    if [ "$CRYPTP_PART" == "-" ]
    then
    echo "$f is not a partition"
    echo "Maybe this is not your fault. Because the Script does not handle /foobar/ if the folder /foobar has"
    echo "its own partition. Try to rerun the script with /foobar instead of /foobar/." #a warning because i dont know how to prevent that. maybe someone else has an idea+++script exits at first found invalid partition this depends on the order of given scripts
    drop_failure
    exit 1
    fi
  else
  echo $f
  fi
done
drop_ok

echo "$COUNTER times"
echo "with the"
	case $ALGO in #prints a summary
	1) echo "urandom"
		;;
	2) echo "zero"
		;;
	3) echo "filesplitter"
		;;
	esac
echo "algorithm."
sleep 3

main
}

trapint ()
{
echo "dont press ctrl + c"
}

main ()
{
echo "Starting now."
echo "This may take a long time."
echo -e '\E[5;31mDo not interrupt or kill this script until it is finished'; tput sgr0
sleep 3

case $ALGO in
1)

	until [ $COUNTER -eq 0 ]
	do
	((COUNTER -=1))
	((COUNTER2 +=1))
	echo "Starting pass $COUNTER2."
	echo "Remaining $COUNTER passes."
		
		for f in $FS
		do
		name="$f/_cleanupfile_"
		echo "Creating $name"
		set +e +u
		trap trapint 2 SIGTSTP
		dd if=/dev/urandom of="$f/_cleanupfile_"
		sync; sync
		rm "${f}/_cleanupfile_"
		sync; sync
		drop_ok
		done

	done
;;
2)
	until [ $COUNTER -eq 0 ]
	do
	((COUNTER -=1))
	((COUNTER2 +=1))
	echo "Starting pass $COUNTER2"
	echo "Remainig $COUNTER passes."

		for f in $FS
		do
		name="$f/_cleanupfile_"
		echo "Creating $name"
		set +e +u
		trap trapint 2 SIGTSTP
		##creates the big cleanupfile
		dd if=/dev/zero of="$f/_cleanupfile_"
		sync; sync ##sync the cleanupfile
		rm "${f}/_cleanupfile_"
		sync; sync ##sync free space
		drop_ok
		done
	done
;;
3)
	until [ $COUNTER -eq 0 ]
	do
	((COUNTER -=1))
	((COUNTER2 +=1))
	echo "Starting pass $COUNTER2"
	echo "Remainig $COUNTER passes."

		for f in $FS
		do
		folder="$f/_clean_"
		
			a=0
			i=0
			while [ $a -eq 0 ]
			do
			unset a
			mkdir -p $folder
			((i+=1))
			unset RAND 
			RAND=$(($RANDOM %2 )) #generates random integer and checks whether this is odd or even by using the mathemtic modulo function
			
				case $RAND in
				0) #rand was even
				name="$folder/_cleanupfile_$i"
				echo "Creating $name"
				set +e +u
				trap trapint 2 SIGTSTP
				dd count=250000  if=/dev/zero of="$name"
				;;
				1) #rand was odd
				name="$folder/_cleanupfile_$i"
				echo "Creating $name"
				set +e +u
				trap trapint 2 SIGTSTP
				dd count=250000 if=/dev/urandom of="$name"
				;;
				esac
			a=$?
			done
			sync; sync
			rm -r "${f}/_clean_"
			sync; sync
			drop_ok

		done
	done
;;
esac		

echo -e '\t \t \t \t \E[32mdone'; tput sgr0 

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

###functions end here

FS=$*
${FS:="/"} 2> /dev/null #if no argument is given, / is assumed
check_root

exit 0
