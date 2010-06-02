#!/bin/bash

#this script implements the debian method of retrieving all installed
#packages. it then downloads them  and packs them in tar.bz2 format

mkdir /tmp/save_packages
#creating a direcotry save_packages in  /tmp/ holding the apt.sources list
#and the downloaded packages.

cp -rv --parents /etc/apt /tmp/save_packages
#saving the  current apt configuration
# the --parents switch ensures that the whole path is copied

cp -rv  --parents /var/cache/apt/ /tmp/save_packages
#saving the current  apt-cache 
#Todo: skip /var/apt/cache

INST_P=$(dpkg -l |awk '{print $2}') #returns an array each element  holding
#a valid installed package
#awk use to get only the names of packages
#Todo: truncate unneccary pattern string in the beginning

for p in $INST_P
	do
		#if [-f ] #we should test whether the package allready in
		#cache to save time
	
	apt-get install --reinstall -d  --force-yes -y $p
	done
#this downloads all installed package to /var/cache/apt/archives
#so we can grep them later

