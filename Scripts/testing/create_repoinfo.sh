#!/bin/bash

#Script that generates an rpm-list which can be parsed by yast afterwards

DOC_NAME=$1


check_arg()
{
echo "Checking for arguments."

if [ -z "$DOC_NAME" ] #because DIR is the same as $*, DIR will be null if no arguments given, and therfore the -z will be true and exits the script with error code NO_ARGS.
	then
	drop_failure
	echo "XML file must have a name. Usage: `basename $0` \"<NAME_OF_XML_FILE>\""
	exit 1
	else
	drop_ok
	check_rpm
fi
	
}

check_rpm()
{
echo "Checking for rpm"
	rpm --test || drop_failure
	drop_ok
	check_suse
	
}

check_suse ()
{
echo "verifying VENDOR ID of Opensuse"
	
	VENDOR=$(env|grep suse || echo "false")
	
	if [ "$VENDOR" == "false"  ]
		then
	
		echo -e '\E[33mWARNING: cannot find vendor ID for current using version of opensuse.'; tput sgr0
		echo -e '\E[33mThis means either this is not an opensuse Distribution or you are not using the default root-tree'; tput sgr0
		echo -e '\E[33mMaybe you just chrooted to an othoer root-tree.'; tput sgr0
		echo -e '\E[33mIf this is not an opensuse Distribution you may destroy your system when parsing this xml with yast'; tput sgr0
			
			read -n 1 -p "Continue anyway y/n" ANSWER #the scrip does not finish here, why?
			${ANSWER:=1} 2> /dev/null
				case $ANSWER in
				*) echo "please press y or n"
					;;
				y):
					;;
				n) echo "exiting script"
					exit_script
					;;
				esac	
			
		main
		else
		echo "found $VENDOR"
		drop_ok
		main
	fi
 	
}


main() #main function
{
echo "Starting please be patient"
RPMS=$(rpm -qa)




echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> $DOC_NAME.xml
echo "<syscontent>" >> $DOC_NAME.xml
echo -e "\t <ident>" >> $DOC_NAME.xml
echo -e "\t\t <name></name>" >> $DOC_NAME.xml
echo -e "\t\t <version epoch=\"0\"/>" >> $DOC_NAME.xml
echo -e "\t\t <description></description>" >> $DOC_NAME.xml
echo -e "\t\t <created>1234667821</created>" >> $DOC_NAME.xml #unixtimestamp may be generatet by timestamp
echo -e "\t </ident>" >> $DOC_NAME.xml
echo -e "\t <onsys>" >> $DOC_NAME.xml

for i in $RPMS

	do
		NAME=$(echo $(rpm -q $i --qf %{NAME}))
		VERSION=$(echo $(rpm -q $i --qf %{VERSION}))
		RELEASE=$(echo $(rpm -q $i --qf %{RELEASE}))
		ARCH=$(echo $(rpm -q $i --qf %{ARCH}))
		echo -e "\t\t <entry kind=\"package\" name=\"$NAME\" epoch=\"0\" ver=\"$VERSION\" rel=\"$RELEASE\" arch=\"$ARCH\"/>" >> $DOC_NAME.xml
	done

echo -e "\t </onsys>" >> $DOC_NAME.xml
echo "</syscontent>" >> $DOC_NAME.xml
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


XML_error ()
{
echo -e '\t \t \t \ŧ \E[31mThere is an error in XML File'; tput sgr0
exit 1
}

exit_script ()
{
	exit 0
}

if [ -f $DOC_NAME.xml ]
	then 
	rm $DOC_NAME.xml
fi
check_arg


xmllint $DOC_NAME.xml || XML_error
echo -e '\t \t \t \ŧ \E[32mFile successfully created'; tput sgr0

exit 0
