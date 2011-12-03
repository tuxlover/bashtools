#!/bin/bash


input=$1
input_array=(32 16 8 4 2 1 0)


for i in ${input_array[@]}
	do
		if  [ $input -eq $i ]
			then
				echo "$input"
				break
		elif [ $input -gt $i  ]
			then 
				input=$((input - $i))
				echo $i
		fi

	done




