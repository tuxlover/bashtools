#!/bin/bash 
#maybe 
#!/usr/bin/env python3

#i rpm is used to intelligently doing things with rpm.
# the idea is based on the folling thinking:
#based on users input and the status information rpm holds in his database it should be pretty much clear
#what rpm is supposed todo. 

#user input               #rpm-version        #package-status                   #action
irpm package-name            ==                 ok                               remove
irpm package-name            >                  ok                               update
irpm package-name            <                  ok                               downgrade
irpm package-name           ==                  defect                           reinstall 
irpm package-name           >                   defect                           remove defect package and upgrade
irpm package-name           <                   defect                           remove defect package and downgrade 
