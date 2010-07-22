#!/bin/bash

#git-20102906_1409
#This is cleancheck
#cleancheck is currently under heavly development
#it is expected that things are not working or not
#working probertly although we test it as hard as we
#can.

#As you can see the todo list is quiet long and there will be a long
#time as the final version will be out.

#for bug reporting, please use github bugtracker and commit a fix
#if possible

#for feature requests please use github comments. however there are several
#things here we will never implement. one of them would be support for ubuntu
#because its freaking me out.

#cleancheck.sh
#Script that does several Systemscans.
#It checks system integrety and logs information
#about the system. By default it will do a lot of scans
#and will need a long runtime.
#It creates logfiles which can be inspected aferwards.

#Caution the goal of cleancheck is not to prevent intrusion
#but to detect intrusion and find out security leaks.

##help_option starts here
option_h()
{
echo "$0 [-a PATH] [-c PATH] [-l NAME] [-e DIR1:DIR2:...] [-h] [-s PATH] [-w ACDPSU]"
echo "[-n] [-q] [-t PATH] [-T PATH] {-j}"
echo "-a set path to clamscan  binary. if not set, which clamscan is used"
echo "-c set path to  chkrootkit binary. if not set which rkhunter is used"
echo "-e exclude these dirs for scanning for viruses"
echo "   you have to seperate the directories by : character"
echo "	 example -e /home/:/media/:/mnt/"
echo "-f pretend to be the firstrun. this is usefull if you update your system"
echo "   and therefore the sha512sums dont match anymore"
echo "   WARNING be sure that you do this only when the system has been updated by rpm"
echo "-j do no other action but upgrade system basic tools"
echo "-l set name and path to logdir"
echo "-n run without tripwire support"
echo "-h show this help"
echo "-q be as less verbose as possible and log only to logfile"
echo "-s set path to lynis binary. if not set which lynis is used"
echo "-t set path to the tripwire checking tool. if not set which tripwire is used"
echo "-T set path to the tripwire admin tool. if not set which twadmin is used"
echo "-w with feature explizit set feature"
echo "      A: scan for viruses"
echo "      C: check for rootkits"
echo "      D: check health of current disks"
echo "      S: check security holes"
echo "      P: do an package integrety-check. RPMS only"
echo "      U: only update or check the sha512 sums" 
echo "      u: only update the system"
echo "   You may also use this option to set the order of checks performed"
echo "   or to exclude actions that should not be performed."
exit 0	
}
##help option ends here

##setting up runtime varibales starts here

INDEX=$(date +%Y%m%d%H%M%S)

#first initilize the variables
ANTIVIR=
ROOTKIT_CHECKER=
SECURITY_CHECKER=
TRIPWIRE_CHECK=
TRIPWIRE_ADMIN=
DISK_CHECKER=
LOGFILE=
USE_QUIET=
FIRST_RUN=
declare -a EXCLUDE_DIRS=
declare -a WITH_FEATURE=
SHA_SUM=/var/log/selftest
DISTRIBUTION=$(head -1 /etc/SuSE-release|awk '{print $1}')
RELEASE=$(head -1 /etc/SuSE-release|awk '{print $2}')
SUSE_RELEASE=${DISTRIBUTION}_${RELEASE}

option_a()
{
ANTIVIR="$OPTARG"
}

option_c()
{
ROOTKIT_CHECKER="$OPTARG"	
}

option_e()
{
EXCLUDE_DIRS="$OPTARG"
DIRS=$(echo $EXCLUDE_DIRS |  sed "s/:/\n/g" )
}

option_f()
{
FIRST_RUN="yes"	
}

option_l()
{
LOGFILE="$OPTARG"
}

