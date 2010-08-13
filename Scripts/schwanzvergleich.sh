#!/bin/bash
LC_ALL=C
echo $(uptime\
      |grep Tage\
      |sed 's/.*an \([0-9]*\) Tag.*/\1\/10+/';\
      cat /proc/cpuinfo|grep MHz|awk '{print $4"/30+";}';\
      free\
      |grep '^Mem'\
      |awk '{print $3"/1024/3+"}'; df -P -k -x nfs\
      | grep -v 1k\
      | awk '{if ($1 ~ "/dev/(scsi|sd)"){ s+= $2} s+= $2;} END\
      {print s/1024/50"/15+70";}'\
      )\
|sed 's/,/./g'\
|bc\
|sed 's/\(.$\)/.\1cm/'
