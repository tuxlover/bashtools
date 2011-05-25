#!/bin/bash

#this script should be used with udev rules and the RUN directive
#whenever a external drive is mounted

DEVICE=$(/dev/sdb1)


notify_virus()
{
inotify -wall "We found a virus on the stick. will not mount until removed"

exit 1
}


#create a mount point if its not already created
if [ !-d  /media/share  ]
	then
		echo "creating non existing directory"
		mkdir /media/share
fi

#next we should mount the filesystem readonly and noexec so we can scan the filesystem
#for viruses if we find some we should be able to inform the user using libnotify
mount -o ro nodev noexec /dev/sdb1 /media/share
clamscan -ri  || notify_virus

remount -o remount rw defaults /dev/sdb1 /media/share


