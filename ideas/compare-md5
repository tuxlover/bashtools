#!/bin/bash

#compares data by parsing the md5sum file of the data
#calcuate md5 sum and compares it with the ones given in the md5sum file

#usage: comparemd5 <inputfile> <md5sumfile> 

if [ -z "$1" ]
then
echo "Not enough arguments given. Usage:`basename $0` <inputfile> <md5sumfile>"
drop_failure
else
main
fi

main ()

