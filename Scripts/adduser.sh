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

while [ "$NEW_USER" == "0" ]
	do
		
		read -n 8 -p "Enter Name for new User ..." NEW_USER
		clear
		#should not be longer than 8 characters in heterogen environments
		#Todo: root is not alowed
		#Todo: special characters should be not allowed in username
		${NEW_USER:="0"} 2> /dev/null
	done

}

#group name for new user
group_name()
{
${NEW_GROUP:="0"} 2> /dev/null

while [ "$NEW_GROUP" == "0" ]
	do
		read -p "Enter Name of the group for $NEW_USER ..." NEW_GROUP
		clear
		${NEW_GROUP:="0"} 2> /dev/null
		#Todo: check if group does not exist, create it
		#Todo: root is not allowd
		#Todo: special characters should be not allowed in groupname
	done


}

#home directory for new user
home_dir()
{
${HOME_DIR:="0"} 2> /dev/null

while [ "$HOME_DIR" == "0" ]
	do
		read -n 255 -p "Enter home directory for user $NEW_USER ..." HOME_DIR
		clear
		#should not be longer than 255 characters on ext3 systems
		#Todo: since we have a sepperated /home partition we do not
		#allow /home directories to be stored elsewhere
		${HOME_DIR:="0"} 2> /dev/null
	done

}

#shell for new user
user_shell()
{
echo "Give The Loginshell for $NEW_USER .. "
echo "These are the allowed shells."
cat /etc/shells
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

#BUGS: when pressing the backspace or other keys than characters weird chacters like ? and apear
