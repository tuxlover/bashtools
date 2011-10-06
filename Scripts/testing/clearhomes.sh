clear_homes()
{
echo "cleaning up users home"
for file in $USERS_HOME
	do
		find $file -type d -name .thumbnails -exec rm -r {} \;
		find $file -type f -name .recently-used -exec rm -r {} \;
		find $file -type f -name .recently-used.xbel -exec rm -r {} \;
	done	
	
}
USERS_HOME=$(cat /etc/passwd | cut -d ":" -f 6|grep /home/ && echo "/root")
