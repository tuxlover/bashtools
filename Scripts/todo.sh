#!/bin/bash
#This Script is just a idea so far.

#I think whats really needed is a script that makes it easy to create (todo -c) 
#and manage a project todo list.

#By managing i mean adding new Entries -a
#removing closed entries -r
#mark entries as done -x
##show list -s
#show open task -o
#entries are listed by issue numbering

#an example ho it could work

#todo -c
#created todolist for user mark
#todolist for user mark allready exists. leaving it untouched
#todo -s 
#there is no entry in your todolist yet
#todo -a "write a entry"
#todo -s
#DATE ISSUE1 write an entry [o]
#todo -a "write an other entry"
#todo -x 1
#marked ISSUE 1 as done
#todo -o
#DATE ISSUE2 write an other entry
#todo -s
#DATE ISSUE1 write an entry [x]
#DATE ISSUE2 write an other entry [o]
#todo -s U 
#DATE ISSUE write an other entry
#tddo -r 
#Removed ISSUE1 from your todolist


#more suggestions are welcome
TODO_LIST_FILE=$HOME/.todo.lst


create_list()
{
if [ ! -f $TODO_LIST_FILE ]
	then
		touch $TODO_LIST_FILE
fi
}


add_entry()
{
#TODO: test for "" at beginning and end of the note
if [ ! -f $TODO_LIST_FILE ]
	then
		echo "$TODO_LIST_FILE was not created yet."
		read -e -t 10 -n 1 -p "Do you want to create this file now y/n" ANSWER
		${ANSWER:=n} 2> /dev/null

		if [ $ANSWER == "y" ]
			then
				touch $TODO_LIST_FILE
			else
				echo "Use -c option to create the file for the todo list."
				exit
		fi
fi
NEW_ENTRY=$(echo ${OPTARG[@]})
echo "$NEW_ENTRY --> [o]" >> $TODO_LIST_FILE
}


show_done()
{
nl $TODO_LIST_FILE|grep '[[:blank:]]\-\->[[:blank:]]\[x\]$'
}

show_open()
{
nl $TODO_LIST_FILE|grep '[[:blank:]]\-\->[[:blank:]]\[o\]$'
}

show_list()
{
#TODO: test for empty list	
nl $TODO_LIST_FILE

}

mark_entry()
{
#TODO:
#check for OPTARG to be an array
#check for OPTARG to be an valid entry
#mark more than one 
sed -i ${OPTARG},${OPTARG}s_'\[o\]'_'\[x\]'_ $TODO_LIST_FILE
head -n $OPTARG  $TODO_LIST_FILE |tail -1

}

remove_marked()
{
#TODO:
#how to do that with sed
#test for undone entires and for entires at all
BAK=$HOME/.todo.lst.bak

cat $TODO_LIST_FILE |grep '[[:blank:]]\-\->[[:blank:]]\[o\]$' >> $BAK 
rm $TODO_LIST_FILE
cat $BAK >> $TODO_LIST_FILE
rm $BAK
}

help_me()
{
echo "$0 is a script for easyly maintianing a todo list"
echo "-c: create the todo list file if its not exist. the script will not remove existing files"
echo "-a: add a new entry to the todo list. Example: $0 -a \"write an entry\""
echo "-s: show all the entries in the todo list." 
echo "-o: show all open entries in the todo list [o]"
echo "-d: show all entries marked as done  [x]"
echo "-r remove entries from the todo list which are marked as done [x]"
echo "-x: mark an entry as done. Example: $0 -x 3 will mark the entry number 3 as done."
echo "-h: show this help"
}

#begin options
while getopts "cdhorsa:x:" opt
	do
		case $opt in 
			a) add_entry
				;;
			c) create_list
				;;
			d) show_done
				;;
			h) help_me
				;;
			o) show_open
				;;
			r) remove_marked
				;;
			s) show_list
				;;
			x) mark_entry

		esac
	done
shift `expr $OPTIND - 1`	

#TODO: the -c option is not neccesary
#TODO: disable the noclobber option if this was enabled
