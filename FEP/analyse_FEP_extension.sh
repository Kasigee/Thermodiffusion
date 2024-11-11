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

if [ $for_or_back = 'forward' ] || [ $for_or_back = 'for' ] || [ $for_or_back = 'forwards' ]
then
forback=''
lambda_num=0
possibleFrames=100000
elif [ $for_or_back = 'backward' ] || [ $for_or_back = 'back' ] || [ $for_or_back = 'backwards' ]
then
forback='_backward'
lambda_num=20
possibleFrames=20000
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

if [ $cation == 'LI' ] && [ $cation_or_anion == 'cation' ]
then
#shellCutOff=2.35
shellCutOff=2.6
elif [ $cation == 'NA' ] && [ $cation_or_anion == 'cation' ]
then
#shellCutOff=3.15
shellCutOff=3.1
elif [ $cation == 'KA' ] && [ $cation_or_anion == 'cation' ]
then
#shellCutOff=3.6
shellCutOff=3.5
#elif [ $cation == 'RB' ] && [ $cation_or_anion == 'cation' ]
#then
#shellCutOff=
#elif [ $cation == 'CS' ] && [ $cation_or_anion == 'cation' ]
#then
#shellCutOff=
elif [ $anion == 'FL' ] && [ $cation_or_anion == 'anion' ]
then
shellCutOff=2.5
elif [ $anion == 'CL' ] && [ $cation_or_anion == 'anion' ]
then
shellCutOff=3.15
elif [ $anion == 'IO' ] && [ $cation_or_anion == 'anion' ] || [ $anion == 'IB' ] && [ $cation_or_anion == 'anion' ] ||  [ $anion == 'IC' ] && [ $cation_or_anion == 'anion' ] ||  [ $anion == 'IF' ] && [ $cation_or_anion == 'anion' ] ||  [ $anion == 'IG' ] && [ $cation_or_anion == 'anion' ]
then
shellCutOff=3.55
elif [ $anion == 'IA' ] && [ $cation_or_anion == 'anion' ]
then
shellCutOff=4.05
elif [ $anion == 'IE' ] && [ $cation_or_anion == 'anion' ]
then
shellCutOff=2.85
#fi

fi


declare -A charge_data
charge_data=( [LI]=1.00000 [NA]=1.00000 [KA]=1.00000 [RB]=1.00000 [CS]=1.00000 [BE]=2.00000 [MG]=2.00000 [CA]=2.00000 [SR]=2.00000 [BA]=2.00000 [B]=3.00000 [AL]=3.00000 [GA]=3.00000 [FL]=-1.00000 [CL]=-1.00000 [BR]=-1.00000 [IO]=-1.00000 )
declare -A mass_data
mass_data=( [LI]=6.9400 [NA]=22.9898 [KA]=39.0983 [RB]=85.4678 [CS]=132.9055 [BE]=9.012182 [MG]=24.3050 [CA]=40.0780 [SR]=87.62 [BA]=137.327 [AL]=26.98154 [FL]=18.9984 [CL]=35.4500 [BR]=79.9040 [IO]=126.9045 )

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
        cation=''
        anion2=$anion
        anion=''
        fi
else
nions=$(printf "%.0f" $(echo "16 *(("$box_size"^3)/(3^3)) * $conc" | bc )) #adjust to conc... Maybe this will work?
#echo nions $nions
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

if [[ $forback == '' ]]
then
 #num=$(echo 0 1 9 10)
 i=0
else
 i=20
 #num=$(echo 20 19 10 11)
fi

if [ "$cation_or_anion" == 'salt' ]
then
#end_steps_target=500000000
#end_time_target=1000000
#end_steps_target=50000000
#end_time_target=100000
end_steps_target=1000000
end_time_target=20000
else
end_steps_target=5000000
end_time_target=20000
fi

FinCount=$(grep "Finished mdrun on rank 0" "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$rep"/Lambda_"$i"/Production_MD"$forback"/md"$i".log | wc -l)
end_steps=$( tail -n300 "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$rep"/Lambda_"$i"/Production_MD"$forback"/md"$i".log | grep 'Statistics' | awk '{print $3}')
#echo $1 $2 $3 $4 $5 $6 $7 $8 $FinCount $end_steps

#echo $end_steps
if [[ $FinCount -ge 1 ]] && [[ $end_steps -ge "$end_steps_target" ]];
#date
#if [ -f "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$rep"/Lambda_20/Production_MD"$forback"/md20.log ]
then
 #date
 XVGcount=$(ls "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$rep"/Lambda_[0-9]/Production_MD"$forback"/md*.xvg "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$rep"/Lambda_[0-9][0-9]/Production_MD"$forback"/md*.xvg | wc -l)
