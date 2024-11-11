#!/bin/bash

if [ $# -ne 8 ]
then
	echo $0 cation anion temperatureerature conc simulation_time forback rep Lambda 
	exit 0
fi

module load vmd gromacs

wd=$PWD
cation=$1
anion=$2
temperature=$3
conc=$4
simulation_time=$5
for_or_back=$6
rep=$7
lambda=$8

if [ $rep = '1' ]
then
rep=''
else
rep='_rep'$rep
fi


if [ $for_or_back = 'forward' ] || [ $for_or_back = 'for' ] || [ $for_or_back = 'forwards' ]
then
forback=''
elif [ $for_or_back = 'backward' ] || [ $for_or_back = 'back' ] || [ $for_or_back = 'backwards' ]
then
forback='_backward'
fi

echo "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$simulation_time"ns_salt"$rep"/Lambda_"$lambda"/Production_MD"$forback" 
if [ -d "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$simulation_time"ns_salt"$rep"/Lambda_"$lambda"/Production_MD"$forback" ]
then
	cd "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$simulation_time"ns_salt"$rep"/
	if [ ! -f "$cation""$anion"_water_fixed.pdb ]
	then
		gmx editconf -f "$cation""$anion"_water_fixed.gro -o "$cation""$anion"_water_fixed.pdb
	fi
	cd "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$simulation_time"ns_salt"$rep"/Lambda_"$lambda"/Production_MD"$forback"
	cp "$wd"/analyse_distance_over_time.tcl .
	#sed -i 's/new your_structure_file.tpr/new md'$lambda'.tpr/g' analyse_distance_over_time.tcl
        sed -i 's/new your_structure_file.tpr/new ..\/..\/'$cation''$anion'_water_fixed.pdb/g' analyse_distance_over_time.tcl
	sed -i 's/your_trajectory_file.xtc type xtc/md'$lambda'.trr type trr/g' analyse_distance_over_time.tcl
	sed -i 's/NA/'$cation'/g'  analyse_distance_over_time.tcl
	sed -i 's/CL/'$anion'/g'  analyse_distance_over_time.tcl
	vmd -dispdev text -e analyse_distance_over_time.tcl
	sleep 4
	#./plot_distance_over_time.py
	#$wd/plot_distances.py
else
	echo ""$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$simulation_time"ns_salt"$rep"/Lambda_"$lambda"/Production_MD"$forback" doesn't exist"
	exit 0
fi
