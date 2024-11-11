#!/bin/bash

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


if [ $rep = '1' ]
then
rep=''
else
rep='_rep'$rep
fi

if [ $box_size = '3' ] || [ $box_size = '' ]
then
boxsize=''
else
boxsize='_'$box_size'nm'
fi

if [ $for_or_back = 'forward' ] || [ $for_or_back = 'for' ] || [ $for_or_back = 'forwards' ]
then
forback=''
elif [ $for_or_back = 'backward' ] || [ $for_or_back = 'back' ] || [ $for_or_back = 'backwards' ]
then
forback='_backward'
fi

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
        cation2=$cation
        cation=water
        anion2=$anion
        anion=''
        elif [ $cation_or_anion == 'methane' ]
        then
        cation2=$cation
        cation=methane
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

cd "$wd"/"$cation""$anion"_"$conc"M_"$temperature"K_"$length"ns_"$cation_or_anion""$rep"/Lambda_0/Production_MD

if [ ! -s msd.xvg ]
then
if [ "$cation_or_anion" == 'salt' ]
then
 echo '7
 6
 1' | gmx msd -f md0.trr -s md0.tpr -o msd.xvg
 else
 echo '5
 1' | gmx msd -f md0.trr -s md0.tpr -o msd.xvg
 fi
else
echo $PWD
grep s0 msd.xvg
grep s1 msd.xvg
fi

cd $wd
