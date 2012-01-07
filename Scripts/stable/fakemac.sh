#!/bin/bash 
#This startscript should be used to fake your macadress
### BEGIN INIT INFO
# Provides:          fakemac
# Required-Start:    $earlysyslog
# Required-Stop:     $network
# Default-Start:     3 5
# Default-Stop:      0 6
# Short-Description: fakemac providing a faked mac by macchanger
# Description:       Start machanger -r to allow changing mac and provide fake macadres
### END INIT INFO



devices=(eth0 wlan0 )
FAKE=$(which macchanger)

fake_start()
{
#save current status of macchanger so when stopped the default is restore
for d in ${devices[@]}
	do
		${FAKE} -s $d|cut -d" " -f3 > /root/.run/cur_${d}_mac 
		chattr +i /root/.run/cur_${d}_mac
		${FAKE} -r $d	
	done		
				
#creating an indicator file 
touch /root/.run/fakedmac
chattr +i /root/.run/fakedmac
}

fake_stop()
{
for d in ${devices[@]}
	do      
		unset OLD_MAC
		OLD_MAC=$(cat /root/.run/cur_${d}_mac)
		${FAKE} -m ${OLD_MAC} $d
		chattr -i /root/.run/cur_${d}_mac
		rm /root/.run/cur_${d}_mac
	done

#removing the indicator file
chattr -i /root/.run/fakedmac
rm /root/.run/fakedmac
}

fake_reload()
{
#reload just gives a new faked mac
for d in ${devices[@]}
		do
			${FAKE} -r $d
		done
}

macstate()
{
#checking for indicator file
if [ -f /root/.run/fakedmac  ]
	then
		echo -e '\E[32mAll MACS faked';tput sgr0
	else
		echo -e '\E[33mNo MAC is faked';tput sgr0
fi

for f in ${devices[@]}
	do
		${FAKE} -s $f
	done
}

all_faked()
{

echo "executing $0"
echo -e '\E[32mAll MACS faked'; tput sgr0
return 0
}

all_unfaked()
{
echo "executing $0"
echo -e '\E[32mResetting all MACS to default'; tput sgr0
return 0
}

#should never happen
#and indicates a bug in the script
oops()
{
echo "executring $0"
echo -e '\E[31mSomething went wrong'; tput sgr0
return 1
}

case "$1" in
	"start") if [ ! -d /root/.run ]
			then
				mkdir /root/.run
			fi
		 
	fake_start && all_faked || oops
	;;
	"stop") fake_stop && all_unfaked || oops
	;;
	"status") macstate && exit 0
	;;
	"restart") if [! -d /root/.run ]
			then
				mkdir /root/.run
		   fi
		
				if [ -f /root/.run/fakedmac ]
					then
						fake_stop && fake_start && all_faked || oops
					else
						fake_start && all_faked || oops
				fi
	;;
	"reload") fake_reload && all_faked || oops
	;;
	*) echo "I dont understand $1. Usage: $0  [start] [stop] [restart] [reload] [status]" && exit 1
esac
