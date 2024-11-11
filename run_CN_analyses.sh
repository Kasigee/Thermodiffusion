#for direction in forward backward
for direction in forward
 do
#./qSolvAn.sh LI 0 cation 2.6 $direction
#./qSolvAn.sh NA 0 cation 3.1 $direction
#./qSolvAn.sh KA 0 cation 3.5 $direction

#./qSolvAn.sh FL 0 anion 2.5 $direction
./qSolvAn.sh CL 0 anion 3.15 $direction
./qSolvAn.sh IO 0 anion 3.55 $direction
done
