#!/bin/bash
#mmg move my gnome is a rewrite of yourgnome
#-------------------------------------------#
#			yourgnome version 1.1 			#
#	http://code.google.com/p/yourgnome		#
#				Licence: GPL				#
#	http://www.gnu.org/licenses/gpl.html	#
#-------------------------------------------#

##VARS
INDEX=$(date +%Y%m%d%H%M%S)
##VARS

option_backup()
{
BACKUP_PATH="$OPTARG"
}

option_restore()
{
RESTORE_PATH="$OPTARG"
}

option_help()
{
echo "$0 [-b PATH] [-r PATH] [-h]"
echo "-b PATH do a backup of your gnome settings and save resulting tarball in PATH"
ehco "-r PATH restore your previous gnome setings and "
}

if [ -z $1 ]
	then
		option_help
fi

while getopts b:r:h opt
	do
		case "$opt" in
		b)
			option_backup
		;;
		r) 
			option_restore
		;;
		h) 
			option_help
		;;
		\?) option_help
		esac
	done
shift `expr $OPTIND -1`



clear;
echo "yourgnome Version 1 , http://code.google.com/p/yourgnome\n";
echo "this tool used to backup your Gnome in one tar.gz file !";
echo "Also, it restores that backup for you when you want !";
echo "\n";
echo "\033[1m 1] Backup.\033[0m";
echo "\033[1m 2] Restore.\033[0m";
read -p "->> 1 or 2 ?: " choice
if [ $choice -eq 1 ];
then
clear
echo "yourgnome Version 1 , http://code.google.com/p/yourgnome\n";
echo "this tool used to backup your Gnome in one tar.gz file !";
echo "Also, it restores that backup for you when you want !";
echo "\n";
echo "->> Gnome will be backed up for the user: \033[1m$USERNAME\033[0m";
echo "->> type the path in which you want to save the backup, then press Enter ..";
echo "->> e.g. /home/$USERNAME/Desktop"
read -p "->> Path: " path
clear
nowd=`date | awk '{ print $3_$2_$6 }'` #will repalced thorugh IDNEX
ran=`echo $$`
echo "yourgnome Version 1 , http://code.google.com/p/yourgnome\n";
echo "this tool used to backup your Gnome in one tar.gz file !";
echo "Also, it restores that backup for you when you want !";
echo "\n";
echo "\033[1m**-->> 0] Creating temporary folder ..\033[0m";
mkdir /tmp/yourgnome_$ran-$nowd
echo "\033[1m**-->> Done !\033[0m";
echo "\033[1m**-->> 1] Creating backup of: Gnome Themes ..\033[0m";
cd $HOME/
tar -z -P --create --file /tmp/yourgnome_$ran-$nowd/yourgnome_themes_$ran-$nowd.tar.gz .themes
echo "\033[1m**-->> Done !\033[0m";
echo "\033[1m**-->> 2] Creating backup of: Gnome Background Image ..\033[0m";
bgpath=`gconftool -g /desktop/gnome/background/picture_filename`
bgdir=`dirname $bgpath`
fname=`basename $bgpath`
cd $bgdir/
tar -z -P --create --file /tmp/yourgnome_$ran-$nowd/yourgnome_bg_$ran-$nowd.tar.gz $fname
echo "\033[1m**-->> Done !\033[0m";
echo "\033[1m**-->> 3] Creating backup of: Gnome Configuration Records ..\033[0m";
cd $HOME/
tar -z -P --create --file /tmp/yourgnome_$ran-$nowd/yourgnome_conf_$ran-$nowd.tar.gz .gconf
gconftool-2 --dump / > /tmp/yourgnome_$ran-$nowd/dump
echo "\033[1m**-->> Done !\033[0m";
echo "\033[1m**-->> 4] Creating Info Files ..\033[0m";
echo "$ran-$nowd" > /tmp/yourgnome_$ran-$nowd/infofile
echo "$fname" > /tmp/yourgnome_$ran-$nowd/bgfile
echo "\033[1m**-->> Done !\033[0m";
echo "\033[1m**-->> 5] Creating Final File ..\033[0m";
echo "\033[1mQ:\033[0m What name you want for the final backup file ?"
echo "e.g. MyBackUp"
read -p "filename: " n
cd /tmp/yourgnome_$ran-$nowd/
tar -z -P --create --file $path/$n.tar.gz *
echo "\033[1m**-->> Done !\033[0m";
echo "\033[1m**-->> 6] Removing temporary folder ..\033[0m";
rm -rf /tmp/yourgnome_$ran-$nowd
echo "\033[1m**-->> Done !\033[0m";
fi


if [ $choice -eq 2 ];
then
clear
echo "yourgnome Version 1 , http://code.google.com/p/yourgnome\n";
echo "this tool used to backup your Gnome in one tar.gz file !";
echo "Also, it restores that backup for you when you want !";
echo "\n";
echo "type the path with filename of yourgnome backup .."
echo "->> e.g. /home/$USERNAME/Desktop/MyBackUp.tar.gz"
read -p "->> Backup File: " epath
echo "\033[1m**-->> 0] Creating temporary folder ..\033[0m";
if [ ! -d /tmp/yourgnome ]; then
mkdir /tmp/yourgnome
fi

echo "\033[1m**-->> 1] Reading backup ..\033[0m";
tar --extract --directory=/tmp/yourgnome --file=$epath
getinfofile=`cat /tmp/yourgnome/infofile`
echo "\033[1m**-->> Done !\033[0m";
echo "\033[1m**-->> 2] Extracting: Gnome Themes ..\033[0m";
cd /tmp/yourgnome/
tar --extract --directory=$HOME --file=yourgnome_themes_$getinfofile.tar.gz
echo "\033[1m**-->> Done !\033[0m";
echo "\033[1m**-->> 3] Extracting: Gnome Configuration Records ..\033[0m";
tar --extract --directory=$HOME --file=yourgnome_conf_$getinfofile.tar.gz
gconftool-2 --load /tmp/yourgnome/dump /
echo "\033[1m**-->> Done !\033[0m";
echo "\033[1m**-->> 4] Extracting: Gnome Background Image ..\033[0m";
echo "type a path to save the background image in .."
echo "->> e.g. /home/$USERNAME/Desktop"
read -p "->> Path: " np
tar --extract -P --directory=$np --file=yourgnome_bg_$getinfofile.tar.gz
bgf=`cat /tmp/yourgnome/bgfile`
gconftool -s /desktop/gnome/background/picture_filename -t string $np/$bgf
echo "\033[1m**-->> Done !\033[0m";
echo "\033[1m**-->> 5] Removing temporary folder ..\033[0m";
rm -rf /tmp/yourgnome
echo "\033[1m**-->> Done !\033[0m";
fi

