if [ $# -ne 6 ]
then
	#echo "$0 temperature(K) conc(M)"
	echo "$0 cation anion conc temp type forback"
	exit 0
fi

wd=$PWD

cation=$1
anion=$2
Conc=$3
Temperature=$4
type=$5
for_or_back=$6

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

if [ $type == 'cation' ]
then
element1='OW'
element2='OW'
ion=$cation
elif [ $type == 'anion' ]
then
element1='HW'
element2='HW1 or name HW2'
ion=$anion
fi

if [ $for_or_back = 'forward' ] || [ $for_or_back = 'for' ] || [ $for_or_back = 'forwards' ]
then
forback=''
lambda=0
elif [ $for_or_back = 'backward' ] || [ $for_or_back = 'back' ] || [ $for_or_back = 'backwards' ]
then
forback='_backward'
lambda=20
fi


cd "$ion"_"$Conc"M_"$Temperature"K_2ns_"$type"
echo $PWD
if [ ! -f rdf"$ion"*_*ions"$forback".xvg ] || [ ! -f rdf"$ion"*_*ions_cn"$forback".xvg ]
then
gmx rdf -f Lambda_"$lambda"/Production_MD"$forback"/md"$lambda".trr -s Lambda_"$lambda"/Production_MD"$forback"/md"$lambda".tpr -o rdf"$ion"-"$element1"_allions"$forback".xvg -cn "$i"rdf"$ion"-"$element1"_allions_cn"$forback".xvg  -selrpos atom -seltype atom -ref "name "$ion"D or name "$ion"" -sel "name $element2" -cut 0 -rmax 1.5

#gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$cation"_allions.xvg -selrpos atom -seltype atom -ref "name "$cation"D or name "$cation"" -sel "name "$cation"D or name "$cation"" -cut 0 -rmax 1.5
#gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$anion"_allions.xvg -selrpos atom -seltype atom -ref "name "$cation"D or name "$cation"" -sel "name "$anion"D or name "$anion"" -cut 0 -rmax 1.5
#gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$anion"_disapearingcations.xvg -selrpos atom -seltype atom -ref "name "$cation"D" -sel "name "$anion"D or name "$anion"" -cut 0 -rmax 1.5
#gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$anion"_disappearingsaltions.xvg -selrpos atom -seltype atom -ref "name "$cation"D" -sel "name "$anion"D" -cut 0 -rmax 1.5
#gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$anion"_disappearinganions.xvg -selrpos atom -seltype atom -ref "name "$cation"D or name "$cation"" -sel "name "$anion"D" -cut 0 -rmax 1.5
#gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$anion"-"$cation"_disappearinganions.xvg -selrpos atom -seltype atom -ref "name "$anion"D" -sel "name "$cation"D or name "$cation"" -cut 0 -rmax 1.5
fi

cd ..
plot_rdf_xvg.py `ls "$ion"_"$Conc"M_*K_2ns_"$type"/rdf*"$ion"*_*ions"$forback".xvg`
