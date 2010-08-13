#!/bin/bash


echo "found this processes with $1 in its name. choose"

#PID_P holds number of allprozesses
#tr "\n" "\ " converts newline to space and therefore converts this construct into an array
PID_P=$(ps -A -o pid,cmd|grep -i $1|grep -v grep|awk '{print $1}'|tr "\n" "\ ")
NAME_P=$(ps -A -o pid,cmd|grep -i $1|grep -v grep|awk '{print $2}'|tr "\n" "\ " )


i=0
for p in ${NAME_P[@]}
	do
		echo "($i) $p"
		array1[$i]=$p
		i=$(($i+1))
	done

j=0
for q in ${PID_P[@]}
	do
		array2[$j]=$q
		j=$(($j+1))
	done

echo "Which program should be terminated."
read -e -p "enter the number of the Programm you want to kill" ANSWER
echo $ANSWER

echo ${array1[$ANSWER]}
echo ${array2[$ANSWER]}

exit 0


#todo: irgnore listing bash inwhich the script itself runs
