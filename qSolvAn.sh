
if [ $# -ne 4 ]
then
echo "$0 ion conc type forback"
exit 0
fi

ion=$1
conc=$2
type=$3
#shellCutOff=$4
direction=$4
wd=$PWD

if [ $ion == 'LI' ] && [ $type == 'cation' ]
then
shellCutOff=2.6
elif [ $ion == 'NA' ] && [ $type == 'cation' ] || [ $ion == 'NACL' ] && [ $type == 'salt' ]
then
shellCutOff=3.1
elif [ $ion == 'KA' ] && [ $type == 'cation' ]
then
shellCutOff=3.5
#elif [ $ion == 'RB' ] && [ $type == 'cation' ]
#then
#shellCutOff=
#elif [ $ion == 'CS' ] && [ $type == 'cation' ]
#then
#shellCutOff=
elif [ $ion == 'FL' ] && [ $type == 'anion' ]
then
shellCutOff=2.5
elif [ $ion == 'CL' ] && [ $type == 'anion' ]
then
shellCutOff=3.15
elif [ $ion == 'IO' ] && [ $type == 'anion' ] || [ $ion == 'IB' ] && [ $type == 'anion' ] ||  [ $ion == 'IC' ] && [ $type == 'anion' ] ||  [ $ion == 'IF' ] && [ $type == 'anion' ] ||  [ $ion == 'IG' ] && [ $type == 'anion' ]
then
shellCutOff=3.55
elif [ $ion == 'IA' ] && [ $type == 'anion' ]
then
shellCutOff=4.05
elif [ $ion == 'IE' ] && [ $type == 'anion' ]
then
shellCutOff=2.85
fi


#for i in `ls -d *"$ion"*"$conc"M_*2n*"$type"*/`
for i in `ls -d "$ion"_"$conc"M_*_2n*"$type"/`
do
echo $i
cd $wd/$i
../qjob_SolvAnalysis $ion $type $shellCutOff $direction
#cp Solvation_analysis_template.py . 
#python Solvation_analysis_template.py > SolvAn.dat
done
