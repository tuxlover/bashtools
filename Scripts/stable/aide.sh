#!/bin/bash
#wrapper script to start aide in a regular time interval

#variables for 
DB_INIT="/var/lib/aide/aide.db.out"
DB="/var/lib/aide/aide.db"
DB_NEW="/var/lib/aide/aide.db.new"

#dont run aide when on battery
if [ -d /proc/acpi/battery  ]
	then
		#we need to enable pipefail here because we test the exitstatus of grep 
		set -o pipefail
		HAS_POWER=$(grep -r charging /proc/acpi/battery/ | tail -1|cut -d: -f3 || echo "no")
		set +o pipefail

		if [ $HAS_POWER == 'discharging' ]
			then
				echo "It seems your computer uses battry as power source."
				echo "The Backup might fail to due empty battery"
				echo "connect your Computer to a power socket and rerun the script again"
				exit 1
		fi			

fi


#check whether we have a current aide database present
if [ -f $DB_INIT  ]
	then
		mv $DB_INIT $DB
		aide -C
		STATE=$?
		#detecting changes
		if [ $STATE == 1 ]
			then
				echo "new files detected"|mail -s "Weekly run of aide finished" root
		elif [ $STATE == 2 ]
			then
				echo "removed files detected"|mail -s "weekly run of aide finished" root
		elif [ $STATE == 3 ]
			then
				{
				echo "new files detected"
				echo "removed files detected"
			}|mail -s "weekly run of aide finished" root
		elif [ $STATE == 4 ]
			then
				echo "changed files detected"|mail -s "weekly run of aide finished" root
		elif [ $STATE == 5 ]
			then
				{
				echo "new files detected"
				echo "changed files detected"
			}|mail -s "weekly run of aide finished" root
		elif [ $STATE == 6 ]
			then
				{
				echo "removed files detected"
				echo "changed files detected"
			}|mail -s "weekly run of aide finished" root
		elif [ $STATE == 7 ]
			then
				{
				echo "new files detected"
				echo "removed files detected"
				echo "changed files detected"
			} |mail -s "weekly run of aide finishd" root 
			else
				echo "all clean"|mail -s "weekly run of aide finished" root
		fi
		mv $DB $DB_INIT
	else
		aide -i
fi
