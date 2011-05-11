#!/bin/bash

#This Script is the opensuse way of adduser
#the  interactive script for adding new users to the system

#it asks for each value and checks given parameters

#!!DO NOT USE THIS SCRIPT IN A PRODUCTIVE ENVIRENMENT!!
#

#name for new user
user_name()
{
${NEW_USER:="0"} 2> /dev/null

#get usernames which are allready taken
TAKEN_USERS=$(awk -F: '{print $1}' /etc/passwd)

while [ "$NEW_USER" == "0" ]
	do
		
		#should not be longer than 8 characters in heterogen environments
		read -e -n 8 -p "Enter Name for new User ..." NEW_USER
		clear
		if [ $NEW_USER == "root" ]
			then
				echo "root cannot be used"
				NEW_USER="0"
		fi
		
		#We find usernames allready in use
		for u_taken in ${TAKEN_USERS[@]}
			do
				if [ $u_taken == $NEW_USER  ]
					then
						echo "This username is allready taken."
						echo "choose a different name"
						NEW_USER="0"
						break
				fi
			done
		#Todo: special characters should be not allowed in username
		${NEW_USER:="0"} 2> /dev/null
	done

}

#group name for new user
group_name()
{
${NEW_GROUP:="0"} 2> /dev/null

#get groupnames allready taken
TAKEN_GROUPS=$(awk -F: '{print $1}' /etc/group )

#this bollean variable holds whether we need a new group
ADD_NEW_GROUP="y"

while [ "$NEW_GROUP" == "0" ]
	do
		read -e -n 8 -p "Enter Name of the group for $NEW_USER ..." NEW_GROUP
		clear
		#root is not allowed
		if [ $NEW_GROUP == "root" ]
			then
				echo "root cannot be used."
				NEW_USER="0"
		fi

		#we find groupnames allready taken
		for g_taken in ${TAKEN_GROUPS[@]}
			do
		
				if [ $g_taken == $NEW_GROUP ]
					then
						ADD_NEW_GROUP="n"
						break
				fi
			done

		if [ $ADD_NEW_GROUP == "y" ]
			then
				echo "groupadd $NEW_GROUP"
				echo "new group $NEW_GROUP added to /etc/group file"
		fi

		${NEW_GROUP:="0"} 2> /dev/null
		#Todo: special characters should be not allowed in groupname
	done


}

#home directory for new user
home_dir()
{
${HOME_DIR:="0"} 2> /dev/null

while [ "$HOME_DIR" == "0" ]
	do
		read -e -n 255 -p "Enter home directory for user $NEW_USER ..." HOME_DIR
		clear
		
		#Variable to check if we are really creating home directory in /home/
		IS_IN_HOME=$(echo $HOME_DIR|grep '^\/home\/[[:alnum:]].*$' || echo "no") 2> /dev/null
		
		#since we have a sepperated /home partition we do not
		#allow /home directories to be stored elsewhere
		if [ $IS_IN_HOME == "no" ]
			then
				echo "You must choose a valid directory under the /home tree."
				HOME_DIR="0"
		fi
		${HOME_DIR:="0"} 2> /dev/null
	done

}

#shell for new user
user_shell()
{
echo "Give The Loginshell for $NEW_USER ..."
echo "These are the allowed shells."
#valid shells from /etc/shells
VALID_SHELLS=$(cat /etc/shells)
counter=0
#check for valid shells and print them
for shell in ${VALID_SHELLS[@]}
	do

		if [ -f $shell ] 
			then

				counter=$((counter+=1))
				echo "( $counter ) $shell"
		fi	

	done
#Tdodo: Only valid shells for login are allowd
}



#additional set expiration date
expire_date()
{
	read -n 1 -p "Do you want to set a date where account for $NEW_USER expires?" ANSWER
	${ANSWER:="n"} 2> /dev/null
	clear

	if [ "$ANSWER" == "y" ]
		then

			read -n 4 -p "Year when the account for user $NEW_USER expires ..." EXPIRE_YEAR
			clear
			#Todo: how to force read exactly accept only 4 characters and these only numerical
			
			read -n 2 -p "Month of Year when the account for user $NEW_USER expires ..." EXPIRE_MONTH
			clear
			#Todo: accept only numerical values
			#Todo: check if this in the range from 01 to 12

			read -n 2 -p "Day of Month when the account for user $NEW_USER expires ..." EXPIRE_DAY 
			clear
			#Todo: accept only numerical values
			#Todo: check if this in the range from 01 to 31

			#Todo: Check if Month exists
			#For Example there is no 2008-02-31

		EXPIRE_DATE=$EXPIRE_YEAR-$EXPIRE_MONTH-$EXPIRE_DAY
		#Todo: Test whether the string is complete
		fi

#Todo: Howto test wheter EXPIRE_DATE has the form YYYY-MM-DD
}



#bash first reads in all functions
#it does not know a function before they are read in
#so the firstly called function has to be on the button
#checking for root
root_check()
{
if [ "$UID" !=  "0" ]
	then
		echo "not root"
		exit 1
	else
		user_name
		group_name
		home_dir
		user_shell
		expire_date
fi
}


root_check
echo $NEW_USER
echo "$NEW_GROUP"
echo $HOME_DIR
echo $EXPIRE_DATE

#bug:shell selection does not work yet

##Todo:
# User Selection (done)
# Group Selection (done)
# Home Dirctory Selection (done)
# Shell Selection (work in progress)
# Expiration Date (work in progress)
# Passwort Selection (need ideas)
# erweitere Konfiguration /etc/shadow (not implemented)
# users Comment (not implemented)

# should be ask for advanced , detailed or basic setup
# basic setup should ask for users name and his passwort only
# it then sets up the user by suse standard mask
# detailed setup should ask for users name password group and shell home (not implemented)
# advanced setup should aks all possible questions
