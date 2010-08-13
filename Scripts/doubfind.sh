#!/bin/bash

#find doubled data in argument folder by checking md5-sum for each file first, save it in a kind of database, compare it and give out doubled md5sums files
# it is indent to find doubed files evenm zhough two files have differetn names



#TODO
#script should only be run as root
#arg_check
#main
#then main function should first create a database
#maybe we using a small database like sqlite or postgresql
#howto do that
#second we need a function to read the database
#third we need a funtion which finaly compares the database files
#how can if find doubled files
#options:
#--md5sum uses md5sum as verifier
#--sha1 uses sha1 hash algorithm as verifier
#--just-filename uses filesnames only as verifier

