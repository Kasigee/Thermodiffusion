
if [ $# -ne 4 ]
then
echo "$0 cation anion type shellCutOff"
exit 0
fi

cation=$1
anion=$2
type=$3
shellCutOff=$4 #NACL=3.75nm, NAFL=3.0nm, NAI=4.4nm, LICL=2.8nm, KCL
wd=$PWD

for i in `ls -d "$cation""$anion"_?M*2ns*"$type"/`
do
echo $i
cd $wd/$i
../qjob_IonPair $cation $anion $type $shellCutOff
#cp Solvation_analysis_template.py . 
#python Solvation_analysis_template.py > SolvAn.dat
done