option_j()
{		
echo "You choose to just upgrade the scripts toolchain."
echo "Other Options will be ignored"
echo "Refreshing zyppers Database..."

zypper -n ref

echo "checking if newer version of clamscan is available..."
test $(zypper -n --no-refresh se -s -t package  --match-exact clamav|grep ^i|awk '{print $7}'|tr -d [:punct:]) -lt $(zypper -n --no-refresh se -s -t package --match-exact --sort-by-name clamav|grep ^v|awk '{print $7}'|tr -d [:punct:]|head -1 ) && new_version="yes" || new_version="no"
			
if [ "$new_version" == "yes" ]
	then
		echo "there is a newer version available"
		echo "trying to update"
		VENDOR=$(zypper -n --no-refresh se -s -t package --match-exact clamav|grep ^v|awk '{print $11}')
		zypper -n --no-refresh in -n --from $VENDOR clamav clamav-db
		echo "finished"
	else
		echo "no update available"
fi


echo "checking if newer version of tripwire available..."
test $(zypper -n --no-refresh se -s -t package  --match-exact tripwire|grep ^i|awk '{print $7}'|tr -d [:punct:]) -lt $(zypper -n --no-refresh se -s -t package --match-exact --sort-by-name tripwire|grep ^v|awk '{print $7}'|tr -d [:punct:]|head -1 ) && new_version="yes" || new_version="no"

if [ "$new_version" == "yes" ]
	then
		echo "there is a newer version available"
		echo "trying to update"
		VENDOR=$(zypper -n --no-refresh se -s -t package --match-exact tripwire|grep ^v|awk '{print $11}')
		zypper -n --no-refresh in -n --from $VENDOR tripwire
		echo "finished"
	else
		echo "no update available"
fi
	

echo "checking if newer version of rkhunter is available..."
test $(zypper -n --no-refresh se -s -t package  --match-exact rkhunter|grep ^i|awk '{print $7}'|tr -d [:punct:]) -lt $(zypper -n --no-refresh se -s -t package --match-exact --sort-by-name rkhunter|grep ^v|awk '{print $7}'|tr -d [:punct:]|head -1 ) && new_version="yes" || new_version="no"

if [ "$new_version" == "yes" ]
	then
		echo "there is a newer version available"
		echo "trying to update"
		VENDOR=$(zypper -n --no-refresh se -s -t package --match-exact rkhunter|grep ^v|awk '{print $11}')
		zypper -n --no-refresh in -n --from $VENDOR rkhunter
		echo "finished"
	else
		echo "no update available"
fi

echo "checking if newer version of lynis is available..."
test $(zypper -n --no-refresh se -s -t package  --match-exact lynis|grep ^i|awk '{print $7}'|tr -d [:punct:]) -lt $(zypper -n --no-refresh se -s -t package --match-exact --sort-by-name lynis|grep ^v|awk '{print $7}'|tr -d [:punct:]|head -1 ) && new_version="yes" || new_version="no"

if [ "$new_version" == "yes" ]
	then
		echo "there is a newer version available"
		echo "trying to update"
		VENDOR=$(zypper -n --no-refresh se -s -t package --match-exact lynis|grep ^v|awk '{print $11}')
		zypper -n --no-refresh in -n --from $VENDOR lynis
		echo "finished"
	else
		echo "no update available"
fi

exit 1
}

option_n()
{
without_triptwire="yes"
}
	
option_q()
{
USE_QUIET="yes"
}

option_s()
{
SECURITY_CHECKER="$OPTARG"	
}

option_t()
{
TRIPWIRE_CHECK="$OPTARG"
}

option_T()
{
TRIPWIRE_ADMIN="$OPTARG"	
}

option_w()
{
W_F="$OPTARG"

#convert a contiguous string to an array
#where each letter is an element of the array

c=${#OPTARG}
while [ $c -ge 0 ]
	do
		WITH_FEATURE[$c]=${W_F:$c:1}
		c=$(($c-1))
	done
}



while getopts a:c:l:e:s:t:T:w:fhjnq opt
	do
		case "$opt" in
			a) option_a
			;;
			c) option_c
			;;
			h) option_h
			;;
			l) option_l
			;;
			e) option_e
			;;
			f) option_f
			;;
			j) option_j
			;;
			n) option_n
			;;
			s) option_s
			;;
			t) option_t
			;;
			T) option_T
			;;
			q) option_q
			;;
			w) option_w
			;;
			\?) option_h #in case of invalid option display help
		esac
	done
