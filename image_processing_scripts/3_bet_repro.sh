#!/bin/bash

# path to data

DATA_DIR=/home/goschv/CSB_NeuroRad2/goschv/DATA/Repro


cd $DATA_DIR

for s in CSB*

do

echo $s


# brain extract b0 

bet $s/*b0.nii.gz  $s/processed/"${s:9:11}"_b0_bet.nii.gz -f 0.2 -R


# fast extract images
fast -n 2 -I 1 -l 20 -t 2 -o $s/processed/"${s:9:11}"_fast $s/processed/*b0_bet.nii.gz   

done 
