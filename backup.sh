for i in `seq 0 100`
do
	rsync -arvz --progress --timeout=36000 --remove-source-files -e "ssh -i /home/kas/.ssh/id_rsa"  kpg575@gadi.nci.org.au:/scratch/g15/kpg575/GROMACS/FEP/H2* .
#rsync -arvz --progress --timeout=36000 -e "ssh -i /home/kas/.ssh/id_rsa"  kpg575@gadi.nci.org.au:/scratch/g15/kpg575/GROMACS/FEP/*rep* .
#rsync -arvz --progress --timeout=36000 -e "ssh -i /home/kas/.ssh/id_rsa"  kpg575@gadi.nci.org.au:/scratch/g15/kpg575/GROMACS/FEP/MG* .
#	rsync -arvz --progress --timeout=36000 --remove-source-files -e "ssh -i /home/kas/.ssh/id_rsa"  kpg575@gadi.nci.org.au:/scratch/g15/kpg575/GROMACS/FEP/AL* .
done
