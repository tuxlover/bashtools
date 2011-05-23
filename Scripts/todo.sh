#This Script is just a idea so far.

#I think whats really needed is a script that makes it easy to create (todo -c) 
#and manage a project todo list.

#By managing i mean adding new Entries -a
#removing closed entries -r
#mark entries as done -x
##show list -s
show open task -o
#entries are listed by issue numbering

#an example ho it could work

todo -c
created todolist for user mark
todo -s 
there is no entry in your todolist yet
todo -a "write a entry"
todo -s
DATE ISSUE1 write an entry [o]
todo -a "write an other entry"
todo -x 1
marked ISSUE 1 as done
todo -o
DATE ISSUE2 write an other entry
todo -s
DATE ISSUE1 write an entry [x]
DATE ISSUE2 write an other entry [o]
tddo -r 
Removed ISSUE1 from your todolist


#more suggestions are welcome
