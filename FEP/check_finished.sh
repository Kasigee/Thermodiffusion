#!/bin/bash

wd=$PWD

#if grep 'Finished mdrun' "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion"/Lambda_*/Production_MD/md*.log
#grep 'Finished mdrun' "$wd"/*/Lambda_*/Production_MD/md*.log | awk -F'.log' '{print $1}' | awk -F'md' '{print $2}'
#for i in $(grep 'Finished mdrun' "$wd"/*/Lambda_*/Production_MD/md*.log)
#do
#	echo $i
#done

finished_files="Finished_files.dat"

# Search through the directory for files containing the string 'Finished mdrun'
for file in $(find $wd -type f -name "md*.log")
do
    if grep -q 'Finished mdrun' $file
    then
        # Check if the file is already listed in Finished_files.dat
        if ! grep -q $file $finished_files
        then
            echo $file >> $finished_files
        fi
    fi
done
