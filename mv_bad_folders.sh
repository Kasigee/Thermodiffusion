cation='LI'
anion='CL'
conc=0
temp=275
for_back='_backward'

for i in `ls -d "$cation""$anion"_"$conc"M_"$temp"K_2ns_salt/Lambda_*/Production_MD"$forback"/`; do other=$(echo "${i%/}"); echo $(mv $i "$other"_bad); echo $i; done
