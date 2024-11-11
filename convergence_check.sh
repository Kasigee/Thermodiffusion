wd=$PWD

#for ion in FL CL IO
#for ion in IO
#do
for cation in NA
do
for anion in CL IO
do
for temp in 200 240 270 275 280 285 290 295 300 320 340 355 370
 do
  #cd $wd/"$ion"_0M_"$temp"K_2ns_anion
  cd $wd/"$cation""$anion"_0M_"$temp"K_2ns_salt
   for i in 10 100 1000 2000 5000 10000 20000 50000 75000 100000
   do
   if [ -e bar_analysis_"$i".dat ] && [ -s bar_analysis_"$i".dat ]
   then
    i_in_ns=$(echo "$i /1000" | bc -l)
    FE=$(tail -n48 bar_analysis_"$i".dat | grep total | awk '{print $6}')
    FEerr=$(tail -n48 bar_analysis_"$i".dat | grep total | awk '{print $8}')
#    echo $ion $i_in_ns $i $temp $FE -$FE $FEerr
    echo $cation $anion salt $i_in_ns $i $temp $FE -$FE $FEerr
   else
    module load gromacs
    gmx bar -f $(ls Lambda_[0-9]/Production_MD/md*.xvg Lambda_[0-9][0-9]/Production_MD/md*.xvg) -o -oi -e $i > bar_analysis_"$i".dat;
   fi
  done
 done
#done
done
done
