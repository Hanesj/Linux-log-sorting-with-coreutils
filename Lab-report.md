Lab report:
The scripts I created for this lab:

adjust_merge_sort.sh:
#!/bin/bash

IFS=$'\n' 
First we set the internal field separator to newline so that the shell knows that 
a the first piece of data ends when after a new line is entered.

Here we loop through the first log file which is 3 minutes and 8 seconds behind.
We define where in the line the time is written. So we create a variable to hold the value and take it line by line. And with each line use cut, with the delimeter of a space character and if we look at the log file we can see that time is in field 2.

Since we know what amount the logfile time is behind we use the variable we created to hold the time and we use the date command to modify it. We say that our variable is in the UTC timezone and we want to add 188 seconds to that which is equal to 3 minutes and 8 seconds. For some reason I couldn't figure out I also had to to say -1 hour otherwise it would add an hour to the new time. We save the corrected time to a new variable.

After that we edit the file with the incorrect timestamps by using sed. Sed is a stream editor that we can use to edit files and we use the -i flag to edit the original file instead of creating a new output file. After this our modification of the first log file is finished so we end the for loop with "done". +%T means that we want the time in the format of 0-23:0-60:0-60

for LINE in $(cat www-2.log); do
        TIME="$(echo "${LINE}" | cut -d " " -f 2)"
        FIXED_TIME="$(date --date "${TIME} UTC -1 hour +188 seconds" "+%T")"
        sed -i "s/$TIME/$FIXED_TIME/" www-2.log
done

Next we need to modify the second log file where the timestamps are in the timezone CEST.
We start as we did before and set variable to the time field in the log file. 

But now instead of increasing the timestamp we need to change the timezone so we use the date command again with the variable we've saved and with the -u flag to say that we want UTC. After our time-variable we tell date that it's originally in CEST.

We use sed again but now with the -e so we can use more than one expressions. We also want to change the text from CEST to UTC now that we have changed the timezone.

for LINE in $(cat www-3.log); do
        TIME="$(echo "${LINE}" | cut -d " " -f 2)"
        FIXED_TZ="$(date -u --date "${TIME} CEST" "+%T")"

        sed -i -e "s/$TIME/$FIXED_TZ/" -e "s/CEST/UTC/" www-3.log
done

We merge all the log files in to a temporary file that we call merge.log.
After that we sort the data in the merge file and write it to a new file called sorted.log where all the data is now stored and sorted. We then remove the temporary merge file.

cat www-1.log > merge.log && cat www-2.log >> merge.log && cat www-3.log >> merge.log
sort merge.log > sorted.log
rm merge.log

user_timeline.sh:
#!/bin/bash
IFS=$'\n'

Instead of automatically generating a timeline for the user kim i created a script where you can choose which users log file you want by adding the users name as an argument to the script.
We first take the sorted log file we have created with the previous script and use grep to find all the lines where the users name that we passed as an argument is found. We save all those lines to a temporary file that is called <users>_timeline.log. We create the log file which will be saved and enter a simple so we know which users log files we are looking at. We use -i flag with grep so that grep is case-insensitive.

We then do as in previous script and use cut to target a certain field of the log entry and save it to a variable. We also use "tr" to remove characters that we dont want present in the log file. We do this for all the information that we want. We then add all the trimmed information we want to the file which we will be saved. We remove the temporary file we created and finally present a message that lets us know that a log file has been created for the user that we wanted information about. 

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

(Also created a script to generate timeline for user "kim" automatically.)
kim_auto.sh:

Simply runs the scripts that have been described above and gets user "kim"'s log file.

#!/bin/bash
./adjust_merge_sort.sh
./user_timeline.sh Kim