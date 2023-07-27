#!/bin/bash

# path to data 

for DATA_DIR in /home/goschv/CSB_NeuroRad2/goschv/DATA/Repro


do

# path to template
TEMPLATE=/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz 

cd $DATA_DIR 

for s in CSB*

do 

echo $s 


# register DWI (B0) 
antsRegistrationSyNQuick.sh -d 3 -f $TEMPLATE -m $s/processed/*b0_bet.nii.gz -o $s/processed/quickb02mni_

# register ADC 
antsApplyTransforms -d 3 -i $s/*4.nii.gz -r $TEMPLATE -o $s/processed/quickADC.nii.gz  -t $s/processed/quickb02mni_1Warp.nii.gz -t  $s/processed/quickb02mni_0GenericAffine.mat

# register TRACE 
antsApplyTransforms -d 3 -i $s/*5.nii.gz -r $TEMPLATE -o $s/processed/quickTRACE.nii.gz  -t $s/processed/quickb02mni_1Warp.nii.gz -t  $s/processed/quickb02mni_0GenericAffine.mat

# register ROI 
antsApplyTransforms -d 3 -i $s/ROI/*roi.img -r $TEMPLATE -o $s/processed/ROI_reg_quick.nii.gz  -t $s/processed/quickb02mni_1Warp.nii.gz -t  $s/processed/quickb02mni_0GenericAffine.mat -n NearestNeighbor



# quality check registration
fslmaths $s/processed/ROI_reg_quick.nii.gz -mas $s/processed/quickTRACE.nii.gz $s/processed/ROI_mas_quickTRACE.nii.gz

rm $s/processed/ROI_mas_quickTRACE.txt

3ddot -dodice $s/processed/ROI_mas_quickTRACE.nii.gz $s/processed/ROI_reg_quick.nii.gz >> $s/processed/ROI_mas_quickTRACE.txt

done

for s in CSB*

do 

echo $s 

cat $s/processed/ROI_mas_quickTRACE.txt



done 

done 

# references

'https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL
32 Woolrich MW, Jbabdi S, Patenaude B, Chappell M, Makni S, Behrens T, et al. Bayesian analysis of neuroimaging data in FSL. Neuroimage. 2009;45: S173–86.
22 Avants BB, Tustison NJ, Song G, Cook PA, Klein A, Gee JC. A reproducible evaluation of ANTs similarity metric performance in brain image registration. Neuroimage. 2011;54: 2033–2044.
23 Avants BB, Epstein CL, Grossman M, Gee JC. Symmetric diffeomorphic image registration with cross-correlation: evaluating automated labeling of elderly and neurodegenerative brain. Med Image Anal. 2008;12: 26–41.
24 Mazziotta J, Toga A, Evans A, Fox P, Lancaster J, Zilles K, et al. A four-dimensional probabilistic atlas of the human brain. J Am Med Inform Assoc. 2001;8: 401–430.
25 Mazziotta J, Toga A, Evans A, Fox P, Lancaster J, Zilles K, et al. A probabilistic atlas and reference system for the human brain: International Consortium for Brain Mapping (ICBM). Philos Trans R Soc Lond B Biol Sci. 2001;356: 1293–1322.
26 Mazziotta JC, Toga AW, Evans A, Fox P, Lancaster J. A probabilistic atlas of the human brain: Theory and rationale for its development. Neuroimage. 1995;2: 89–101.
'
