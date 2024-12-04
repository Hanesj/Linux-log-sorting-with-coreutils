#!/bin/bash
IFS=$'\n'

cat sorted.log | grep -i user:$1 > $1_timeline.tmp
echo "-------------------------LOG TIMELINE FOR: $1------------------------------" > $1_timeline.log
for LINE in $(cat $1_timeline.tmp); do
	TIME_DATE="$(echo "${LINE}" | cut -d " " -f -2 | tr -d \=)"
	IP_ADDR="$(echo "${LINE}" | cut -d ":" -f 8 | tr -d \> | cut -d " " -f 1)"
	METHOD="$(echo "${LINE}" | cut -d " " -f 6)"
	PATH_="$(echo "${LINE}" | cut -d " " -f 7)"
	STATUS_CODE="$(echo "${LINE}" | cut -d " " -f 9)"
	echo $TIME_DATE $IP_ADDR $METHOD $PATH_ $STATUS_CODE >> $1_timeline.log
done

rm $1_timeline.tmp
echo "Log file for $1 has been saved in a file called: $1_timeline.log" 
