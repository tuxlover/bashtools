#!/bin/bash
#all_users_ps

#This script shows how to get around the problem that the ps output in scripts apears multiple times when
#users is read
#declare -a USERS=$(users)
USERS[0]=root
USERS[1]=matthias
USERS[2]=matthias
USERS[3]=root

k=0
for i in ${USERS[@]}
do

  if [ $i != $k ]
  then
  echo $i
  sleep 5
  ps -U $i
  k=$i
  fi

done

