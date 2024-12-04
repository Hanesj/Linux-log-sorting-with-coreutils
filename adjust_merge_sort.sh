#!/bin/bash
IFS=$'\n'


for LINE in $(cat logfiles/www-2.log); do
	TIME="$(echo "${LINE}" | cut -d " " -f 2)"
	FIXED_TIME="$(date --date "${TIME} UTC -1 hour +188 seconds" "+%T")"
	sed -i "s/$TIME/$FIXED_TIME/" logfiles/www-2.log
done

for LINE in $(cat logfiles/www-3.log); do
	TIME="$(echo "${LINE}" | cut -d " " -f 2)"
	FIXED_TZ="$(date -u --date "${TIME} CEST" "+%T")"
	
	sed -i -e "s/$TIME/$FIXED_TZ/" -e "s/CEST/UTC/" logfiles/www-3.log
done
cat logfiles/www-1.log > merge.log && cat logfiles/www-2.log >> merge.log && cat logfiles/www-3.log >> merge.log
sort merge.log > sorted.log 
rm merge.log