shift `expr $OPTIND - 1`


#assign the ANTIVIR variable must be declared here to run the script correctly
if [ -z $ANTIVIR ]
	then
		ANTIVIR=$(which clamscan || echo "no")
fi

#assign the ROOTKIT_CHECKER variable must be declared here to run the script correctly
if [ -z $ROOTKIT_CHECKER ]
	then
		ROOTKIT_CHECKER=$(which rkhunter || echo "no")
fi

#assign the SECURITY_CHECKER variable must declared here to run the script correctly
if [ -z $SECURITY_CHECKER ] #check for open security holes
	then
		SECURITY_CHECKER=$(which lynis || echo "no")
fi

#assign Tripwire variable must declared here to run the script correctly
if [ -z $TRIPWIRE_CHECK ]
	then
		TRIPWIRE_CHECK=$(which tripwire || echo "no" ) #tripwire is used by rkhunter
fi

if [ -z $TRIPWIRE_ADMIN ]
	then
		TRIPWIRE_ADMIN=$(which twadmin || echo "no" )
fi

#assign the DISK_CHECKER variable must be declared here to run the script correctly
if [ -z DISK_CHECKER ] #check disk health status
	then
		DISK_CHECKER=$(which smartctl || echo "no")
fi


if [ -z $USE_QUIET ]
	then
		USE_QUIET="no"
fi

if [ -z $FIRST_RUN ]
	then
		FIRST_RUN="no"
fi

