#!/usr/bin/env python3
import sys
#import os

# Loop through the input files specified in the command line arguments
T=float(sys.argv[1])


sum = 0.0
sumA = 0.0
sumB = 0.0
# read the file
with open("GFE_temp.dat", "r") as f:  # replace "filename.txt" with your file name
    for line in f:
        values = line.split()  # split the line into a list
        sum += float(values[2])  # add the third value from the list to the sum
        sumA += float(values[4])  # add the third value from the list to the sum
        sumB += float(values[6])  # add the third value from the list to the sum


GFE=sum*2.479*(T/298)
SA=sumA*2.479*(T/298)
SB=sumB*2.479*(T/298)
print("GFE: ", GFE,"kJ/mol","Entropy? A:",SA,"B:", SB)
averageS=(SA+SB)/2
print("AVG S:",averageS)
