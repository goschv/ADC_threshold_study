#!/bin/bash

# path to data 

for DATA_DIR in /home/goschv/CSB_NeuroRad2/goschv/DATA/Repro

do 

cd $DATA_DIR 

for s in CSB*

do 

echo $s 

mkdir $s/processed

# DCM to nii0

dcm2niix_afni $s 

# fslsplit

fslsplit $s/*_3.nii $s/

# rename fslsplit b0 image

mv $s/0000.nii.gz $s/b0.nii.gz

# gzip

gzip  $s/*.nii

# brain extract b0 

bet $s/*b0.nii.gz  $s/processed/"${s:9:11}"_b0_bet.nii.gz -f 0.2 -R



done

done
