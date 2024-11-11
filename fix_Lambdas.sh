#!/bin/bash

wd=$PWD
folder=$1

for i in $(seq 20 -1 0); do
  source="$wd/$folder/Lambda_0/Production_MD"
  target="$wd/$folder/"

  # Construct the path by adding nested Lambda_x/Production_MD for each iteration
  for j in $(seq 1 $i); do
    source="${source}/Lambda_${j}/Production_MD"
  done

  # Extract the path to the Lambda folder
  lambda_path=$(dirname "${source}")

  # Move the nested directory to the correct location
  mv "${lambda_path}" "${target}/."

done
