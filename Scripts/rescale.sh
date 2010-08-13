#!/bin/bash

#rescale

#Script to easily mass rescale a collection of jpeg, bitmap or png pictures
#requieres ImageMagick

#Comes with the package Bash-Tools
#Ideas collected by Mendel Cooper (Advanced Bash Scripting Guide)
#Rewritten for opensuse 10.2 by Matthias Propst



#VARS
#VARS

###functions begin here

check_convert () #convert is a function for manipultating images. it comes with ImageMagick
{
VERSION=$(convert -version 2> /dev/null || echo "-" ) #checks for Image Magick

if [[ $VERSION == "-" ]]
then
echo "ImageMagick seemes not to be installed"
echo "Please install ImageMagick and rerun again."
echo "Script exits now."
drop_failure
exit 1
else
echo "found $VERSION"
drop_ok
check_arg
fi
}

#checks whether there is at least one argument passed to the script
check_arg ()
{
if [ -z  $PIC ] 2> /dev/null
then
echo "You must select at least one file "
echo "Usage: `basename $0` \"[jpeg] [bmp] [gif] [png] [tif]\" "
drop_failure
exit 1
else
echo "These Pictures have been selected for rescaling"

	for pic in $PIC
	do
	echo $pic
	done #echoing all files that have been found in the directory if * is given as arguments for example. 

drop_ok
geometry

fi
}

geometry ()
{
read -p "Please specify the new horizontal size:" HOR
read -p "Please specify the new vertical size:" VERT
check_geometry
}

#Check whether the input variables are valid integers
check_geometry ()
{
PIXEL=$(( $HOR * $VERT )) || PIXEL=0 #becasue HOR*VERT must be an integer > 0 this checks wheter you havent given a Integer based geometry and whether both HOR and VERT are greater than zero

	if [ $PIXEL -eq 0 ]
	then
	echo "$HOR"x"$VERT" "is not a geometirc size"
	drop_failure
	exit 1
	else
	main
	fi
}

#main fucntion does the action for what the script is for
main ()
{
for pic in $PIC
do
unset PICS_S
PICS_S=$(identify -verbose $pic|grep Geometry)  || PICS_S="-"

	if [ $PICS_S == "-" ] 2> /dev/null	
	then
	echo "$Image does not seem to have a valid format"
	echo -e '\E[33mskipped'; tput sgr0 ##this checks whether the file realy is an image.
	else
	unset OLD_GEO
	unset A
	unset OLD_HOR
	unset OLD_VERT
	unset OLD_PIXEL

	##strips out the information from the identify module of Image Magick
	#see Variable manipulation in Advanced bash scripting guid to understand
	OLD_GEO=$(echo ${PICS_S##* })
	A=$(echo ${OLD_GEO%%x*})
	declare -i OLD_HOR=$(echo ${A##* })
	declare -i OLD_VERT=$(echo ${PICS_S##*x})
	OLD_PIXEL=$(( $OLD_VERT * $OLD_HOR ))
	#see Variable manipulation in Advanced bash scripting guid to understand
		
		if [[ $PIXEL -ge $OLD_PIXEL ]] #this chceks whether the new rescaled picture will be smaller than the original one
		then
		echo "The image allready has $OLD_PIXEL pixel but you want to rescale to $PIXEL pixel, which is greater or equal to the original size."
		echo -e '\E[33mskipped'; tput sgr0 #skipped if this not so
		else
		convert $pic -verbose -scale "$HOR"x"$VERT" rescale_new-$pic
		fi
	
	fi
done
}

drop_ok ()
{
echo -e '\t \t \t \t \E[32mok'; tput sgr0
}

drop_failure ()
{
echo -e '\t \t \t \t \E[31mfailure'; tput sgr0
}

###functions end here

PIC=$*
#the identify module of image magick cheks all images in a given directory
#for there geometry
case $1 in
-i)
	for pic in $PIC
	do

	identify -verbose $pic 2> /dev/null |grep Geometry 2> /dev/null && ls $pic
	done
;;
*) check_convert #causes the script to do the main work
;;
esac

exit 0