# if [ $(ls "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$rep"/Lambda_[0-9]/Production_MD"$forback"/md*.xvg "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$rep"/Lambda_[0-9][0-9]/Production_MD"$forback"/md*.xvg | wc -l) -ge 21 ]
 if [ $XVGcount -ge 21 ]
 then
  #date
  cd "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$rep"
  if [ -f CN_MRT"$forback".dat ]
  then
   #date
   CN=$(grep 'Coordination Numbers' CN_MRT"$forback".dat | awk '{print $NF}' | awk -F"}" '{print $1}')
   MRT1=$(grep 'Residence Times Cutoff' CN_MRT"$forback".dat | awk '{print $NF}' | awk -F"}" '{print $1}')
   MRT2=$(grep 'Residence Times Fit' CN_MRT"$forback".dat | awk '{print $NF}' | awk -F"}" '{print $1}')
#  else
#   CN='-'
#   MRT1='-'
#   MRT2='-'
  fi
  if [ -f CN_MRT_ionpair"$forback".dat ]
  then
   IP=$(grep 'Coordination Numbers' CN_MRT_ionpair"$forback".dat | awk '{print $NF}' | awk -F"}" '{print $1}')
   IPL1=$(grep 'Residence Times Cutoff' CN_MRT_ionpair"$forback".dat | awk '{print $NF}' | awk -F"}" '{print $1}')
   IPL2=$(grep 'Residence Times Fit' CN_MRT_ionpair"$forback".dat | awk '{print $NF}' | awk -F"}" '{print $1}')
#  else
#   IP='.'
#   IPL1='.'
#   IPL2='.'
  fi
 
#  if [ ! -f bar_analysis"$forback"_extend"$end_time_target".dat ]
  if [ ! -f bar_analysis"$forback"_extend"$end_steps".dat ] || [ $force == 'yes' ]
  then
   module load gromacs
   gmx bar -f $(ls Lambda_[0-9]/Production_MD"$forback"/md*.xvg Lambda_[0-9][0-9]/Production_MD"$forback"/md*.xvg) -o -oi > bar_analysis"$forback"_extend"$end_steps".dat
   #gmx bar -f $(ls Lambda_[0-9]/Production_MD"$forback"/md*.xvg Lambda_[0-9][0-9]/Production_MD"$forback"/md*.xvg) -o -oi -e 20000 > bar_analysis_20000.dat
   tail -n48 bar_analysis"$forback"_extend"$end_steps".dat
   FE=$(tail -n48 bar_analysis"$forback"_extend"$end_steps".dat | grep total | awk '{print $6}')
   FEerr=$(tail -n48 bar_analysis"$forback"_extend"$end_steps".dat | grep total | awk '{print $8}')
   if [[ $forback != '_backward' ]]
   then
    FE=$(echo "-$FE")
   fi
   echo $1 $2 $3 $4 $5"_extend" $6 $7 $8 $FE $FEerr
   #python ../sum_values.py
   #echo $1 $2 $3 $4 $5 $6 $7
   cd $wd
   #exit 0
  else
   FE=$(tail -n48 bar_analysis"$forback"_extend"$end_steps".dat | grep total | awk '{print $6}')
   FEerr=$(tail -n48 bar_analysis"$forback"_extend"$end_steps".dat | grep total | awk '{print $8}')
   if [[ $forback != '_backward' ]]
   then
    FE=$(echo "-$FE")
   fi
   #python ../sum_values.py
   output=$(python ../sum_values.py bar_analysis"$forback"_extend"$end_steps".dat $temperature)
   SA=$(echo $output | awk '{print $3}')
   SAerr=$(echo $output | awk '{print $5}')
   SB=$(echo $output | awk '{print $8}')
   SBerr=$(echo $output | awk '{print $10}')

