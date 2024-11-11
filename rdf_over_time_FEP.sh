if [ $# -ne 6 ]
then
	#echo "$0 temperature(K) conc(M)"
	echo "$0 cation anion conc temp step start"
	exit 0
fi

wd=$PWD

cation=$1
anion=$2
Temperature=$4
Conc=$3
#filename=$1
step=$5
start=$6


cd "$cation""$anion"_"$Conc"M_"$Temperature"K_10ns_salt
echo $PWD
for i in `seq $start $step $(echo "$start + $step * 9" | bc)`
do
#	i2=$(expr $i + 99999 )
#	i2=$(expr $i + 9999 )
#        i2=$(expr $i + 999 )
	i2=$(expr $i + $(echo "$step - 1" | bc) )
	echo $i $i2
	if [ ! -f rdf"$cation"-"$anion"_"$i"-"$i2".xvg ]
	then
	gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$anion"_"$i"-"$i2".xvg -selrpos atom -seltype atom -ref "name NAD or name NA" -sel "name CLD or name CL" -cut 0 -rmax 3 -b $i -e $i2
#	gmx rdf -f Lambda_0/Production_MD/md0.trr -s Lambda_0/Production_MD/md0.tpr -o rdf"$cation"-"$anion"_"$i"-"$i2".xvg -selrpos atom -seltype atom -ref "name NAD or name NA" -sel "name CLD or name CL" -cut 0 -rmax 3 -b $i -e $i2
	fi
	icheck=$(expr $i + $(echo "$step - 2" | bc) )
done
echo $icheck
numqu=$(echo "${icheck//[^[:alpha:]]/?}")

plot_xvg.py `ls rdf"$cation"-"$anion"_*-$numqu.xvg`
