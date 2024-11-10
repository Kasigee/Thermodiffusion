echo radius ion temperature ES_Start N_LAMBDA Pressure Ensemble FE FE_err
echo radius ion temperature ES_Start N_LAMBDA Pressure Ensemble FE FE_err > FEP_data.log
for file in /scratch/g15/kpg575/NAMD/radius_*/*/*/*/*/forwards/fepout/ParseFEP.log
do
        radius=$( echo $file | awk -F/ '{print $6}' | awk -F'radius_' '{print $NF}')
        ion=$( echo $file | awk -F/ '{print $7}')
        temperature=$( echo $file | awk -F/ '{print $8}')
        ES_Start=$( echo $file | awk -F/ '{print $9}')
        N_LAMBDA=$( echo $file | awk -F/ '{print $(10)}')
        Pressure=$( echo $file | awk -F/ '{print $(11)}' | awk -F'P' '{print $1}')
        Ensemble=$( echo $file | awk -F/ '{print $(12)}' )
#       FE=$(tail -n1 $file | grep 'total free energy change is' | awk '{ gsub(/[^0-9]+/, " "); $1=$1; print $1}')
#       FE_err=$(tail -n1 $file | grep 'total free energy change is' | awk '{ gsub(/[^0-9]+/, " "); $1=$1; print $2}')
        Extracted_Numbers=$(tail -n1 $file | grep 'total free energy change is' | grep -o -E '[0-9]*\.?[0-9]+' )
        FE=$(echo "$Extracted_Numbers" | head -n1)
        FE_err=$(echo "$Extracted_Numbers" | tail -n1)
        echo $radius $ion $temperature "$ES_Start" "$N_LAMBDA" "$Pressure" "$Ensemble" "$FE" "$FE_err"
        echo $radius $ion $temperature "$ES_Start" "$N_LAMBDA" "$Pressure" "$Ensemble" "$FE" "$FE_err" >> FEP_data.log
done
