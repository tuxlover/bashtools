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



FAKE=$(which macchanger)

get_args()
{
lines=$(cat /etc/udev/rules.d/*persistent-net.rules|awk '/NAME=\"/{print $8}'|cut -d= -f 2|wc -l)
index=0
while [ $lines -gt 0 ]
	do	
		
		devices[$index]=$(cat /etc/udev/rules.d/*persistent-net.rules|awk '/NAME=\"/{print $8}'|cut -d= -f2|head -$lines|tail -1|cut -d\" -f2)
		lines=$((lines-=1))
		index=$((index+01))
	done

export devices
}

fake_start()
{
#save current status of macchanger so when stopped the default is restore
for d in ${devices[@]}
	do
		echo "$d:"
		${FAKE} -r $d	
		#FIX: every mac shouly2yd have a different mac adress
		sleep 1
	done	
	
#creating an indicator file
touch /var/run/fakedmac
				
}

fake_stop()
{
for d in ${devices[@]}
	do      
		echo "$d:"
		#getting the old AMC from udev persistent-net-rules
		old_mac=$( grep $d /etc/udev/rules.d/*persistent-net.rules|awk '{print $4}'|cut -d'=' -f3|cut -d\" -f2)
		${FAKE} -m $old_mac $d
	done

#removing the indicator file
rm /var/run/fakedmac
}

fake_reload()
{
#reload just gives a new faked mac
for d in ${devices[@]}
		do
			echo "$d:"
			${FAKE} -r $d
		#FIX: every mac shouly2yd have a different mac adress
		sleep 1
		done
}

macstate()
{
#checking for indicator file
if [ -f /var/run/fakedmac  ]
	then
		echo -e '\E[32mAll MACS faked';tput sgr0
	else
		echo -e '\E[33mNo MAC is faked';tput sgr0
fi

for f in ${devices[@]}
	do
		echo "$f:"
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


get_args

case "$1" in
	"start") 
		 
	fake_start || opps
	all_faked || oops
	;;
	"stop") fake_stop && all_unfaked || oops
	;;
	"status") macstate && exit 0
	;;
	"restart") 
		
				if [ -f /var/run/fakedmac ]
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

