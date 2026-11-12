## EDIT THE FOLLOWING:
## PROJECT_NAME name of the project associated e.g. "ab12"
## The STORAGE_LOCATION will need updating "e.g. scratch/ab12+scratch/cd34"

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

cat <<END > MSD"$cation""$anion""$conc"M"$temp"K"$cation_or_anion".job
#!/bin/bash
#PBS -P PROJECT_NAME
#PBS -l ncpus=12
#PBS -q normal
#PBS -l mem=34GB
#PBS -l walltime=3:00:00
#PBS -l wd
#PBS -N MSD.job
#PBS -l storage=STORAGE_LOCATION

export OMP_NUM_THREADS=12

module load gromacs
./analyse_diffusion.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11}

END

qsub -P PROJECT_NAME MSD"$cation""$anion""$conc"M"$temp"K"$cation_or_anion".job
rm  MSD"$cation""$anion""$conc"M"$temp"K"$cation_or_anion".job

