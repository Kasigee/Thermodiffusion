wd=$PWD
module load gromacs
for i in `seq 1 20`
do
for subset in NPT NVT Production
do
if [ $subset == 'NPT' ]
then
prefix="npt"
elif [ $subset == 'NVT' ]
then
prefix="nvt"
elif [ $subset == 'Production_MD' ]
then
prefix=md
fi
for folder in `ls -d "$wd"/*/Lambda_"$i"/"$subset"*/`
do
cd $folder
echo $folder
#cd $wd/$folder 
if grep 'nstxout                  = 500' mdout.mdp
then
#ls -d */Lambda_"$i"/Production*/
 if [ ! -f "$prefix""$i"_reduced.trr ];
 then
 echo "0" | gmx trjconv -f "$prefix""$i".trr -s "$prefix""$i".tpr -dt 20 -o "$prefix""$i"_reduced.trr
  if [ $(wc -l < "$prefix""$i"_reduced.trr) -eq 0 ];
  then
  echo "$folder"/"$prefix""$i"_reduced.trr is empty
  elif [ ! -f "$prefix""$i"_reduced.trr ]
  then
  echo "$folder"/"$prefix""$i"_reduced.trr still does not exist
  else
  echo "rm "$prefix""$i".trr"
  rm "$prefix""$i".trr
  fi 
 else
  if [ $(wc -l < "$prefix""$i"_reduced.trr) -eq 0 ];
  then
  echo "$folder"/"$prefix""$i"_reduced.trr is empty
  else
  echo "rm "$prefix""$i".trr"
  rm "$prefix""$i".trr
  fi
 fi
fi
done
done
done
