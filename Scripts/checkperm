#checkperm

#is a simple script that finds not allowed writeable data on your system

find_perm()
{
echo "Looking for files that are writeable by others"
find $HOME \( -type f -o -type d \) -perm -002 -ls
}

change_perm()
{
echo "Lookong files that are writeable by others"
echo "Changing permissions for"
find $HOME \( -type f -o -type d \) -perm -002 -ls -ok chmod o=-w {} \;
}
