#!/bin/bash

# path to data 

for DATA_DIR in /home/goschv/CSB_NeuroRad2/goschv/DATA/Repro


#/home/goschv/CSB_NeuroRad2/goschv/DATA/11_wakeupstroke.unknown /home/goschv/CSB_NeuroRad2/goschv/DATA/08_deltatinaccurate.unknown /home/goschv/CSB_NeuroRad2/goschv/DATA/11_deltatover9.exact 24_deltatover9.exact


do

cd $DATA_DIR 

for s in CSB*

do 

echo $s 

# fslsplit

fslsplit $s/*_3.nii $s/

# rename fslsplit b0 image first image series resembles b0

mv $s/0000.nii.gz $s/b0.nii.gz

# gzip

gzip  $s/*.nii


done

done


# references

'https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL
 32 Woolrich MW, Jbabdi S, Patenaude B, Chappell M, Makni S, Behrens T, et al. Bayesian analysis of neuroimaging data in FSL. Neuroimage. 2009;45: S173–86.'
