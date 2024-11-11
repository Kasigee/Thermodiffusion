#!/bin/bash
#!/bin/perl

if [ $# -ne 10 ] && [ $# -ne 11 ] 
then
echo "$0 cation anion concentration(M) temperature(K) length(ns) investigating_anion_or_cation forward_or_backward replicate parallel box_size force"
exit 0
fi

wd=$PWD

cation=$1
anion=$2
conc=$3
temperature=$4
length=$5
cation_or_anion=$6
for_or_back=$7
rep=$8
parallel=$9
box_size=${10}
force=${11}
queuelimit=25

echo cation=$cation anion=$anion conc=$conc temp=$temperature length=$length cation_or_anion=$cation_or_anion for_or_back=$for_or_back rep=$rep parallel=$parallel box_size=$box_size force=$force 


if [ $for_or_back = 'forward' ] || [ $for_or_back = 'for' ] || [ $for_or_back = 'forwards' ]
then
forback=''
elif [ $for_or_back = 'backward' ] || [ $for_or_back = 'back' ] || [ $for_or_back = 'backwards' ]
then
forback='_backward'
fi

if [ $box_size = '3' ] || [ $box_size = '' ]
then
boxsize=''
else
boxsize='_'$box_size'nm'
fi


if [ $rep = '1' ]
then
rep=''
else
rep='_rep'$rep
fi

cp /scratch/g15/kpg575/GROMACS/empty-box.gro empty-box.gro

timestep=0.002
nsteps=$(echo "$length/$timestep *1000" | bc )

cation=$(echo "$cation" | tr '[:lower:]' '[:upper:]')
anion=$(echo "$anion" | tr '[:lower:]' '[:upper:]')

if [ $cation == 'K' ]
then
cation='KA'
fi
if [ $anion == 'F' ]
then
anion='FL'
fi
if [ $anion == 'I' ]
then
anion='IO'
fi



declare -A charge_data
charge_data=( [LI]=1.00000 [NA]=1.00000 [KA]=1.00000 [RB]=1.00000 [CS]=1.00000 [BE]=2.00000 [MG]=2.00000 [CA]=2.00000 [SR]=2.00000 [BA]=2.00000 [B]=3.00000 [AL]=3.00000 [GA]=3.00000 [FL]=-1.00000 [CL]=-1.00000 [BR]=-1.00000 [IO]=-1.00000 [IA]=-1.00000 [IB]=-1.00000 [IC]=-1.00000 [IE]=-1.00000 [IF]=-0.50000 [IG]=-2.00000 )
declare -A mass_data
mass_data=( [LI]=6.9400 [NA]=22.9898 [KA]=39.0983 [RB]=85.4678 [CS]=132.9055 [BE]=9.012182 [MG]=24.3050 [CA]=40.0780 [SR]=87.62 [BA]=137.327 [AL]=26.98154 [FL]=18.9984 [CL]=35.4500 [BR]=79.9040 [IO]=126.9045 [IA]=126.9045 [IB]=126.9045 [IC]=126.9045 [IE]=126.9045 [IF]=126.9045 [IG]=126.9045)

cationcharge=${charge_data[$cation]}
anioncharge=${charge_data[$anion]}
cationmass=${mass_data[$cation]}
anionmass=${mass_data[$anion]}

if [ $conc  == 0 ]
then
nions=1
nions2=0
        if [ $cation_or_anion == 'cation' ]
        then
        anion2=$anion
        anion=''
        cation2=$cation
        elif [ $cation_or_anion == 'anion' ]
        then
        cation2=$cation
        cation=''
        anion2=$anion
        elif [ $cation_or_anion == 'both' ] || [ $cation_or_anion == 'salt' ]
        then
        cation_or_anion='salt'
        anion2=$anion
        cation2=$cation
        nions2=1
        elif [ $cation_or_anion == 'water' ]
        then
#       else
        cation2=$cation
        cation=water
        anion2=$anion
        anion=''
        elif [ $cation_or_anion == 'methane' ]
        then
#       else
        cation2=$cation
        cation=methane
        anion2=$anion
        anion=''
	elif [ $cation_or_anion == 'H2' ]
        then
#       else
        cation2=$cation
        cation=H2
        anion2=$anion
        anion=''
        elif [ $cation_or_anion == 'NaFcluster' ]
        then
#       else
        cation2=$cation
        cation=NaFcluster
        anion2=$anion
        anion=''
        fi
else
nions=$(printf "%.0f" $(echo "16 *(("$box_size"^3)/(3^3)) * $conc" | bc )) #adjust to conc... Maybe this will work?
echo nions $nions
        if [ $cation_or_anion == 'both' ] || [ $cation_or_anion == 'salt' ]
        then
        cation_or_anion='salt'
#       nions2=$nions
        nions2=$(printf "%.0f" $(echo "$nions - 1" | bc ))
        nions3=$(printf "%.0f" $(echo "$nions - 1" | bc ))
                if [ $cation == 'BE' ] || [ $cation == 'MG' ] || [ $cation == 'CA' ] || [ $cation == 'BA' ] || [ $cation == 'SR' ]
                then
                nions2=$(printf "%.0f" $(echo "($nions)*2" | bc ))
                fi
        elif [ $cation == 'BE' ] || [ $cation == 'MG' ] || [ $cation == 'CA' ] || [ $cation == 'BA' ] || [ $cation == 'SR' ]
        then
        nions2=$(printf "%.0f" $(echo "($nions - 1)*2" | bc ))
        else
        nions2=$(printf "%.0f" $(echo "$nions - 1" | bc ))
        fi
cation2=$cation
anion2=$anion
fi



#if [ $(ls "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"/Lambda_[0-9]/Production_MD"$forback"/md*.xvg "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"/Lambda_[0-9][0-9]/Production_MD"$forback"/md*.xvg | wc -l) -ge 21 ]
#then
#cd "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"
#if [ ! -f bar_analysis"$forback".dat ]
#then
#module load gromacs
#gmx bar -f $(ls Lambda_[0-9]/Production_MD"$forback"/md*.xvg Lambda_[0-9][0-9]/Production_MD"$forback"/md*.xvg) -o -oi > bar_analysis"$forback".dat
#tail -n48 bar_analysis"$forback".dat
#fi
#exit 0
if [ $(ls "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"/Lambda_[0-9]/Production_MD"$forback"/md*.xvg "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"/Lambda_[0-9][0-9]/Production_MD"$forback"/md*.xvg | wc -l) -ge 21 ]
then
cd "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep" 
if [ ! -f bar_analysis"$forback".dat ]
then
module load gromacs
gmx bar -f $(ls Lambda_[0-9]/Production_MD"$forback"/md*.xvg Lambda_[0-9][0-9]/Production_MD"$forback"/md*.xvg) -o -oi > bar_analysis"$forback".dat
tail -n48 bar_analysis"$forback".dat
echo $1 $2 $3 $4 $5 $6 $7 $8
cd $wd
exit 0
else
tail -n48 bar_analysis"$forback".dat
echo $1 $2 $3 $4 $5 $6 $7 $8
cd $wd
exit 0
fi
exit 0
fi

module load gromacs


numberqued=`qstat -u kpg575 | grep Q | grep vol | wc -l`


#qued=`qstat -f | tr -d '\n' | tr -d '[:blank:]' | grep "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"  | wc -l`
qued=`qstat -f | tr -d '\n' | tr -d '[:blank:]' | grep "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"/"$cation""$anion"."$forback".olog  | wc -l`
#qued2=`qstat -u kpg575 | grep gpuvol | grep Q | wc -l`
qued2=`qstat -u kpg575 | grep Q | grep gpuvol |  wc -l`

if [ $qued -ge 1 ]
then
echo Not queuing - Queued
elif [ $qued2 -ge $queuelimit ]
then
echo Not queuing - Personal Limit
#elif [ $numberqued -ge 40 ]
#then
#       echo Too many personal jobs qued
#       exit 0
else
if grep 'Finished mdrun' "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"/Lambda_20/Production_MD"$forback"/md20.log   && [ $force != 'yes' ]
then
echo skip to analysis
else

echo cp template_solvating.top "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
cp template_solvating.top "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
#if [ $ion == 'Li' ] || [ $ion == 'Na' ] || [ $ion == 'K' ] || [ $ion == 'Rb' ] || [ $ion == 'Cs' ] || [ $ion == 'Be' ] || [ $ion == 'Mg' ] || [ $ion == 'Ca' ] || [ $ion == 'Ba' ] || [ $ion == 'Sr' ]
#then
#iontype='cation'
#else
#iontype='anion'
#fi

if [ "$(grep "$cation" $wd/"$cation""$anion"_"$conc"M_water.gro | wc -l)" -ne "$nions2" ]
then
	rm $wd/"$cation""$anion"_"$conc"M_water.gro
fi

#if [ ! -f  "$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"/"$cation""$anion"_water_fixed.gro ] || ( grep 'Finished mdrun' "$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"/Lambda_*/Production_MD/m*.log )
#if ! grep 'Finished mdrun' "$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"/Lambda_*/Production_MD"$forback"/m*.log 
#then
cp /scratch/g15/kpg575/GROMACS/empty-box.gro empty-box.gro
sed -i 's/XXXXXX/'$box_size'/g' empty-box.gro
sed -i 's/YYYYYY/'$box_size'/g' empty-box.gro
sed -i 's/ZZZZZZ/'$box_size'/g' empty-box.gro
sed -i 's/Placeholder Title/'$solvent_forcefield' '$cation''$anion' '$conc'M '$box_size' '$box_size' '$box_size'/g' empty-box.gro
echo "Solvating"
if [ ! $cation_or_anion == 'methane' ] && [ ! $cation_or_anion == 'H2' ] && [ ! $cation_or_anion == 'NaFcluster' ]; then
gmx solvate -cp empty-box.gro -o water-box.gro -cs spc216.gro -p "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top #fix watermodel in this line
mv water-box.gro "$cation""$anion"_"$conc"M_water.gro
elif [ $cation_or_anion == 'methane' ]; then
#gmx editconf -f methane.gro -o methane_box.gro -c -d 1.0 -bt cubic
#gmx solvate -cp methane.gro -cs spc216.gro -o methane_solv.gro -p topol.top
echo 'MED                 1' >> "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
gmx solvate -cp methane.gro -cs spc216.gro -o methane_solv.gro -p "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top #fix watermodel in this line
mv methane_solv.gro "$cation""$anion"_"$conc"M_water.gro
elif [ $cation_or_anion == 'H2' ]; then
echo 'H2D                 1' >> "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
gmx solvate -cp H2D.gro -cs spc216.gro -o H2D_solv.gro -p "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top #fix watermodel in this line
mv H2D_solv.gro "$cation""$anion"_"$conc"M_water.gro
elif [ $cation_or_anion == 'NaFcluster' ]; then
  echo NaFCluster
  echo 'NFC                 1' >> "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
  gmx solvate -cp NaFcluster.gro -cs spc216.gro -o NaFcluster_solv.gro -p "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top #fix watermodel in this line
  echo Sovating done
  mv NaFcluster_solv.gro "$cation""$anion"_"$conc"M_water.gro
fi
#exit 0
gmx grompp -f minim.mdp -c "$cation""$anion"_"$conc"M_water.gro -o ion.tpr -p "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top -maxwarn 2
#cp topol-water.top topol-"$cation""$anion"-"$conc"M.top
echo number of ions is $nions at "$conc"M for box with width "$box_size"nm
#if [ ! -f  "$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"/"$cation""$anion"_water_fixed.gro ] || ( grep 'Finished mdrun' "$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"/Lambda_*/Production_MD/m*.log )
#if  ( grep 'Finished mdrun' "$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"/Lambda_*/Production_MD/m*.log )
#then
#echo "if [ $cation_or_anion == 'water' ] || [ $cation2 == 'methane' ] || [ $anion2 == 'methane' ]"
        if [ $cation_or_anion == 'water' ] || [ $cation2 == 'methane' ] || [ $anion2 == 'methane' ] || [ $cation2 == 'H2' ] || [ $anion2 == 'H2' ] || [ $cation2 == 'NaFcluster' ] || [ $anion2 == 'NaFcluster' ]
        then
        echo "2" | gmx genion -s ion.tpr -o "$cation""$anion"_"$conc"M_water.gro -p "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top -pname $cation2 -nname $anion2 -np 0 -nn 0 -rmin 0.3
	elif  [ $cation_or_anion == 'salt' ]
	then
	echo "2" | gmx genion -s ion.tpr -o "$cation""$anion"_"$conc"M_water.gro -p "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top -pname $cation2 -nname $anion2 -np $nions2 -nn $nions2 -rmin 0.3
		if [ ! $conc == 0 ]
		then
	        gmx grompp -f minim.mdp -c "$cation""$anion"_"$conc"M_water.gro -o ion2.tpr -p "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top -maxwarn 2
		echo "2" | gmx genion -s ion2.tpr -o "$cation""$anion"_"$conc"M_water.gro -p "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top -pname $cation2 -nname $anion2 -np 1 -nn 1 -rmin 0.3
		fi
	elif [ $cation_or_anion == 'cation' ]
	then
	echo "2" | gmx genion -s ion.tpr -o "$cation""$anion"_"$conc"M_water.gro -p "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top -pname $cation2 -nname $anion2 -np $nions -nn $nions2 -rmin 0.3
	elif [ $cation_or_anion == 'anion' ]
	then
	echo "2" | gmx genion -s ion.tpr -o "$cation""$anion"_"$conc"M_water.gro -p "$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top -pname $cation2 -nname $anion2 -np $nions2 -nn $nions -rmin 0.3
	fi
#fi




if [ ! -d "$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns ]
then
mkdir "$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"
fi

fi # end of check - to prevent making new box; will jump to analysis


fewd=$( echo "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep" )
#cd "$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"
#mv $wd/"$cation""$anion"_"$conc"M_water.gro "$cation""$anion"_water_fixed.gro
cp -r $wd/template_files/MDP $fewd/.
#if [ ! -s $fewd/topol.top ]
#then
#cp $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top $fewd/topol.top
# if [ ! -s $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top ]
# then
# echo $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top empty, check why?
# exit 0
#fi
#fi
#echo XXXXXXXXXXXXXXXXXXX mv $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top $fewd/topol.top XXXXXXXXXXXXXXXXXXXXXX

if [ $parallel == 'no' ]
then
cp $wd/template_files/qjob $fewd/.
else
cp $wd/template_files/qjob_parallel $fewd/.
fi

echo "FEWD = ."$fewd"."

linevar=$(grep 'nsteps' "$fewd"/MDP/Production_MD"$forback"/md_0.mdp)
sed -i 's/'$linevar'/nsteps                   = '$nsteps' /g' $fewd/MDP/Production_MD"$forback"/md*.mdp
sed -i 's/nsteps                   = 500000 /nsteps                   = '$nsteps' /g' $fewd/MDP/Production_MD"$forback"/md*.mdp
sed -i 's/nsteps                   = 50000000000 /nsteps                   = '$nsteps' /g' $fewd/MDP/Production_MD"$forback"/md*.mdp
sed -i 's/ref_t                    = 300 /ref_t                    = '$temperature' /g' $fewd/MDP/*"$forback"/*.mdp

if [ $cation_or_anion == 'cation' ]
then
#sed -i '0,/NA/{s/NA/'$cation'D/g}' "$cation""$anion"_water_fixed.gro
#sed -i '1,2b; 0,/NA / s//'$cation'D/;0,/ NA / s//'$cation'D /' $wd/"$cation""$anion"_"$conc"M_water.gro
sed -i '1,2b; 0,/'$cation' / s//'$cation'D/;0,/ '$cation' / s//'$cation'D /' $wd/"$cation""$anion"_"$conc"M_water.gro
sed -i 's/couple-moltype           = NA /couple-moltype           = '$cation'D /' $fewd/MDP/*"$forback"/*.mdp
sed -i 's/couple-moltype           = NAD /couple-moltype           = '$cation'D /' $fewd/MDP/*"$forback"/*.mdp
#sed -i 's/NA /'$cation'/g' "$cation""$anion"_water_fixed.gro
	if [ $conc  == 0 ]
	then
	sed -i 's/'$cation'               1/'$cation'D               1/' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
	# Reverse the file, replace the first occurrence (which is actually the last in the original file), and reverse it back
	tac $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top | awk '!changed && /"\$anion"/{sub(/"\$cation"/, "\"$cation\"D"); changed=1} 1' | tac > temp.txt
	
	# Move the temporary file back to the original file
	mv temp.txt $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
	else
	sed -i 's/'$cation'               '$nions'/'$cation'               '$nions2'/' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
	echo ''$cation'D               1' >> $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
	fi
elif [ $cation_or_anion == 'anion' ]
then
sed -i '1,2b; 0,/'$anion' / s//'$anion'D/;0,/ '$anion' / s//'$anion'D /' $wd/"$cation""$anion"_"$conc"M_water.gro
sed -i 's/couple-moltype           = NA /couple-moltype           = '$anion'D /' $fewd/MDP/*"$forback"/*.mdp
sed -i 's/couple-moltype           = NAD /couple-moltype           = '$anion'D /' $fewd/MDP/*"$forback"/*.mdp
#sed -i 's/NA /'$anion'/g' "$cation""$anion"_water_fixed.gro
	if [ $conc == 0 ]
	then
#	echo ERROR?
	sed -i 's/'$anion'               1/'$anion'D               1/' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
#	sed -i "s/$anion'              '1/"$anion"D'              '1/" $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
#echo 'sed -i s/'$anion'               1/'$anion'D               1/ $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top'
#echo	$wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
#	echo ERROR??
	# Reverse the file, replace the first occurrence (which is actually the last in the original file), and reverse it back
        tac $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top | awk '!changed && /"\$anion"/{sub(/"\$anion"/, "\"$anion\"D"); changed=1} 1' | tac > temp.txt

        # Move the temporary file back to the original file
        mv temp.txt $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
	else
	sed -i 's/'$anion'               '$nions'/'$anion'               '$nions2'/' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
	echo ''$anion'D               1' >> $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
	fi
elif [ $cation_or_anion == 'salt' ]
then
sed -i '1,2b; 0,/'$cation' / s//SAL/;0,/ '$cation' / s//'$cation'D /' $wd/"$cation""$anion"_"$conc"M_water.gro
sed -i '1,2b; 0,/'$anion' / s//SAL/;0,/ '$anion' / s//'$anion'D /' $wd/"$cation""$anion"_"$conc"M_water.gro
sed -i 's/couple-moltype           = NA /couple-moltype           = SAL /' $fewd/MDP/*"$forback"/*.mdp
sed -i 's/couple-moltype           = NAD /couple-moltype           = SAL /' $fewd/MDP/*"$forback"/*.mdp

#multilinevariable='
#; Define '$cation''$anion'D molecule type
#[ moleculetype ]
#; molname       nrexcl
#SAL        1
#
#[ atoms ]
#1  '$cation'D   1   SAL    '$cation'D   1   '$cationcharge' '$cationmass'
#2  '$anion'D   1   SAL    '$anion'D   1   '$anioncharge' '$anionmass''
#
#line_insert_num=$(grep -n '; Define LI molecule type' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top | awk -F':' '{print $1}')
#line_insert_num2=$(echo "$line_insert_num - 3" | bc )
#
#printf '%s\n' "$multilinevariable" | sed -i ''$line_insert_num2'r /dev/stdin' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top

sed -i 's/NA in water/'$ion' in water/g' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
sed -i 's/NA                       1/'$ion'                       1/g' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top

#sed -i 's/-maxwarn 2/-maxwarn 2 -n watbox_select.ndx/g' qjob
#if [ $conc  == 0 ]
#then
#echo '5|6
#q' | gmx make_ndx -f "$cation""$anion"_water_fixed.gro -o salt_select.ndx
#else
#echo '5|7
#q' | gmx make_ndx -f "$cation""$anion"_water_fixed.gro -o salt_select.ndx
#fi
#sed -i 's/NA /'$anion'/g' "$cation""$anion"_water_fixed.gro
	if [ $conc == 0 ]
        then
#        sed -i 's/'$cation'               1/'$cation'D               1/' $fewd/topol.top
#	sed -i 's/'$anion'               1/'$anion'D               1/' $fewd/topol.top
	sed -i 's/'$cation'               1/SAL               1/' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
	sed -i '/'$anion'               1/d' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
        else
        sed -i 's/'$cation'               '$nions'/'$cation'               '$nions3'/' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
	sed -i 's/'$anion'               '$nions'/'$anion'               '$nions3'/' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
        sed -i '0,/'$cation'               1/{//d}' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
        sed -i '0,/'$anion'               1/{//d}' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
	if [ -f $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top ]
	then
	echo 'SAL               1' >> $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
	fi
        #echo ''$cation'D               1' >> topol.top
       # echo ''$anion'D               1' >> topol.top
        fi


#echo "5|6|2
#q"| gmx make_ndx -f "$cation""$anion"_water_fixed.gro -o salt_select.ndx
#gmx grompp -f prod.mdp -c watbox_select_order.pdb -p topol_select.top -o md-"$cation""$anion"-"$conc"M-wat.tpr -r watbox_select_order.pdb -n salt_select.ndx -maxwarn 3
#sed -i 's/'$cation'               '$nions'/'$cation'               '$nions2'/' topol.top
#echo ''$cation'D               1' >> topol.top
elif [ $cation_or_anion == 'water' ]
then
#tac $wd/"$cation""$anion"_"$conc"M_water.gro | awk '{if (n<3) {gsub("SOL","DIS"); n++}} 1' | tac > temp && mv temp $wd/"$cation""$anion"_"$conc"M_water.gro
#perl -i -pe 'BEGIN{$n=0} if(@a = m/SOL/g){$n += scalar(@a)} if($n>3){s/SOL/DIS/g; $n -= @a} END{if($n>0){s/SOL/DIS/$n}}' $wd/"$cation""$anion"_"$conc"M_water.gro
sed -i 's/couple-moltype           = NA /couple-moltype           = DIS /' $fewd/MDP/*"$forback"/*.mdp
sed -i 's/couple-moltype           = NAD /couple-moltype           = DIS /' $fewd/MDP/*"$forback"/*.mdp
nsol=$(grep 'SOL' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top | tail -n1 | awk '{print $NF}')
lowsol=$( echo "$nsol -1" | bc )

echo nsol $nsol low sol $lowsol
#sed -i 's/ '$nsol'/'$lowsol'/
# DIS    1/' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
sed -i 's/'$nsol'SOL/'$nsol'DIS/g' $wd/"$cation""$anion"_"$conc"M_water.gro
sed -i 's/SOL         '$nsol'/SOL         '$nsol'/g' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
echo " following line is slightly dodgey coding - prone to changing other parts of the parameter file if the numbers match (but only by 1)"
sed -i 's/'$nsol'/'$lowsol'/g' $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
#sed -i "s/${nsol}/$(echo -e "${lowsol}\nDIS 1")/g" $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
echo 'DIS               1' >> $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top
fi
cd $fewd

if [[ -z $(cat  "$cation""$anion"_water_fixed.gro) ]] || [[ ! -e "$cation""$anion"_water_fixed.gro ]]
then
	mv $wd/"$cation""$anion"_"$conc"M_water.gro "$cation""$anion"_water_fixed.gro
elif [ "$(grep "$cation" $wd/"$cation""$anion"_"$conc"M_water.gro | wc -l)" -ne "$nions2" ]
then
	mv $wd/"$cation""$anion"_"$conc"M_water.gro "$cation""$anion"_water_fixed.gro
fi

#if [ ! -s $fewd/topol.top ]
#then
mv $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top $fewd/topol.top
# if [ ! -s $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top ]
# then
# echo $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top empty, check why?
# exit 0
#fi
#fi

#if [[ -z $(cat topol.top) ]] || [[ ! -e topol.top ]]
#then
#	mv $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top topol.top
##elif (( $(echo "$countDUMlines > 1" | bc -l) ))
##then
##	rm topol.top
##	mv $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top topol.top
#fi
#rm $wd/"$cation""$anion"_"$conc"M_water.gro
#rm $wd/"$cation""$anion"_"$conc"M_water_"$cation_or_anion""$boxsize""$rep".top

#else
#sed -i '1s/NA/'$anion'D/g' "$cation""$anion"_water_fixed.gro
#sed -i '1,2b; 0,/NA / s//'$anion'D/;0,/ NA / s//'$anion'D /' "$cation""$anion"_water_fixed.gro
#sed -i 's/NA /'$anion'/g' "$cation""$anion"_water_fixed.gro
#sed -i '1,2b; 0,/NA / s//'$anion'D/;0,/ NA / s//'$anion'D /' "$cation""$anion"_water_fixed.gro
#sed -i 's/couple-moltype           = NA /couple-moltype           = '$anion'D /' MDP/*/*.mdp
#sed -i 's/couple-moltype           = NAD /couple-moltype           = '$anion'D /' MDP/*/*.mdp
#sed -i 's/'$anion'               '$nions'/'$anion'               '$nions2'/' topol.top
#echo ''$anion'D               1' >> topol.top
#fi


# Find the line number of the first occurrence of "SAL"
lineNumber=$(grep -n "SAL" topol.top | head -n 1 | cut -d: -f1)

# Check if "SAL" was found in the file
if [ $cation_or_anion  == 'salt' ]
then
if [ $(grep -c "DUM$cation" topol.top) -lt 3 ]
then
if [ ! -z "$lineNumber" ]; then
    # Calculate the line to insert the new content
    insertLine=$((lineNumber + 2))
    
    # Check if the content already exists
#    if ! grep -A$(wc -l < topol.top) "^${lineNumber}" topol.top | grep -q "SAL.*DUM\|DUM.*SAL"; 
   # if ! grep -q '\[ atoms \]' topol.top || ! grep -q "${cation}D" topol.top || ! grep -q "${anion}D" topol.top;
#    then
#        # Insert the content at the calculated line
        sed -i "${insertLine}i\\
[ atoms ]\\
1  ${cation}D   1   SAL    ${cation}D   1   ${cationcharge} ${cationmass} DUM${cation} 0 ${cationmass}\\
2  ${anion}D   1   SAL    ${anion}D   1   ${anioncharge} ${anionmass} DUM${anion} 0 ${anionmass}
" topol.top
#    fi
else
    echo "The string 'SAL' was not found in topol.top"
fi
fi
fi

if [ $cation_or_anion == 'salt' ]
then 
# While the count of lines containing 'DUM'$cation is greater than 1
while [ $(grep -c "DUM$cation" topol.top) -gt 3 ]
do
    # Get the line number of the last occurrence of 'DUM'$cation
    lineno=$(grep -n "DUM$cation" topol.top | tail -2 | head -1 | cut -d: -f1)

        # If lineno is non-empty, delete the line and the preceding line from the file
    if [ ! -z "$lineno" ] && [ "$lineno" -gt 1 ]; then
        sed -i "$((lineno-1)),$lineno d" topol.top
    elif [ "$lineno" -eq 1 ]; then
        # If the match is found on the first line, only that line is deleted
        sed -i "${lineno}d" topol.top
    else
        echo "Pattern not found"
        exit 1
    fi
done

# While the count of lines containing 'DUM'$anion is greater than 1
while [ $(grep -c "DUM$anion" topol.top) -gt 3 ]
do
    # Get the line number of the last occurrence of 'DUM'$cation
    lineno=$(grep -n "DUM$anion" topol.top | tail -1 | head -1 | cut -d: -f1)

	# If lineno is non-empty, delete the line from the file
    if [ ! -z "$lineno" ]; then
        sed -i "${lineno}d" topol.top
    else
        echo "Pattern not found"
        exit 1
    fi
done
fi


if [ $cation_or_anion == 'salt' ]
then
if (( $(echo "$conc > 0" | bc -l) ))
then
	file="topol.top"
	sal_line=$(tail -n 1 $file | grep SAL)
	nad_line=$(tail -n 1 $file | grep "$cation"D)
	cld_line=$(tail -n 1 $file | grep "$anion"D)
	dis_line=$(tail -n 1 $file | grep DIS)
	if [ -n "$sal_line" ]; then
	    # Remove the last line
	    sed -i '$ d' $file

	    # Get the number of lines
	    num_lines=$(wc -l < $file)

	    # Insert the SAL line 2 lines up
	    awk -v n=$num_lines -v s="$sal_line" '(NR==n-1) {print s} 1' $file > temp && mv temp $file
	else
	    echo "Last line does not contain SAL"
	fi

	if [ -n "$nad_line" ]; then
	    # Remove the last line
	    sed -i '$ d' $file

	    # Get the number of lines
	    num_lines=$(wc -l < $file)

	    # Insert the "$cation" line 2 lines up
	    awk -v n=$num_lines -v s="$nad_line" '(NR==n-1) {print s} 1' $file > temp && mv temp $file
	else
	    echo "Last line does not contain "$cation"D"
	fi

	if [ -n "$cld_line" ]; then
	    # Remove the last line
	    sed -i '$ d' $file

	    # Get the number of lines
	    num_lines=$(wc -l < $file)

	    # Insert the "$anion"D line 2 lines up
	    awk -v n=$num_lines -v s="$cld_line" '(NR==n) {print s} 1' $file > temp && mv temp $file
	else
	    echo "Last line does not contain "$anion"D"

	fi
        if [ -n "$dis_line" ]; then
            # Remove the last line
            sed -i '$ d' $file

            # Get the number of lines
            num_lines=$(wc -l < $file)

            # Insert the SAL line 2 lines up
            awk -v n=$num_lines -v s="$dis_line" '(NR==n-1) {print s} 1' $file > temp && mv temp $file
        else
            echo "Last line does not contain SAL"
        fi
fi
fi



#sed -i 's/NA in water/'$ion' in water/g' topol.top
#sed -i 's/NA                       1/'$ion'                       1/g' topol.top

#if [ ! -f bar.xvg ]
#then
#qued=`qstat -f | tr -d '\n' | tr -d '[:blank:]' | grep "$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$boxsize""$rep"  | wc -l`
#if [ $qued -ge 1 ]
#then
#echo Not queuing
#else
sed -i 's/nsteps                   = 500000 /nsteps                   = '$nsteps' /g' $fewd/MDP/Production_MD"$forback"/md*.mdp
sed -i 's/nsteps                   = 50000000000 /nsteps                   = '$nsteps' /g' $fewd/MDP/Production_MD"$forback"/md*.mdp
sed -i 's/nsteps                   = 50000000000/nsteps                   = '$nsteps' /g' $fewd/MDP/Production_MD"$forback"/md*.mdp
sed -i 's/nsteps                   = 50000000000 /nsteps                   = '$nsteps' /g' $fewd/MDP/*/*.mdp
sed -i 's/ref_t                    = 300 /ref_t                    = '$temperature' /g' $fewd/MDP/*/*.mdp

sed -i 's/NA/'$cation''$anion'/g' qjob
if [ $parallel == 'no' ]
then
echo Running single job for all Lambdas
./qjob "$forback"
else
echo Running each Lambda in parallel
./qjob_parallel "$forback"
fi
fi
echo $1 $2 $3 $4 $5 $6 $7 $8
#else
#cat bar.xvg
#fi
