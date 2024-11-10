#!/bin/bash

#This script was written by Kasimir P Gregory on the 4/02/2023 and annotated by Lincoln Hall on the 11/02/2023.

wd=$PWD #This sets the variable wd to the current working directory for easier directory management.

if [ $# -ne 7 ] #This checks if the number of supplied variables is equal to 7, as listed below.
then
	echo "$0 boxlength temperature ion lambdaStart ensemble LambdaNum FEPAnalsis(e.g.bar/sos)" #The variable 'boxlength' defines the dimensions of the periodic boundary in Angstroms, 'temperature' defines the temperature of the system in Kelvin, 'ion' defines the ion identity, 'lambdaStart' defines when electrostatics is switched on in the lambda sweep, 'ensemble' defines whether it is NVT (constant volume) or NPT (constant pressure), 'LambdaNum' defines the number of steps in the lambda sweep, and 'FEPAnalysis(e.g.bar/sos)' defines whether to use the Bennett Acceptance Ratio or the Simple Overlap Sampling method of analysis. 
	exit 0
fi

boxlength=$1
temperature=$2
ion=$3
lambdaStart=$4
ensemble=$5
LambdaNum=$6
FEPAnalysis=$7

baseFilesT=270 #This is where template style files are pulled from, which have starting coordinates, masses of elements and further parameters used in the simulation.


declare -A ion_data #This declares an array called 'ion_data'.
ion_data=( [Li]=LIT [Na]=SOD [K]=POT [Rb]=RUB [Cs]=CES [F]=FLU [Cl]=CLA [Br]=BRO [I]=IOD [Mg]=MAG [SS]=SFS [LS]=LFS [SE]=SES [LE]=LES [Ca]=CAL )
declare -A charge_data #This declares an array called 'charge_data'.
charge_data=( [Li]=' 1' [Na]=' 1' [K]=' 1' [Rb]=' 1' [Cs]=' 1' [F]=-1 [Cl]=-1 [Br]=-1 [I]=-1 [Mg]=' 2' [SS]=' 1' [LS]=' 1'  [SE]=' 1' [LE]=' 1' [Ca]=' 2' )
declare -A mass_data #This declares an array called 'mass_data'.
mass_data=( [Li]=6.9400 [Na]=22.9898 [K]=39.0983 [Rb]=85.4678 [Cs]=132.9055 [F]=18.9984 [Cl]=35.4500 [Br]=79.9040 [I]=126.9045 [Mg]=24.3050 [SS]='22.9898' [LS]='22.9898' [SE]='22.9898' [LE]='22.9898' [Mg]=40.0780 )

othername=${ion_data[$ion]} #This defines a variable called 'othername' depending on the ion declared.
charge=${charge_data[$ion]} #This defines a variable called 'charge' depending on the ion declared.
mass=${mass_data[$ion]} #This defines a variable called 'mass' depending on the ion declared.

echo $othername $charge $mass #Prints these varaibles to the screen.

#Makes a subdirectory for NVT simulations but NPT is the default, so NPT does not have a subdirectory.
if [ $ensemble == 'NVT' ]
then
	ensembledir='/NVT'
elif [ $ensemble == 'NPT' ]
then
	ensembledir=''
fi

#Makes a subdirectory for the LambdaNum if it isn't 20, because 20 was the default.
if [ $LambdaNum == '20' ]
then
        LambdaNumDir=''
	result=$(echo "scale=3; 1 / $LambdaNum" | bc ) #This divides 1 by the LambdaNum.
        DelLamb=$(printf "%0.3f\n" $result) #This ensures formatting to be consistent for different LambdaNum values.
        echo Del_Lambda $DelLamb
else
	LambdaNumDir="/$LambdaNum"
	result=$(echo "scale=3; 1 / $LambdaNum" | bc )
	DelLamb=$(printf "%0.3f\n" $result)
	echo Del_Lambda $DelLamb
fi

#Makes different analysis file output names dependent on the analysis type.
if [ $FEPAnalysis == 'bar' ]
then
        AnalysisFile=''
elif [ $FEPAnalysis == 'sos' ]
then
		AnalysisFile='sos'
fi

#Start the actual process.
mkdir -p $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/"$lambdaStart""$ensembledir""$LambdaNumDir" #Make the directory for each combination of variables. The '-p' flag will make parent directories if required.
cd $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/"$lambdaStart""$ensembledir""$LambdaNumDir" #Possibly redundant because there's later cd commands that are explicit.

qued2=`qstat -f | tr -d '\n' | tr -d '[:blank:]' | grep ParseFEP_"$boxlength""$ion""$temperature""$lambdaStart""$AnalysisFile".job  | wc -l` #Checks the queue for a queued or running file of the anticipated name, and counts how many are there.


for direction in forwards backwards #Iterates over the forwards and backwards FEPs.
do
	if ! grep -q 'estimator: total free energy change' $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/$lambdaStart"$ensembledir""$LambdaNumDir"/forwards/fepout/ParseFEP.log && [ ! $qued2 -ge 1 ] #Checks that there isn't a finished analysis, and that this job isn't already in the queue.
	then
		mkdir -p $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/"$lambdaStart""$ensembledir""$LambdaNumDir"/$direction
		rsync -av --exclude='*/' --exclude='fepout.tar' $wd/boxlength_"$boxlength"/Na/"$baseFilesT"/0.5"$ensembledir"/$direction/ $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/$lambdaStart"$ensembledir""$LambdaNumDir"/$direction/ #This copies the template-like files into the relevant directory.
		echo "copied across"
	cd $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/$lambdaStart"$ensembledir""$LambdaNumDir"/"$direction"
	cp $wd/TIP3P-FB-water.prm . #Copy the parameter files into the current directory.
	sed -i 's/SOD/'"$othername"'/g' solvate_"$boxlength".pdb #Find and replace all SODs (sodium, which is in the template-like files) to the relevant 'othername' for the current ion.
	sed -i 's/NA/\U'"$ion"'/g' solvate_"$boxlength".pdb #Find and replace all NAs to the relevant 'ion' and ensure all letters are uppercase.
	sed -i '0,/1.00/s/ 1.00/'"$charge"'.00/' solvate_"$boxlength".pdb #Change the charge to the charge of the relevant current ion.
	sed -i 's/'"$baseFilesT"'/'"$temperature"'/g' 3_collect_fep_data.py #Change the temperature to the desired temperature for reading files.
	if [ ! -f fep_"$direction".conf ] #To ensure that backwards is named correctly.
	then
		mv fep_forwards.conf fep_"$direction".conf
		echo Naming issue
	fi
	sed -i 's/'"$baseFilesT"'/'"$temperature"'/g' fep_"$direction".conf #Changes temperature in the conf file for the actual molecular dynamics simulation.
	if [ ! $LambdaNum == '20' ] #Sets the intervals dependent on the Lambda for the conf file and relevent python analysis files.
        then
		sed -i 's/set dlambda    0.05/set dlambda    '$DelLamb'/g' fep_"$direction".conf
		sed -i 's/num_l = 20/num_l = '$LambdaNum'/g' *py
		sed -i 's/delta_l = 0.05/delta_l = '$DelLamb'/g' *py

	fi
	if [ $ion == 'Mg' ] || [ $ion == 'I' ] || [ $charge == ' 2' ] || [ $charge == '-2' ] #Increases the equilibration time for each simulation, as it didn't appear long enough for certain ions.
	then
		sed -i 's/set numsteps   5010000/set numsteps   5200000/g' fep_"$direction".conf #Changes total number of steps to account for longer equilibration, with the same number of production steps in the molecular dynamics simulation.
		sed -i 's/alchEquilSteps  10000/alchEquilSteps  200000/g'  fep_"$direction".conf #Changes number of equilibration steps to account for a longer equilibration time.
	fi
	sed -i 's/SOD/'"$othername"'/g' solvate_"$boxlength".psf #This and subsequent three commands repeats changes made earlier, but here for the psf file.
	sed -i 's/22.9898/'"$mass"'/g' solvate_"$boxlength".psf
	sed -i '0,/1.00/s/ 1.000000/'"$charge"'.000000/' solvate_"$boxlength".psf
	sed -i 's/alchElecLambdaStart 0.5/alchElecLambdaStart '"$lambdaStart"'/g' fep_"$direction".conf
	FinishedCount=$(grep 'End of program' $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/"$lambdaStart""$ensembledir""$LambdaNumDir"/"$direction"/fep_dir_*/fep.log | wc -l) #This counts how many of the different lambda sinulations have finished successfully.
	echo Number Finished is $FinishedCount
	if [ $FinishedCount -ge $LambdaNum ] #This checks all lambda steps have finished so that analysis can proceed.
	then
		python2 3_collect_fep_data.py #This uses a script written by Ben Corry to collect finished outputs.
		tar -xvf fepout.tar
		rm fepout.tar
		cd $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/$lambdaStart"$ensembledir""$LambdaNumDir"/"$direction"/fepout
                if [ ! -f 4_combine_fepout_stride_stop_forwards_use.py ] #This checks if a subsequent code written by Ben Corry exists within the folder, and if not copies it in.
                then
                        cp $wd/boxlength_30/Na/270/0.5/forwards/4_combine_fepout_stride_stop_forwards_use.py .
                fi
		stride=$(grep 'stride = ' 4_combine_fepout_stride_stop_forwards_use.py) #Finds the current stride length, which is how often the trajectory is sampled.
		stride_escaped=${stride//\//\\/} #Reformats the stride variable.
                sed -i 's/'"$stride_escaped"'/stride = 20/g' 4_combine_fepout_stride_stop_forwards_use.py
                sed -i 's/270/'$temperature'/g' 4_combine_fepout_stride_stop_forwards_use.py
		sed -i 's/num_l = 20/num_l = '$LambdaNum'/g' *py
                sed -i 's/delta_l = 0.05/delta_l = '$DelLamb'/g' *py
		sed -i 's/stop = 5050000/stop = 5250000/g' 4_combine_fepout_stride_stop_forwards_use.py
                python2 4_combine_fepout_stride_stop_forwards_use.py #This amalgamates the data into a combined file, sampling every stride length.
	elif [ $FinishedCount -ge 1 ] #This checks if simulations have started but not all lambda values have finished.
        then
    		echo "One of these runs crashed for some reason. ( $1 $2 $3 $4 $5 )"
	else
		qued=`qstat -f | tr -d '\n' | tr -d '[:blank:]' | grep $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/"$lambdaStart""$ensembledir""$LambdaNumDir"/"$direction"  | wc -l`
		if [ $qued -ge 1 ] #Queue checker, similar to previously stated.
		then
			echo queued
			if [ $direction == 'backwards' ] #If forwards, this script will continue so that it can check the backwards simulations, however if it is backwards it has already checked forwards and therefore can exit.
                        then
				exit 0
			fi
		else
			if [ -f 1_setup_fep_direcories.py ] #This is checking if files exist, to move them into the relevant directories.
			then
				mv 1_setup_fep_direcories.py 1_setup_fep_directories.py
			fi
			sed -i 's/forwards/'$direction'/g' 1_setup_fep_directories.py #Changes forwards to backwards, if necessary.
			python2 1_setup_fep_directories.py #Script written by the one and only Ben Corry sets up the directories to run each lambda value simulation.
			python2 2_submit_fep_directories.py #Submits each simulation to the queue.
			if [ $direction == 'backwards' ]
			then
				exit 0
			fi
		fi
	fi
	else
		echo Finished
	fi
done

if grep -q '-estimator: total free energy change' $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/$lambdaStart"$ensembledir""$LambdaNumDir"/forwards/fepout/ParseFEP.log #Checks if the analysis is complete.
then
	echo "Finished? (ion = $ion / rad=$boxlength / temperature = $temperature / LambdaStart = $lambdaStart / ensemble = $ensemble )"
	echo $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/$lambdaStart"$ensembledir""$LambdaNumDir"/forwards/fepout/ParseFEP.log
	tail -n1 $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/$lambdaStart"$ensembledir""$LambdaNumDir"/forwards/fepout/ParseFEP.log #Prints the final line, which has the total free energy change for this set of parameters.
else
module load vmd #Loads the VMD module to use it for the parseFEP analysis.
cd $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/$lambdaStart"$ensembledir""$LambdaNumDir"/forwards/fepout

#The following lines until the second 'END' makes a pbs script that will upload the parseFEP analysis job to the queue.
cat <<END > ParseFEP_"$boxlength""$ion""$temperature""$lambdaStart""$AnalysisFile".job
#!/bin/bash
#PBS -l walltime=24:00:00
#PBS -l mem=20GB
#PBS -l ncpus=48
#PBS -l software=vmd
#PBS -l wd
#PBS -P g15
#PBS -q normal


module load vmd

echo 'package require parsefep
parsefep  -forward '$wd'/boxlength_'$boxlength'/'$ion'/'$temperature'/'$lambdaStart''$ensembledir''$LambdaNumDir'/forwards/fepout/fep_test_'$temperature'_combined.fepout -backward '$wd'/boxlength_'$boxlength'/'$ion'/'$temperature'/'$lambdaStart''$ensembledir''$LambdaNumDir'/backwards/fepout/fep_test_'$temperature'_combined.fepout -entropy -'$FEPAnalysis'' | vmd -dispdev text >  ParseFEP_"$boxlength""$ion""$temperature""$lambdaStart""$AnalysisFile".out 
END

#Now submit pbs job to the queue, after ensuring that it isn't already queued and that the right number of simulations have completed.
FinishedCount=$(grep 'End of program' $wd/boxlength_"$boxlength"/"$ion"/"$temperature"/"$lambdaStart""$ensembledir""$LambdaNumDir"/"$direction"/fep_dir_*/fep.log | wc -l)
echo Number Finished is $FinishedCount
qued2=`qstat -f | tr -d '\n' | tr -d '[:blank:]' | grep ParseFEP_"$boxlength""$ion""$temperature""$lambdaStart""$AnalysisFile".job  | wc -l`
if [ $qued2 -ge 1 ] || [ ! $FinishedCount -ge $LambdaNum ]
then
echo ParseFEP_"$boxlength""$ion""$temperature""$lambdaStart""$AnalysisFile" already queued. OR not enough finished.
else
qsub ParseFEP_"$boxlength""$ion""$temperature""$lambdaStart""$AnalysisFile".job
rm -f ParseFEP_"$boxlength""$ion""$temperature""$lambdaStart""$AnalysisFile".job
echo queued ParseFEP.job
fi

fi
exit 0
