if [ $# -ne 4 ]
then
	#echo "$0 temperature(K) conc(M)"
	echo "$0 cation anion conc temp"
	exit 0
fi

wd=$PWD

cation=$1
anion=$2
Conc=$3
Temperature=$4

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

cd "$cation""$anion"_"$Conc"M_"$Temperature"K_2ns_saltpaired
echo $PWD
if [ ! -f rdf"$cation"-"$anion"*_*allions_cn.xvg ]
#if [ ! -f rdf"$cation"-"$cation"*_*allions_cn.xvg ]
then
#gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$cation"_allions.xvg  -cn rdf"$cation"-"$cation"_allions_cn.xvg -selrpos atom -seltype atom -ref "name "$cation"D or name "$cation"" -sel "name "$cation"D or name "$cation"" -cut 0 -rmax 1.5

#gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$anion"_allions.xvg  -cn rdf"$cation"-"$anion"_allions_cn.xvg -selrpos atom -seltype atom -ref "name "$cation"D or name "$cation"" -sel "name "$anion"D or name "$anion"" -cut 0 -rmax 1.5 -b 1000
gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$anion"_allions.xvg  -cn rdf"$cation"-"$anion"_allions_cn.xvg -selrpos atom -seltype atom -ref "name "$cation"D or name "$cation"" -sel "name "$anion"D or name "$anion"" -cut 0 -rmax 1.5

#gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$anion"_disapearingcations.xvg -cn rdf"$cation"-"$anion"_disapearingcations_cn.xvg -selrpos atom -seltype atom -ref "name "$cation"D" -sel "name "$anion"D or name "$anion"" -cut 0 -rmax 1.5
#gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$anion"_disappearingsaltions.xvg -selrpos atom -seltype atom -ref "name "$cation"D" -sel "name "$anion"D" -cut 0 -rmax 1.5
#gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$anion"_disappearinganions.xvg -selrpos atom -seltype atom -ref "name "$cation"D or name "$cation"" -sel "name "$anion"D" -cut 0 -rmax 1.5
#gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$anion"-"$cation"_disappearinganions.xvg -selrpos atom -seltype atom -ref "name "$anion"D" -sel "name "$cation"D or name "$cation"" -cut 0 -rmax 1.5
fi

#cd ..
#plot_rdf_xvg.py `ls "$cation""$anion"_"$Conc"M_*K_2ns_salt/rdf*"$cation"-"$anion"*_*allions.xvg`
#plot_rdf_xvg.py `ls "$cation""$anion"_"$Conc"M_*K_2ns_salt/rdf*"$cation"-"$cation"*_*allions.xvg`
plot_rdf_xvg.py `ls ../"$cation""$anion"_"$Conc"M_*K_2ns_saltpaired/rdf*"$cation"-"$anion"*_*allions.xvg`

#plot_rdf_xvg.py `ls rdf*"$cation"-"$anion"*_*allions.xvg`
cd ..