#totalframes=$(echo "$(tail -n1000 Lambda_0/Production_MD/md0.log | grep 'Writing checkpoint, step' | awk '{print $4}' ) * 2" | bc )
#totalps=$(echo "$totalframes / 1000" | bc )
if [ Lambda_"$lambda_num"/Production_MD"$forback"/md"$lambda_num".log ]
then
totalframes=$( echo "$(tail -n1000  Lambda_"$lambda_num"/Production_MD"$forback"/md"$lambda_num".log | grep -w 'Writing checkpoint, step' | tail -n1 | awk '{print $4}') / 500" | bc )
totalns=$(echo "$totalframes / 1000" | bc )
else
totalframes=$possibleFrames
fi
#echo $totalframes
#echo $totalps
if [ -f SolvAn_"$shellCutOff""$forback"_"$totalframes".dat ]
then
        #echo SolvAn_"$shellCutOff""$forback".dat exists
        #cat SolvAn_"$shellCutOff""$forback".dat
        #grep CN SolvAn_"$shellCutOff""$forback".dat
        CN=$(grep CN SolvAn_"$shellCutOff""$forback"_"$totalframes".dat | awk '{sum += $6} END {printf "%.5f\n", sum/NR}')
        #CN_err=$(grep CN SolvAn_"$shellCutOff""$forback"_"$totalframes".dat | awk '{sum += $6; sumsq += ($6)^2} END {printf "%.5f\n", sqrt(sumsq/NR - (sum/NR)^2)}') #STDEV
        CN_err=$(grep CN SolvAn_"$shellCutOff""$forback"_"$totalframes".dat | awk '{sum += $6; sumsq += ($6)^2} END {printf "%.5f\n", sqrt(sumsq/NR - (sum/NR)^2)/5}') #STERR from 5 "replicates"
        MRT=$(grep CN SolvAn_"$shellCutOff""$forback"_"$totalframes".dat | awk '{sum += $11} END {printf "%.5f\n", sum/NR}')
#        MRT_err=$(grep CN SolvAn_"$shellCutOff""$forback"_"$totalframes".dat | awk '{sum += $11; sumsq += ($11)^2} END {printf "%.5f\n", sqrt(sumsq/NR - (sum/NR)^2)}') #STDEV
        MRT_err=$(grep CN SolvAn_"$shellCutOff""$forback"_"$totalframes".dat | awk '{sum += $11; sumsq += ($11)^2} END {printf "%.5f\n", sqrt(sumsq/NR - (sum/NR)^2)/5}')  #STERR from 5 "replicates"
        MRT_fit=$(grep CN SolvAn_"$shellCutOff""$forback"_"$totalframes".dat | awk '{sum += $13} END {printf "%.5f\n", sum/NR}')
#        MRT_fit_err=$(grep CN SolvAn_"$shellCutOff""$forback"_"$totalframes".dat | awk '{sum += $13; sumsq += ($13)^2} END {printf "%.5f\n", sqrt(sumsq/NR - (sum/NR)^2)}') #STDEV
        MRT_fit_err=$(grep CN SolvAn_"$shellCutOff""$forback"_"$totalframes".dat | awk '{sum += $13; sumsq += ($13)^2} END {printf "%.5f\n", sqrt(sumsq/NR - (sum/NR)^2)/5}')  #STERR from 5 "replicates"
#        echo $CN $CN_err $MRT $MRT_err $MRT_fit $MRT_fit_err
#        exit 0
fi

if [ -f IonPair_"$IP_cutOFF""$forback"_"$totalframes".dat ]
then
echo "FIX this part of the script with reference to the about if-then-else statement, but using the IonPair.dat files"
#else
#	IP='.'
#	IPL1='.'
#	IPL2='.'
fi

actual_length=$(echo "$end_steps * 2 / 1000 / 1000" | bc )

  echo $1 $2 $3 $4 $5"_extend" $actual_length $6 $7 $8 $FE $FEerr $SA $SAerr $SB $SBerr $CN $CN_err $MRT $MRT_err $MRT_fit $MRT_fit_err $IP $IPL1 $IPL2
#   echo $1 $2 $3 $4 $5"_extend" $6 $7 $8 $FE $FEerr $SA $SAerr $SB $SBerr
   if grep WARNING bar_analysis"$forback"_extend"$end_steps".dat 
   then
    echo 'WARNING in this --> indicating some part didnt run long enough'
   fi
   if [ -d Lambda_0/EM ]
   then
    rm -r Lambda_[0-9]/EM Lambda_[0-9][0-9]/EM
   fi
   if [ -d Lambda_0/NVT ]
   then
    rm -r Lambda_[0-9]/NVT Lambda_[0-9][0-9]/NVT
   fi
   if [ -d Lambda_0/NPT ]
   then
    rm -r Lambda_[0-9]/NPT Lambda_[0-9][0-9]/NPT
   fi
   if  [ -d MDP/NPT"$forback" ]
   then
    rm -r MDP/NPT"$forback" MDP/NVT"$forback" MDP/Production_MD"$forback" MDP/topol.top
   fi
  
   #python ../sum_values.py
   cd $wd
  fi
  #echo  $1 $2 $3 $4 $5"_extend" $6 $7 $8  FINCOUNT $FinCount ENDSTEPS $end_steps
  exit 0
 fi
 echo  $1 $2 $3 $4 $5"_extend" $6 $7 $8  FINCOUNT $FinCount ENDSTEPS $end_steps XVGCOUNT $XVGcount
else
echo "$end_steps -ge "$end_steps_target""
echo $1 $2 $3 $4 $5 $6 $7 $8 $FinCount $end_steps
fi
