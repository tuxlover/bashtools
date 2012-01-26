#!/bin/bash
#This Script provides a simple way to maintian a todo list.

BAK=$HOME/.todo.lst.bak
TODO_LIST_FILE=$HOME/.todo.lst


backup_list()
{
cp -u $TODO_LIST_FILE $BAK	
}

restore_list()
{
if [ ! -e $BAK ]
	then
		echo "I am sorry. There is no backupfile."
		echo "Next time create one by using -B before messing something up."
	else
		cp -u $BAK $TODO_LIST_FILE
fi
}


test_line()
{
for c in ${check_args[@]}
	do 
		if [ ! $(echo "$c" | grep -E "^[0-9]+$") ]
			then
				echo "NAL: $c is not a line"
				exit 1
		fi



		LINE=$(nl $TODO_LIST_FILE|awk '{print $1}'|grep -E ^${c} 2> /dev/null || echo "NAL")
		if [ "$LINE" == "NAL"  ]
			then
				echo "NAL: $c is not a line"
				exit 1
		fi
	done
}

add_entry()
{
if [ ! -f $TODO_LIST_FILE ]
	then
		echo "$TODO_LIST_FILE was not created yet."
		touch $TODO_LIST_FILE
		echo "created new todo list file in $TODO_LIST_FILE"
fi
NEW_ENTRY=$(echo "$OPTARG $args")
echo "$NEW_ENTRY --> [o]" >> $TODO_LIST_FILE
}


show_done()
{
echo -e "\E[32m Done Tasks:"
set -o pipefail
nl $TODO_LIST_FILE|grep '[[:blank:]]\-\->[[:blank:]]\[x\]$' 2> /dev/null || echo "no entries marked as done"
set +o pipefail 
tput sgr0
}

show_open()
{
echo -e "\033[1m Open Tasks:"
set -o pipefail
nl $TODO_LIST_FILE|grep '[[:blank:]]\-\->[[:blank:]]\[o\]$' 2> /dev/null || echo "no entries marked as open" 
set +o pipefail
tput sgr0
}

show_list()
{
if  [ ! -s $TODO_LIST_FILE ]
	then
		echo "There is currently no entry in your todo list."
	else

show_open
show_done
fi
}

modify_entry()
{
check_args=${OPTARG}
test_line
#first read in the entry by using sed and get it into a variable
#Since the last two records of field are the markers, shorten the NF variable will cut off the markers
ENTRY="$(sed -n ${OPTARG},${OPTARG}p $TODO_LIST_FILE|awk '{NF=NF-2;print $0}')"
ORIG_ENTRY=$ENTRY

#use the entry itself with -i and write back to the entry
read -e -i "${ENTRY[*]}" ENTRY

sed -i ${OPTARG},${OPTARG}s_"${ORIG_ENTRY}"_"${ENTRY}"_ $TODO_LIST_FILE
}


mark_entry()
{
#TODO:
#check whether entry is marked corectly

#we are setting a new variable
args_x=$(echo "$OPTARG ${args[*]}")	
check_args=$(echo "${args_x[*]}")
test_line
#loop over the entries
for i in ${args_x[@]}
	do
		sed -i ${i},${i}s_'\[o\]'_'\[x\]'_ $TODO_LIST_FILE 
		head -n $i $TODO_LIST_FILE|tail -1
		ENTRY="$(sed -n ${i},${i}p $TODO_LIST_FILE)"
		sed -i ${i},${i}d $TODO_LIST_FILE
		echo "${ENTRY[*]}" >> $TODO_LIST_FILE					
	done
}

unmark_entry()
{
#TODO: 
#check whether entry is marked corectly

#we are setting a new varibale
args_u=$(echo "$OPTARG ${args[*]}")
check_args=$(echo "${args_u[*]}")
test_line

#loop over the entriess
for i in ${args_u[@]}
	do
		sed -i ${i},${i}s_'\[x\]'_'\[o\]'_ $TODO_LIST_FILE 
		head -n $i $TODO_LIST_FILE|tail -1
	done
}

