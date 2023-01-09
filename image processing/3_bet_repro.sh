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


# references

'https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL
32 Woolrich MW, Jbabdi S, Patenaude B, Chappell M, Makni S, Behrens T, et al. Bayesian analysis of neuroimaging data in FSL. Neuroimage. 2009;45: S173–86.
21	Smith SM. Fast robust automated brain extraction. Hum Brain Mapp. 2002;17: 143–155.
27 Zhang Y, Brady M, Smith S. Segmentation of brain MR images through a hidden Markov random field model and the expectation-maximization algorithm. IEEE Trans Med Imaging. 2001;20: 45–57.'
