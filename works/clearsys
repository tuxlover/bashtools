#!/bin/bash
#clearsys


##functions begin here

root_check()
{
if [ $UID -ne 0 ]
then
SEARCH_PATH=$HOME
SEARCH_PATH2=$HOME
else
SEARCH_PATH=( /usr /home /etc /opt /var /root /mnt /media )
SEARCH_PATH2=( /bin /etc /home /lib /media /mnt /opt /root /sbin /srv /usr /var )
fi
}

#search functions begin here
all_actions() #proceed all actions -a same as no option
{	
	root_check
	echo  -e '\E[32mThese temporary files have been found:'; tput sgr0
	
	for i in ${SEARCH_PATH[@]}	
	do 
		find $i -type f -name *.tmp -o -name *.temp -o -name *~
	done
	
	echo -e '\E[32mThese old rpmsave files have been found'; tput sgr0
	
	for i in ${SEARCH_PATH[@]}
	do
		find $i -type f -name *.rpmsave
	done

	echo -e '\E[32mThese are probertly broken symbolic links but should be inspeted afterwards'; tput sgr0

	for j in ${SEARCH_PATH2[@]}
	do 
		find $j -type l -print0| xargs -r0 file| grep "broken symbolic"| sed -e 's/^\|: *broken symbolic.*$/"/g'
	done
	
	exit 0 
}

interactive_actions() #finds and deletes temporary files -i
{
		root_check
		
		echo -e '\E[33mDo you want to delete finayly'; tput sgr0
		
		for i in ${SEARCH_PATH[@]}
		do
			find $i -type f -name *.tmp -ok rm {} \;
			find $i -type f -name *.temp -ok rm {} \;
			find $i -type f -name *~ -ok rm {} \;
			find $i -type f -name *rpmsave -ok rm {} \;
		done
	
		exit 0
}


find_empty_dir() #finds empty dir -e
{
	root_check
	
	echo -e '\E[33m These are empty directories that may not be usefull any longer'; tput sgr0
	sleep 2
	
	for i in ${SEARCH_PATH[@]}
	do
		find $i -type d -empty
	done

	exit 0
}

find_temp() #finds tmp, and temp files -t
{
		root_check
		
		echo  -e '\E[32mThese temporary files have been found:'; tput sgr0
		
		for i in ${SEARCH_PATH[@]}
		do
			find $i -type f -name *.tmp -o -name *.temp
		done

		exit 0
}

find_rpmsave() #finds only rpmsave data -r
{
		root_check
		
		echo  -e '\E[32mThese .rpmsave files have been found:'; tput sgr0
		
		for i in ${SEARCH_PATH[@]}
		do
			find $i -type f -name *.rpmsave
		done

		exit 0
}


find_oldsaves() #finds files usaly created by editors -o
{
		root_check
		
		echo  -e '\E[32mThese oldsave ~ files have been found:'; tput sgr0
		
		for i in ${SEARCH_PATH[@]}
		do
			find $i -type f -name *~
		done

		exit 0
}


find_broken_links() #this function finds broken-links -l
{
	root_check
	
	echo -e '\E[32mThese are probertly broken symbolic links but should be inspeted afterwards'; tput sgr0

	
	for j in ${SEARCH_PATH2[@]}
	do
		find $j -type l -print0| xargs -r0 file| grep "broken symbolic"| sed -e 's/^\|: *broken symbolic.*$/"/g'
	done

	exit 0
}
#search functions end here

get_help() #displys help for this script -h
{
echo "$0 finds temporary files and cleans them from the system"
echo "-a: displays all .rpmsave, .tmp, .temp, oldsave ~ files and broken-links"
echo "-e: displays all empty directories"
echo "-h: print this help"
echo "-i: finds and deletes .rpmsave, tmp, temp and oldsaves interacitvely"
echo "-l: displays all broken links"
echo "-o: displays oldsaves only"
echo "-r: displays .rpmsave only"
echo "-t: displays .tmp and .temp only"

exit 0
}




while getopts aehilort opt
do 
	case "$opt" in
	a) all_actions
	;;
	e) find_empty_dir
	;;
	h) get_help
	;;
	i) interactive_actions
	;;
	l) find_broken_links
	;;
	o) find_oldsaves
	;;
	r)find_rpmsave
	;;
	t)find_temp
	;;
	esac
done
root_check; all_actions


##functions end here



exit 0




