#script that filters /var/log/messages
#basicly it is a wrapper script to grep
#this is what we can filter for:
#-d DATE filter for specific date or range of date 
	#if a range of date is used use the range(dateA dateB) syntax
	#where dateA < dateB and date is a value conaining the YYYY-MM-DD-hh-mm-ss
	#it must contain at least the year.
#-e Expres: filters for a expression in the 5 column
#-b only show on boot events
#-K only show kernel 
#-E only show Errors
#-W only show Warnings

#combine these filters
