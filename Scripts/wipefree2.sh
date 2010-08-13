#!/bin/bash
#wipefree2

#Script that will wipe out free space pf several partitions

#this is a rewrite of former known script wipefree
#doing the action more efficent and faster

#part of bashtools
#original idea by thomas.c.greene






#program creates a new virtual filesystem named __zeros__
#__zeros__ is temporarly mounted on /tmp/wipe/
# a large file is then created writing from /dev/zeros
#/tmp/wipe is unmounted 
#after this is done file __zeros__ will be deledet with a wiper
#for more partitons /tmp/wipe_nr is used
#use options insted of interactive use
