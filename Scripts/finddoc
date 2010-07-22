#!/bin/bash

DOCUMENTS=(readme install howto authors news todo config sample example ref guide man quickstart thanks notes features faq acknowledgement bugs problem )
S_DOCUMENTS=(readme howto doc man)
#FIND=$1
SEARCH_PATH=(/usr/share/ /usr/local/ /usr/src/ /opt )

##functions begin here

#search functions begin here
normal_search()
{
FIND="$OPTARG"	
for i in ${DOCUMENTS[@]}
do

	for j in ${SEARCH_PATH[@]}
	do
	
	find $j -type f -iname *$i*$FIND* -o -type f -iname *$FIND*$i* 2> /dev/null #how to prevent the ugly permissinos denied output?
    find $j -type f -ipath *$i*$FIND* -o -type f -ipath *$FIND*$i* 2> /dev/null #A: redircet errors to /dev/null
	
	done

done

}

package_search() #-p packagesarch: search documents only for packages which are installed
{
FIND="$OPTARG"		
rpm -qad | grep $FIND
rpm -qd $FIND

}

speed_search() #-s speedsearch: only uses doc, howoto and man
{	
FIND="$OPTARG"	
for i in ${S_DOCUMENTS[@]}
do

	for j in ${SEARCH_PATH[@]}
	do
	
	find $j -type f -iname *$i*$FIND* -o -type f -iname *$FIND*$i* 2> /dev/null
	find $j -type f -ipath *$i*$FIND* -o -type f -ipath *$FIMD*$i* 2> /dev/null
	
	done 

done

}

extend_search() #-e extend search: matches keywords also in the matched documents itself 
{
FIND="$OPTARG"
for i in ${DOCUMENTS[@]}
do

	for j in ${SEARCH_PATH[@]}
	do
	
	find $j -type f -iname *$i*$FIND* -o -type f -iname *$FIND*$i* 2> /dev/null
	find $j -type f -ipath *$i*$FIND* -o -type f -ipath *$FIND*$i* 2> /dev/null
	find $j -type f -iname $i| grep $FIND 2> /dev/null
	find $j -type f -iname $FIND | grep $i 2> /dev/null
	
	done

done

}

lisah_search() #-l lisah_search: the machted keywords being printed in long format
{
FIND="$OPTARG"	
for i in ${DOCUMENTS[@]}
do
	
	for j in ${SEARCH_PATH[@]}
	do
	
	find $j -type f -iname *$i*$FIND* -ls -o -type f -iname *$FIND*$i* -ls 2> /dev/null
	find $j -type f -ipath *$i*$FIND* -ls -o -type f -ipath *$FIND*$i* -ls 2> /dev/null
	
	done

done

}

write_search() #-w writes the output to an outputfile
{
FIND="$OPTARG"	
echo "Give name for output."
echo "If no name is given output.txt is used"
read NAME
${NAME:=output} 2> /dev/null

for i in ${DOCUMENTS[@]}
do

	for j in ${SEARCH_PATH[@]}
	do
	
	A=$(find $j -type f -iname *$i*$FIND* -o -type f -iname *$FIND*$i* 2> /dev/null)
	B=$(find $j -type f -ipath *$i*$FIND* -o -type f -ipath *$FIND*$i* 2> /dev/null)
		
		for k in $A
		do
			echo $k >> $NAME.txt
			unset A
		done
		
		for l in $B
		do
			echo $l >> $NAME.txt
			unset B
		done
	
	done
	
done
}
#searh functions end here
get_help()
{
	echo "-e: extend search. matches keywords also in ascii text"
	echo "-l: lisah search. matches keywords like normal but prints more information like fileownership and size"
	echo "-n: normal search. matches keywords"
	echo "-p: matches keyword. only for installed packages"
	echo "-s: speed search. only matches readme howto man and doc"
	echo "-w: write search writes output to a file Xou will be asked for filename."

}

##functions end here

#normal_search

if [ -z $1 ]
then
echo "Usage: $0 [-e] [-l] [-n] [p] [s] [w] keyword. Use -h for help."
exit 1
fi

FIND=
while getopts e:l:n:p:s:w:h opt

do
    case "$opt" in
	  e) extend_search;;
	  h) get_help;;
	  l) lisah_search;;
      n) normal_search;;
	  p) package_search;;
	  s) speed_search;;
	  w) write_search;;
      \?) get_help::		# unknown flag
      	  echo >&2 \
	  "Usage: $0 [-e] [-l] [-n] [p] [s] [w] keyword. Use -h for help."
	  exit 1;;
    esac
done
shift `expr $OPTIND - 1`

exit 0

#improve runtime
#if name is a programs name the progam will start
#how to fix that
#how to make it only to find txt and html files
#no help implemented yet

#use find -exec grep "LOG" '{}' /dev/null \; -print for example
#if in Documents was matched not further surch has to be done
#use xargs instead of -exec to increase speed: example find . -name $1 | xargs -r grep bla
