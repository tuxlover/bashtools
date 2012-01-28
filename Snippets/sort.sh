#!/bin/bash

# bubblesort

array=(1 8 99 2 4 7 22 87 42 32 23 78 200 6 9 0)
echo ${array[@]}

k=1
for i in ${array[@]}
	do
		# k is the kth iteration and therefore is the kth index
		# comparing the kth element with the lenght of array is therefore like testing whether the end of the array was allready reached
		# if last ellement is reached the array is sorted therefore we can stop here
		if  [ $k -eq ${#array[@]} ]
			then
				break
		fi
			declare -i stop=${#array[@]} 
			
			for (( j=$((k-1)); $j < $stop; j=j+1 ))
				do

					# for ascending order use -lt
				        # for descending order use -gt	
					if [ ${array[$(($k-1))]} -gt ${array[$j]} ]
						then
							continue
						else
					#swap both elements when they are not in correct order
						a=${array[$(($k-1))]}
						b=${array[$j]}
						array[$((k-1))]=$b
						array[$j]=$a
					fi
				
				done
			k=$((k+1))	
	done

echo ${array[@]}
