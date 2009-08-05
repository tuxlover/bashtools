#!/bin/bash


teste2 ()
{
while true
do
read_key
echo "hello"
done
}

read_key ()
{
read -t 1 -n 1 -s KEYPRESS
${KEYPRESS:="false"}

case $KEYPRESS in
[q]) exit 0
;;
*) teste2
;;
esac  
}

teste2


exit 0