if [ -z $LOGFILE ]
	then
		#to keep the logfile small
		#previous logfiles will be cleared 
		if [ -f /var/log/cleancheck.log ]
			then
				cat /dev/null > /var/log/cleancheck.log
		fi	
		LOGFILE="/var/log/cleancheck.log"
		touch $LOGFILE
	else
		unset LOGDIR
		LOGDIR=$(echo ${LOGFILE%/*} )
		if [ ! -d $LOGDIR ]
			then
				mkdir -p $LOGDIR
		fi
		
		if [ -f $LOGFILE ]
			then
				cat /dev/null > $LOGFILE
		fi
		touch $LOGFILE
fi
##setting up runtime variables ends here


#check whether you are root
check_root()
{
if [ $UID -ne 0 ]
	then 
		drop_failure
		echo "not root"
		exit 1
	else
		main
fi
}

look_for_updates()
#check if updates are available if internetconnection is present
{
#first check if the suse security repo and updaterepo are present
#if not present add it here
zypper lr -u|awk '{print $11}'|grep "http://download.opensuse.org/update/$RELEASE" || zypper ar -f http://download.opensuse.org/update/$RELEASE/ update

zypper lr -u |awk '{print $11}'|grep "repositories/security/$SUSE_RELEASE" || zypper ar -f http://download.opensuse.org/repositories/security/$SUSE_RELEASE/ security

#than check if connection to server can be established
ping -c 5 http://download.opensuse.org && is_reachable="yes" || is_reachable="no"
ping -c 5 ftp://ftp5.gwdg.de && is_reachable="yes" || is_reachable="no"

if [ "$is_reachable" == "yes" ]
	then
		zypper ref
		zypper -n up
		export FIRST_RUN="yes"
	else
		echo "zypper cannot connect to the updateserver"
		echo "maybe your connection is down or the server maybe overloaded"
fi
}

#check whether programs and argumets are set correctly
check_antivir()
{				
echo "checking for Antivirus detection" 2> /dev/null
if [ "$ANTIVIR" == "no" ]
	then
		drop_failure
		echo "An Virus detection tool is not installed."
		echo "trying to get one"
		zypper -n in clamav clamav-db || we_fail
		ping -c 6 clamav.net && freshclam || echo "not possible"
	else
		echo "checking if newer version of clamscan is available"
		test $(zypper -n --no-refresh se -s -t package  --match-exact clamav|grep ^i|awk '{print $7}'|tr -d [:punct:]) -lt $(zypper -n --no-refresh se -s -t package --match-exact --sort-by-name clamav|grep ^v|awk '{print $7}'|tr -d [:punct:]|head -1 ) && new_version="yes" || new_version="no"
			
		if [ "$new_version" == "yes" ]
			then
                echo "there is a newer version available"
                echo "trying to update"
                VENDOR=$(zypper -n --no-refresh se -s -t package --match-exact clamav|grep ^v|awk '{print $11}')
                zypper -n --no-refresh in -n --from $VENDOR clamav clamav-db
                echo "finished"
			else
                echo "no update available"
		fi

		
		drop_ok
		echo "trying to update daily.cvd file"
		ping -c 6 clamav.net && freshclam || echo "not possible"
fi
}

tripwire_setup()
{
	echo "not implemented yet"
}	

tripwire_setup_keys()
{
clear	
echo "Give the password for the local hosts key:"
$TRIPWIRE_ADMIN --generate-keys -L /etc/tripwire/${HOSTNAME}-local.key

clear
echo "Give the password for the sites key"
$TRIPWIRE_ADMIN --generate-keys -S /etc/tripwire/site.key

}

tripwire_setup_config()
{
clear	
echo "Setting up tripwire configuration file"
$TRIPWIRE_ADMIN --create-cfgfile --cfgfile /etc/tripwire/tw.cfg -S /etc/tripwire/site.key /etc/tripwire/twcfg.txt
}	


tripwire_setup_pol()
{
clear
echo "Setting up a tripwire default policy"
cp /usr/share/doc/packages/tripwire/twpol-Linux.txt /etc/tripwire/twpol.txt
$TRIPWIRE_ADMIN --creatxse-polfile --cfgfile /etc/tripwire/tw.cfg -S /etc/tripwire/site.key /etc/tripwire/twpol.txt
}	

check_tripwire ()
{
echo "checking essential tool for rootkit checker"
#first checking path to tripwire checking tool
if [[ "$TRIPWIRE_CHECK"  == "no" || "TRIPWIRE_ADMIN" == "no" ]]
	then
		drop_failure
		echo "basic tripwire tool is not installed"
		echo "or not installed correctly"
		echo "trying to get it"
		zypper -n in tripwire || we_fail
	else
		echo "checking if newer version is available"
		test $(zypper -n --no-refresh se -s -t package  --match-exact tripwire|grep ^i|awk '{print $7}'|tr -d [:punct:]) -lt $(zypper -n --no-refresh se -s -t package --match-exact --sort-by-name tripwire|grep ^v|awk '{print $7}'|tr -d [:punct:]|head -1 ) && new_version="yes" || new_version="no"

		if [ "$new_version" == "yes" ]
			then
				echo "there is a newer version available"
				echo "trying to update"
				VENDOR=$(zypper -n --no-refresh se -s -t package --match-exact tripwire|grep ^v|awk '{print $11}')
				zypper -n --no-refresh in -n --from $VENDOR tripwire
				echo "finished"
			else
				echo "no update available"
		fi
		
		drop_ok
fi 
				
#checking path and files neccessary to tripwire
#lookup the files wich needs to be up for tripwire check
ls /etc/tripwire/*txt && TRIPWIRE_WARN="yes" || TRIPWIRE_WARN="no" 
ls /etc/tripwire/tw.cfg &&  TRIPWIRE_CFG="yes" || TRIPWIRE_CFG="no"
ls /etc/tripwire/tw.pol && TRIPWIRE_POL="yes" || TRIPWIRE_POL="no"
ls /var/lib/tripwire/$HOSTNAME.twd && TRIPWIRE_DATABASE="yes" || TRIPWIRE_DATABASE="no"
ls /etc/tripwire/site.key && TRIPWIRE_KEY_LOCAL="yes" || TRIPWIRE_KEY_LOCAL="no"
ls /etc/tripwire/$HOSTNAME-local.key && TRIPWIRE_KEY_HOST="yes" || TRIPWIRE_KEY_HOST="no"

echo "Checking your Tripwire configuration"


echo "checking tripwire encryption keys..."
if [[ "$TRIPWIRE_KEY_HOST" == "yes" && "$TRIPWIRE_KEY_LOCAL" == "yes"  ]]
	then
		echo "found"
		drop_ok
else
	echo "no"
	drop_failure
	echo "It looks like your tripwire installation is not completely setup yet"
	echo "You should setup your the keys for your local machine."
	read -s -t 10 -n 1 -p "Do you want to setup them now? y/n?" ANSWER
	${ANSWER:=n} 2> /dev/null
	test $ANSWER == "y" && tripwire_setup_keys || return
fi


echo "checking for tripwire policy..."
if [ "$TRIPWIRE_CFG" == "no" ]
	then
		echo "no"
		drop_failure
		echo "It looks like your tripwire installation is not completely setup yet."
		echo "You should setup a tripwire configuration file."
		read -s -t 10 -n 1 -p "Do you want to setup one now? y/n?" ANSWER
		${ANSWER:=n} 2> /dev/null
		test $ANSWER == "y" && tripwire_setup_config || return
	else
		echo "yes"
		drop_ok
fi

echo "checking for tripwire configuration file..."
if [ "$TRIPWIRE_POL" == "no" ]
	then
		echo "no"
		drop_failure
		echo "It looks like your tripwire installation is not completely setup yet"
		echo "you should setup a tripwire policy."
		read -s -t 10 -n 1 -p "Do you want to setup a default policy now? y/n?" ANSWER
		${ANSWER:=n} 2> /dev/null
		test $ANSWER == "y" && tripwire_setup_pol || return
	else
		echo "yes"
	drop_ok
fi

echo "checking for unencrypted setup files..."
if [ "$TRIPWIRE_WARN" == "yes" ]
	then
		echo "warning"
		drop_failure
		echo "You have unencrypted tripwire setup files"
		echo "I move them to roots directory"
		mv /etc/tripwire/*txt /root/
	else
		drop_ok
fi

echo "checking for tripwire database..."

if [ "$TRIPWIRE_DATABASE" == "no" ]
	then
		echo "no"
		echo "dont worry i create one now"
		$TRIPWIRE_CHECK --init --cfgfile /etc/tripwire/tw.cfg || return
		#Todo/Fixme: after database initilisation we have to run at least one check to create
		#a valid report
		#check for valid report file
	else
		echo "yes"
		drop_ok
fi
}

check_rootkit_checker()
{
if [ "$without_triptwire" != "yes" ]
	then
		check_tripwire
fi

echo "checking for rootkit checker" 2> /dev/null
if [ "$ROOTKIT_CHECKER" == "no" ] 
	then
		drop_failure
		echo "A rootkit checker is not installed"
		echo "trying to get one"
		zypper -n in rkhunter || we_fail
	else
	
		echo "checking if newer version is available"
		test $(zypper -n --no-refresh se -s -t package  --match-exact rkhunter|grep ^i|awk '{print $7}'|tr -d [:punct:]) -lt $(zypper -n --no-refresh se -s -t package --match-exact --sort-by-name rkhunter|grep ^v|awk '{print $7}'|tr -d [:punct:]|head -1 ) && new_version="yes" || new_version="no"
			
		if [ "$new_version" == "yes" ]
			then
                echo "there is a newer version available"
                echo "trying to update"
                VENDOR=$(zypper -n --no-refresh se -s -t package --match-exact rkhunter|grep ^v|awk '{print $11}')
                zypper -n --no-refresh in -n --from $VENDOR rkhunter
                echo "finished"
			else
                echo "no update available"
		fi
	
		drop_ok
fi
}

check_lynis()
{

echo "checking for security checker" 2> /dev/null
if [ "$SECURITY_CHECKER" == "no" ]
	then
		drop_failure
		echo "A security checker is not installed"
		echo "trying to get one"
		zypper -n in lynis || we_fail
	else
		echo "checking if newer version is available"
		test $(zypper -n --no-refresh se -s -t package  --match-exact lynis|grep ^i|awk '{print $7}'|tr -d [:punct:]) -lt $(zypper -n --no-refresh se -s -t package --match-exact --sort-by-name lynis|grep ^v|awk '{print $7}'|tr -d [:punct:]|head -1 ) && new_version="yes" || new_version="no"
			
		if [ "$new_version" == "yes" ]
			then
                echo "there is a newer version available"
                echo "trying to update"
                VENDOR=$(zypper -n --no-refresh se -s -t package --match-exact lynis|grep ^v|awk '{print $11}')
                zypper -n --no-refresh in -n --from $VENDOR lynis
                echo "finished"
			else
                echo "no update available"
		fi
		drop_ok
fi
}

check_smartctl()
{

echo "checking for smartmontools" 2> /dev/null
if [ "$DISK_CHECKER" == "no" ]
	then
		drop_failure
		echo "Smartctl is not installed"
		echo "trying to get it"
		zypper -n in smartmontools || we_fail
	else
		drop_ok
fi
}

exclude_this() #prepare exclude for clamscan 
{
for dir in  ${DIRS[@]}
	do
		echo \ 
		echo "--exclude-dir"=$dir
	done
}


###Each Action has its own function starts here

#this is the actual scan for viruses using clamscan
virus_scan()
{
check_antivir	
if [ ! -z $EXCLUDE_DIRS ]
	then
		if [ "$USE_QUIET" != "no" ]
			then
				{
				echo "with clamscan" 
				echo "with excludedirs"
				echo "Skiping"
								
					for dir in ${DIRS[@]}
						do
							echo $dir
						done
				
				E=$( exclude_this)
				ANT=`$ANTIVIR -r -i --exclude-dir=/proc --exclude-dir=/dev --exclude-dir=/sys  $E /`
				echo "$ANT" 
				} >> $LOGFILE
			else
				{
				echo "with clamscan" 
				echo "with excludedirs"
				echo "Skiping"
								
					for dir in ${DIRS[@]}
						do
							echo $dir
						done
				
				E=$( exclude_this)
				ANT=`$ANTIVIR -r -i --exclude-dir=/proc --exclude-dir=/dev --exclude-dir=/sys $E /`
				echo "$ANT" 
				}|tee -a $LOGFILE
			fi
		else
			if [ "$USE_QUIET" != "no" ]
				then
					{
					echo "with clamscan"
					ANT=`$ANTIVIR -r -i --exclude-dir=/proc --exclude-dir=/dev --exclude-dir=/sys /`
					echo "$ANT" 
					}>> $LOGFILE
				else
					{
					echo "with clamscan"
					ANT=`$ANTIVIR -r -i --exclude-dir=/proc --exclude-dir=/dev --exclude-dir=/sys /`
					echo "$ANT" 
					}|tee -a $LOGFILE
			fi
fi
}


chk_rootkit()
{
check_rootkit_checker	
	
if [ "$USE_QUIET" != "no" ]
	then
		{
		echo "with chkrootkit" 
		
		if [ ! -f /var/lib/rkhunter/db/rkhunter.dat ]
			then
				echo "create initial database"
				$ROOTKIT_CHECKER --propupd
				CNT=`$ROOTKIT_CHECKER -c  --novl --nocolors -sk`
				echo "$CNT"
			else
				CNT=`$ROOTKIT_CHECKER -c --novl --nocolors -sk`
				echo "$CNT"
		fi		
		}>> $LOGFILE
	else
		{
		echo "with chkrootkit"
		
		if [ ! -f /var/lib/rkhunter/db/rkhunter.dat ]
			then
				echo "create initial database"
				$ROOTKIT_CHECKER --propupd
				CNT=`$ROOTKIT_CHECKER -c  --novl --nocolors -sk`
				echo "$CNT"
			else
				CNT=`$ROOTKIT_CHECKER -c --novl --nocolors -sk`
				echo "$CNT"
		fi	

		}|tee -a $LOGFILE
fi	
}

chk_sec()
{
check_lynis
	
if [ "$USE_QUIET" != "no" ]
	then
		{			
		echo "with lynis"
		SNT=`$SECURITY_CHECKER -c -Q --no-colors --no-log`
		echo "$SNT"      
		}>> $LOGFILE
	else
		{			
		echo "with lynis"
		SNT=`$SECURITY_CHECKER -c -Q --no-colors --no-log`
		echo "$SNT"      
		}|tee -a $LOGFILE
fi
}


verify_package()
{
rpm -q rpm && is_rpm="yes" || is_rpm="no"

if [ "$is_rpm" == "yes" ]
	then
		echo "with rpm package verification"
		PACKAGES=$(rpm -qa) #get all installaed packages
		
		if [ "$USE_QUIET" != "no" ]
			then
				{			
					for package in $PACKAGES
						do
							echo "========================="
							echo "Checkiing package $package"
							rpm -V $package
						done
				}>> $LOGFILE
			else
				{			
					for package in $PACKAGES
						do
							echo "========================="
							echo "Checkiing package $package"
							rpm -V $package
						done
				}|tee -a $LOGFILE
		fi
	else
		echo "package verification for rpm skipped"
		echo "You are trying to run rpm on a non rpm system"
fi

}


disk_check()
{
check_smartctl
	
#checking disks using smartmontools	
all_devices=$(ls /dev/sd*) #fixme: check only disks not partitions

if [ "$USE_QUIET" != "no" ]
	then
		{
		echo "with smartmontools"
			
			for device in $all_devices
				do
					smartctl -H $device || exit 1
				done
		} >> $LOGFILE
	else
		{
		echo "with smartmontools"
			
			for device in $all_devices
				do
					smartctl -H $device || exit 1
				done						
									
		} |tee -a $LOGFILE
fi
}

self_test()
{
SHA512_TEST=$(which sha512sum || echo "no")
SHA512=${SHA512_TEST}

if [ "$SHA512_TEST" = "no"  ]
	then 
		echo "the program for calculating the sha512 sum is not in the system"
		echo "please install it and rerun again"
		exit 1
fi
		
if [ ! -f $SHA_SUM/init/SHA_SUMS ]
	then
		echo "first run of $0. initilize sha512 checksums."
		mkdir -p $SHA_SUM/init
		{
			sha512sum $SHA512
			sha512sum $0
			sha512sum /bin/bash
			sha512sum $ANTIVIR
			sha512sum $TRIPWIRE_ADMIN
			sha512sum $TRIPWIRE_CHECK
			sha512sum /usr/bin/freshclam
			sha512sum $ROOTKIT_CHECKER
			sha512sum $SECURITY_CHECKER
			sha512sum $DISK_CHECKER
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
					sha512sum $SHA512
					sha512sum $0
					sha512sum /bin/bash
					sha512sum $ANTIVIR
					sha512sum /usr/bin/freshclam
					sha512sum $ROOTKIT_CHECKER
					sha512sum $SECURITY_CHECKER
					sha512sum $TRIPWIRE_ADMIN
					sha512sum $TRIPWIRE_CHECK
					sha512sum /bin/rpm			
				} >> $SHA_SUM/init/SHA_SUMS
		
				chattr +i $SHA_SUM/init/SHA_SUMS
				echo -e '\E[32mall ok'; tput sgr0
			else
				SUMS=$(sha512sum -c $SHA_SUM/init/SHA_SUMS)
					for sum in ${SUMS[@]}
						do
							if [[ "$sum"  == "FEHLSCHLAG" || "$sum" == "FAILED" ]]
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
}
###Each action has its own function ends here


#do the main action including check for dirs and files
main()
{
#select special features		
if [ ! -z $WITH_FEATURE ]
	then
		echo $INDEX >> $LOGFILE
		echo "file was created by $0" >> $LOGFILE
		echo "-----------------------------------------------------------------" >> $LOGFILE
		self_test
		
		for feature in ${WITH_FEATURE[@]}
			do
				case $feature in
					A) virus_scan
					;;
					C) chk_rootkit
					;;
					D) disk_check						
					;;
					S) chk_sec
					;;
					P) verify_package
					;;
					u) look_for_updates
					;;
					U) :
					;;
					\?) 
						option_h #in case the option dont met display help
				esac
			done
		echo "------------------------------------------------------------------" >> $LOGFILE
#with all features
	else
		if [ "$USE_QUIET" != "no" ]
			then
				{
					echo $INDEX
					echo "file was created by $0"
					echo "-----------------------------------------------------------------"
				    
				    look_for_updates
					self_test
					disk_check
					virus_scan
					chk_rootkit
					chk_sec
					verify_package
				}>> $LOGFILE
			else
					{
					echo $INDEX
					echo "file was created by $0"
					echo "-----------------------------------------------------------------"
					
					look_for_updates
					self_test
					disk_check
					virus_scan
					chk_rootkit
					chk_sec
					verify_package
				}|tee -a $LOGFILE
				
		fi
				
fi
}	

drop_failure ()
{
echo -e '\t \t \t \t \E[31mfailure'; tput sgr0
}

drop_ok ()
{
echo -e '\t \t \t \t \E[32mok'; tput sgr0
}

we_fail()
{
echo -e '\t \t \t \t \E[31mfailed'; tput sgr0	
echo -e '\t \t \t \t \E[31mstop'; tput sgr0
exit 1
}

check_root

exit 0


##Todo:
#use more comments
#clean up the code
#colorize output
#use option to update tripwire database
#rkhunter first initilise database if not present yet
#selftests: look up if the binarys which being used are valid or have been changed
#if package has fatal error reinstall it
#test whether packages match if not install them
#use tripwire to prevent filesystem infiltration
#implement all stuff in a nicer interface
#implement file-integrety checker
#it mitght also be usefull to create additional logfiles  
#use different Logfiles for each than display a summary when finished
#if no changes in package where detected dont display it
#find files which are not belonging to any package and calculate there checksum
#implement -C: run in cron mode
#+ just do the action and print the reports
#+update tripwire databases
#+ no updates
#run tripwire database update after systemupgrade
#set Updatebaseserver manualy option

#create a snapshot of actual system before doing autoupdate
#check if manually set path is set correctly
#check tripwire configuration for permissions
#if we have set path manually dont try to update via zypper
#fixme: unary operator expected.
#fixme: if rkhunter is not on the system it is not installed automaticly

#if -t is used check if the corresponding -T is also specified and vise versa
#calculate md5sum of tripwire database

#checking for newer versions for:
#enable the clamav and freshclam dameon if disabled
#GnuPG
#OpenSSL
#MTA
#OpenSSH   
#setup tripwire
#tripwire  -m u -a --cfgfile /etc/tripwire/tw.cfg -V nano -r /var/lib/tripwire/report/Dickkopf-20100630-004904.twr 
#tripwire  -m u --cfgfile /etc/tripwire/tw.cfg -V nano -r /var/lib/tripwire/report/Dickkopf-20100630-004904.twr
#aoutosectools: (maybe should replace lynis in future)
#set up autidor
#crypt hash grub randomly
#set ntp damon
#disable not needed services
#find and uninstall not needed compilers
#find and disabe account with weak passwords #howto do this
#disable not valid shells in /etc/shells
#setting kernel options according to lynis
#set automaticly to secure without yast #howto do that
#set alias for /bin/su
#show ids on logon
#setup the clamav daemon

#we are looking for new features

