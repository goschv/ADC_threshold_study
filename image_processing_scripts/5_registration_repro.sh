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
