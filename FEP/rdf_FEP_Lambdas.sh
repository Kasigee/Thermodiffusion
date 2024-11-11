if [ $# -ne 5 ]
then
	#echo "$0 temperature(K) conc(M)"
	echo "$0 cation anion conc temp totaltime"
	exit 0
fi

module load gromacs

wd=$PWD

cation=$1
anion=$2
Conc=$3
Temperature=$4
totaltime=$5

cd "$cation""$anion"_"$Conc"M_"$Temperature"K_"$totaltime"ns_salt
echo $PWD
for i in `seq 0 20`
do
if [ ! -f "$i"rdf"$cation"*_*saltions.xvg ] && [ ! -f "$i"rdf"$cation"*_*saltions_cn.xvg ]
then
gmx rdf -f Lambda_"$i"/Production_MD/md"$i".trr -s Lambda_"$i"/Production_MD/md"$i".tpr -o "$i"rdf"$cation"-"$anion"_allions.xvg -cn "$i"rdf"$cation"-"$anion"_allions_cn.xvg -selrpos atom -seltype atom -ref "name NAD or name NA" -sel "name CLD or name CL" -cut 0 -rmax 3
gmx rdf -f Lambda_"$i"/Production_MD/md"$i".trr -s Lambda_"$i"/Production_MD/md"$i".tpr -o "$i"rdf"$cation"-"$anion"_disapearingcations.xvg -cn "$i"rdf"$cation"-"$anion"_disapearingcations_cn.xvg -selrpos atom -seltype atom -ref "name NAD" -sel "name CLD or name CL" -cut 0 -rmax 3
gmx rdf -f Lambda_"$i"/Production_MD/md"$i".trr -s Lambda_"$i"/Production_MD/md"$i".tpr -o "$i"rdf"$cation"-"$anion"_disappearingsaltions.xvg -cn "$i"rdf"$cation"-"$anion"_disappearingsaltions_cn.xvg -selrpos atom -seltype atom -ref "name NAD" -sel "name CLD" -cut 0 -rmax 3
gmx rdf -f Lambda_"$i"/Production_MD/md"$i".trr -s Lambda_"$i"/Production_MD/md"$i".tpr -o "$i"rdf"$cation"-"$anion"_disappearinganions.xvg -cn "$i"rdf"$cation"-"$anion"_disappearinganions_cn.xvg -selrpos atom -seltype atom -ref "name NAD or name NA" -sel "name CLD" -cut 0 -rmax 3
gmx rdf -f Lambda_"$i"/Production_MD/md"$i".trr -s Lambda_"$i"/Production_MD/md"$i".tpr -o "$i"rdf"$anion"-"$cation"_disappearinganions.xvg -cn "$i"rdf"$anion"-"$cation"_disappearinganions_cn.xvg -selrpos atom -seltype atom -ref "name CLD" -sel "name NAD or name NA" -cut 0 -rmax 3
fi
done

plot_rdf_xvg.py `ls *rdf*"$cation"*_*saltions.xvg`
