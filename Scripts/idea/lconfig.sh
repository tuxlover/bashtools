#!/bin/bash

#lconfig is a script to simple put or change 
#a file into local git repositroy


local_git_init()
{
#Todo:
#Check whether git repo is already present
#Check whether file belongs to user

#Todo:
#we need to cd into the repository and if this was not created we dont need to test

cd $HOME/.local_gitrc &> /dev/null
IS_GIT=$(git status -s $HOME/.local_gitrc && echo "yes" || echo "no" )

if [[ -d $HOME/.local_gitrc && $IS_GIT == "yes" ]]
	then
		echo "the local git repository already exists"
		exit 1
	else
		mkdir $HOME/.local_gitrc || echo "W: The direcory for the git repositrory already exists."
		git init --shared=false $HOME/.local_gitrc
fi
}




help_me()
{
echo "lconfig - Script to manage a local git repository"
echo "-a: Add a file for the first time to the git repository."
echo "-r: remove a file from the git repository"
echo "-c: commit changes from a file to git repositroy"
echo "-i: init a new local git repository for user"
}

#begin options
while getopts "hia:c:r:" opt
	do
		case $opt in
			   h) help_me
				;;

			   i) 	local_git_init
		      		;;
		   			
			   a) local_git_add
	   			;;

     			   c) local_git_remove
   				;;

			   r) local_git_remove
   				;;

			   *) help_me
		esac

	done
shift $(($OPTIND -1 ))

#-a add
#-r remove
#-c commit
#-e edit a local file
#-i init
#Todo:
#test whether git is installed
#-s show whats has  been commited to the git repository
