#!/bin/bash

Bin_Array=(128 64 32 16 8 4 2 1)

User_Array=($1 $2 $3 $4 $5 $6 $7 $8)

seen="n"
t=0

malformed_input()
{
echo "malformed input"
echo "must be 8 bits of 0 and 1s"
exit 1
}



if [ $# -ne 8 ]
then
	malformed_input
fi

for w in ${User_Array[@]}
do
	if [[ $w -lt 0 || $w -gt 1 ]]
	then
		malformed_input
		exit 1
	
	fi


done

for u in ${User_Array[@]}
	do
		if [ $seen == "n"  ]
		then
			if [ $u -eq 1 ]
			then	
				decimal=${Bin_Array[$t]}
				seen="y"
			fi
		else
			if [ $u -eq 1 ]
			then
				decimal=$(($decimal+${Bin_Array[$t]}))
			fi
		fi
			
	t=$(($t+1))
	done

if [ $seen == "n"  ]	
then
	echo "0"
else	
	echo $decimal
fi
exit 0

#Fixme:
#test for valid integer
