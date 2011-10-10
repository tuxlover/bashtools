#!/bin/bash
#sysprof
#this script will profile and benchmark your system


##VARS
CPU_CORES=$(cat /proc/cpuinfo |grep "model name"|wc -l)
CPU_TYPE=$(grep -m 1 "model name" /proc/cpuinfo | sed 's/^.*: //g')

TOTAL_MEM=$(free -m -o| awk '{print $2}'|head -2|tail -1)
USED_MEM=$(free -m -o| awk '{print $3}'|head -2|tail -1)
FREE_MEM=$(free -m -o |awk '{print $4}'|head -2|tail -1)
CACHED_MEM=$(free -m -o |awk '{print $7}'|head -2|tail -1)
##VARS


computer_info()
{
##Variables that holds the information
	
echo "## Your Computer ##"
echo "Summary"
echo "-------"
echo "--> Computer"
echo "CPU: 		$CPU_CORES x $CPU_TYPE"
echo "Memory:	$TOTAL_MEM MB ($USED_MEM MB)"
echo "Operating System:		" #howto get this information out of the machine

}

computer_info

exit 0


#show all installed modules and there coresponding functions
#+Operating System
#+User Name
#+Date and Time
#-->Display
#+Resolution
#+OpenGL Renderer
#+X11 Vendor
#-->Multimedia
#+AudioAdapter
#+Codecs
#--> Input Devices
#+PC Speaker
#+Power Button (FF)
#+Power Button (CM)
#+Keyboard
#+Mouse
#--> Printers
#+LPD0
#--> SCSI Disks
#+internal
#+external

#Operating System
#-----------------
#--> Version
#+Kernel
#+Compyiled Machine
#+Compiled C library 
#+default C compiler
#+Dsitribution
#--> Current Session
#+Computer Name
#+User Name
#+Home Directory
#+Desktop Environment
#--> Misc
#+Uptime
#+Load Average

#Kernel Modules
#--------------

#Boot-Information
#----------------

#Installed Languages
#-------------------

#Filesystems
#-----------
#freesoace/used space

#Display
#-------
#parse /etc/X11/xorg.conf

#Environment Variables
#---------------------
#all environment variables

#Users and Groups
#----------------
#parse /etc/group
#parse /etc/passwd

#Prozesses
#---------
#-> treeview
#-> top 5
#-----------------
##Devices
#CPU
#----
#--> Name
#--> Count
#Memory
#------
#Memory free/used/buffered
#PCI Devices
#-----------
#list PCIdevices
#USB Devices
#----------
#list USB Devices

#Printers
#--------
#battery
#-------
#Sensors
#-------
#--> cpu temp
#--> hddtemp
#--> gputemp
#BIOS
#---
##Network
#Interfaces
#----------
#IP-Adresses and Ports
#---------------------
#Routing-Tables
#--------------
#Servers
#-------
#Stats
#-----
#Dirs
#----
#-->SAMBA
#-->NFS
##Benchmark
#CPU Blowfish
#CPU Cryptohash
#CPU Fibonacci
#FPU FFT
#John Walkers


#if a test fails because there the used programm is not installed print 
#a warn and info message
#create a logfile
#work with spaces 
