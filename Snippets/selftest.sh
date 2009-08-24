#!/bin/bash

#selfintegrtety check

SHA_SUM=/var/log/selftest
FIRST_RUN=

option_f()
{
FIRST_RUN="yes"	
}


while getopts f opt
	do
		case "$opt" in
			f) option_f
			;;
			\?) echo "not an option"
		esac
	done
shift `expr $OPTIND - 1`

if [ -z $FIRST_RUN ]
	then
		FIRST_RUN="no"
fi

if [ ! -f $SHA_SUM/init/SHA_SUMS ]
	then
		echo "first run of $0. initilize sha512 checksums."
		mkdir -p $SHA_SUM/init
		{
			sha512sum $0
			sha512sum /usr/bin/clamscan
			sha512sum /usr/bin/freshclam
			sha512sum /usr/bin/lynis
			sha512sum /usr/bin/rkhunter
			sha512sum /bin/rpm			
		} >> $SHA_SUM/init/SHA_SUMS
		#imutable the SHA_SUMS because this is the weakest part of the script
		chattr +i $SHA_SUM/init/SHA_SUMS
	else
		if [ "$FIRST_RUN" != "no" ]
			then
				chattr -i $SHA_SUM/init/SHA_SUMS
				cat /dev/null > $SHA_SUM/init/SHA_SUMS
				{
					sha512sum $0
					sha512sum /usr/bin/clamscan
					sha512sum /usr/bin/freshclam
					sha512sum /usr/bin/lynis
					sha512sum /usr/bin/rkhunter
					sha512sum /bin/rpm			
				} >> $SHA_SUM/init/SHA_SUMS
		
				chattr +i $SHA_SUM/init/SHA_SUMS
			else
				SUMS=$(sha512sum -c $SHA_SUM/init/SHA_SUMS)
					for sum in ${SUMS[@]}
						do
							if [[ "$sum"  = "FEHLSCHLAG" || "$sum" = "FAILED" ]]
								then
									echo  -e '\E[33mwarning:'; tput sgr0
									echo "at least one invalid checksum found"
									echo "use -f if you just updated your system"
									exit 1
							fi
						done
				echo -e '\E[32mall ok'; tput sgr0
		fi
fi

exit 0


#option -f firstrun pretend to be the firstrun. this is usefull if you update your system and therefore the sha512sums dont match anymore
#warning: be sure that you do this only when the system has been updated by rpm or whatever package manager you are using
#check all binaries in clamav, lynsis, rkhunter, rpm or which might be used by them. 
