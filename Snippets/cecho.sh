#!/bin/bash

#cecho.sh is a script by mendel cooper whcih makes colorizing much easier

#Deffining colors
black='\E[30m'; tput sgr0
red='\E[31m'; tput sgr0
green='\E[32m'; tput sgr0
yellow='E[33m'; tput sgr0
blue='\E[34m'; tput sgr0
magenta='\E[35m'; tput sgr0
cyan='\E[36m'; tput sgr0
white='\E[37m'; tput sgr0
bold='\E[1m'; tput sgr0

#setting alias Reset to tput
#alias Reset="tput sgr0"

##function cecho 

cecho ()
{

local default_msg="No message passed"

message=${1:-$default_msg} #defaulto default message
color=${2:-$black}        #Defaults to black

echo -e "$color"
echo "$message"

return
}

cecho "blue" $blue
cecho "magenta" $magenta
cecho "green" $green
cecho "red" $red
cecho "cyan" $cyan
cecho "black"
cecho "bold" $bold
cecho 

exit 0