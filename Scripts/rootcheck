

get_rpms() #find installed rpm packages and create rpm.lst for first init
{
if [ ! -f /var/lib/rootcheck/rpm.lst ]
then
	echo "first time running rpm"#
	echo "creating initiliszed rpm.lst"
	echo "please be patient"
	declare -a RPMS=$(rpm -qa)
		for rpms in $RPMS
		do
		rpms -ql $rpm >> /var/lib/rootcheck/rpm.lst
		rpm --last |sort >> /var/lib/rootcheck/rpm_last.lst
		done
else
	rpm --last|sort >> /var/lib/rootcheck/rpm_last.lst_new
	diff /var/lib/rootcheck/rpm_last.lst /var/lib/rootcheck/rpm_last.lst_new #watch out for new and changed packages scince last time

		echo 
	
}