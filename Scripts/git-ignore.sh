#!/bin/bash

# a little bash script that makes it easier to handle git ignore lists
#state git-ignore

if [ -z $1 ]
	then
		echo "must have an argument"
		exit
fi

if [ ! -d .git ]
	then
		echo "not in a git repository"
		exit 1
fi

if [ ! -f .gitignore ]
	then
		echo "no ignorelist found in git repository"
		echo "creating one"
		echo ".gitignore" >> .gitignore
fi

ls $1 >> .gitignore

exit 0
