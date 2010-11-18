#!/bin/bash

number=$1

Bin_Array=(128 64 32 16 8 4 2 1)

if [ $number -gt "256" ]
	then
		echo "out of range"
		exit 1
fi
	
t=0
for n in ${Bin_Array[@]}
	do
		if [ $number -ge $n  ]
		then
			number_Array[$t]=1
			number=$((number-$n))
		else
			number_Array[$t]=0	
		fi
		t=$(($t+1))
	done


echo ${number_Array[@]} 

exit 0
