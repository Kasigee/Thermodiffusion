#for conc in 0 0.5 0.1 0.3 0.75 1 2 6; do for temp in  270 275 280 285 290 300; do for time in 2; do for direction in forward backward; do for rep in `seq 1 10`; do ./run_GROMACS_FEP.sh Na Cl $conc $temp $time salt $direction $rep no; done; done; done; done; done
for conc in 0 0.5 0.3 1 6 0.75 2
do
 for temp in 270 275 280 285 300 290
do
 for time in 13
 do
 for direction in forward backward
do 
for rep in `seq 1 3`
do
 ./run_GROMACS_FEP.sh Na Cl $conc $temp $time salt $direction $rep no; done; done; done; done; done