remove_marked()
{
#tests whether we have an entry marked as done
if [ ! -s $TODO_LIST_FILE ]
	then
		echo "no entry in your todo list"
		exit 1
	else
		HAS_DONE=$(grep '[[:blank:]]\-\->[[:blank:]]\[x\]$'  $TODO_LIST_FILE || echo "no")
		
		if [ "$HAS_DONE" == "no" ] 
			then	
				echo "no entries marked as done"
				exit 1
		fi
fi

sed -i '/.* --> \[x\]/d' $TODO_LIST_FILE
}

help_me()
{
echo "$0 is a script for easyly maintianing a todo list"
echo "-a: add a new entry to the todo list. Example: todo -a \"write an entry\""
echo "-s: show all the entries in the todo list. (default if no option was passed)" 
echo "-o: show all open entries in the todo list [o]"
echo "-d: show all entries marked as done  [x]"
echo "-m: modify an entry"
echo "-r remove entries from the todo list which are marked as done [x]"
echo "-u unmark an entry as done. Example: todo -u 3 will mark the entry number again as undone"
echo "-x: mark an entry as done. Example: todo -x 3 will mark the entry number 3 as done."
echo "-p: purge the todo list, remove all entries from the todo list"
echo "-pp: purge and remove the .todo.lst file"
echo "-h: show this help"
echo "-B: make a backupcopy of your current todo list"
echo "-R restore the copy from your backupcopy if you have one"
}

#begin options

#when no option was passed, show all entries in the list
if [ -z $1  ]
	then
		show_list
fi



if [ $1 == "-p"  ] 2> /dev/null
	then
		if [ -f $TODO_LIST_FILE  ]
			then
				:> $TODO_LIST_FILE
				exit 0
		fi
elif [ $1 == "-pp"   ] 2> /dev/null
	then
		if [ -f $TODO_LIST_FILE  ]
			then
				rm $TODO_LIST_FILE
				exit 0
		fi
else


	while getopts "dhorsBRa:m:u:x:" opt
		do
			case $opt in 
				a) 	#use this construct if you want parsing more then one argument to this option
			        	#is needed to avoid using "" 
					#we need to breake her so later on the OPTIND variable gets not decreased
					#this would cause an error	
					shift $((OPTIND -1 ))
					#read in this arguments during function call
					args=$(echo $*)
					add_entry
					break
					;;
				d) show_done
					;;
				h) help_me
					;;
				o) show_open
					;;
				m) modify_entry
					;;
				r) remove_marked
					;;
				s) show_list
					;;
				u)	#like the add option
					shift $((OPTIND -1 ))
					args=$(echo $*)
					unmark_entry
					break
					;;
				x)	#like the add option
					shift $((OPTIND -1 ))
					args=$(echo $*)
					mark_entry
					break
					;;
				B) backup_list
					;;
				R) restore_list
					;;
				*) help_me
			esac
		done
	shift $(($OPTIND - 1))	

fi

exit 0

# BUGS: 
# When passed !! as an argument the script will excecute the last command in bash an tail this command
# Marking multiple lines as done is broken. instead the line gets marked twice.

# TODO: disable the noclobber option if this was enabled
# calling two or more options at once does not make any sense	
# give tasks a priority and sort them regarding to their priority
# get done entries to the bottom of the list and undone back up to the head 
# option:
# -s can only use to show just lines matching a pattern
# check whether an entry exists. first check for noninteger values in users input than check wheterh such line exists

###Feature Request by SadoneY:
#highlight the importence of entries by using different collors:
#done entires are colored and shown in green normal and flagged with -x
#open normal entries with no priority are uncolered and bold [o]
#open important entries are colored yellow and bold and flagged with -i [i]
#open very important entries are colored red and bold and flagged with -I [I]
#unmark entries like allways with -u
#Show important with -e only importent and -E only important and very important
#than sort them in this apperance I i o x or show them in reverse order -S
