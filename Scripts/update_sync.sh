#!/bin/bash
#update_sync.sh

#scrip that is indent to check via rsync wheter there is a change of one of the destinations
#if there is a difference sync between both and resolve onky newer 


if [ ! -d ~/test ]
then
mkdir ~/test
fi

rsync -vruh "/media/UDISK 2.0/portable/ThunderbirdPortable/Data/profile/Mail" ~/test/