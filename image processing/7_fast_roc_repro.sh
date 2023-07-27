#!/bin/bash

# path to data

DATA_DIR=/home/goschv/CSB_NeuroRad2/goschv/DATA/Repro

cd $DATA_DIR

for s in CSB*

do

echo $s

mkdir $s/processed/fast4
mkdir $s/processed/ROC_fast4
mkdir $s/processed/ROC_fast4_dil


################################## USES REGISTERED BET IMAGES TO APPLY FMRIB's Automated Segmentation Tool #############################


# FAST 4 call
#fast -n 4 -t 2 -o $s/processed/fast4/"${s:9}"_fast4 $s/processed/quickb02mni_Warped.nii.gz


# ouput is *0.nii.gz, generate masks
fslmaths $s/processed/fast4/*0.nii.gz -thr 0.9 $s/processed/fast4/"${s:9}"_thresh.nii.gz
fslmaths $s/processed/fast4/*0.nii.gz -binv $s/processed/fast4/"${s:9}"_0binv.nii.gz
fslmaths $s/processed/fast4/*thresh.nii.gz -binv $s/processed/fast4/"${s:9}"_threshbinv.nii.gz


# get the fasted images 
fslmaths $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz -mas $s/processed/fast4/"${s:9}"_0binv.nii.gz $s/processed/fast4/"${s:9}"_ADC_fast_0.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz -mas $s/processed/fast4/"${s:9}"_threshbinv.nii.gz $s/processed/fast4/"${s:9}"_ADC_fast_thresh.nii.gz
fslmaths $s/processed/algo/roid0.nii.gz -mas $s/X/fast1/*pve_0.nii.gz $s/X/fast1/"${s:9}"_ROI_fast.nii.gz

# % of ROI lost in patient + MEAN ADC DWI lesion day 0
fslmaths $s/processed/algo/1_run_pipeline1/ADC_bet_ROIextract.nii.gz -mas $s/processed/fast4/*ADC_fast_thresh.nii.gz $s/processed/fast4/"${s:9}"_ROI_fast4.nii.gz4

fslstats $s/processed/fast4/*ROI_fast4.nii.gz -V >> $s/processed/fast4/"${s:9}"_VOL_ROI_fast4.txt
fslstats $s/processed/fast4/*ROI_fast4.nii.gz -M >> $s/processed/fast4/"${s:9}"_MEAN_ROI_fast4.txt

# % of CSF in patient 
fslstats $s/processed/fast4/*ADC_fast_thresh.nii.gz -V >> $s/processed/fast4/"${s:9}"_VOL_fast4.txt
fslstats $s/processed/fast4/ID_thresh.nii.gz -V >> $s/processed/fast4/"${s:9}"_VOL_fast4_CSF.txt
fslstats $s/processed/quickb02mni_Warped.nii.gz  -V >> $s/processed/fast4/"${s:9}"_VOL_bet.txt

# MEAN ADC brain tissue
fslstats $s/processed/fast4/*ADC_fast_thresh.nii.gz -M >> $s/processed/fast4/"${s:9}"_MEAN_fast4.txt
fslstats $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz -M >> $s/processed/fast4/"${s:9}"_MEAN_bet.txt



'--------------------------------------------------------------------------ROC analysis registered + FAST image-------------------------------------------------------------------'

# 1st binarize to generate binary ROI

fslmaths $s/processed/fast4/*ADC_fast_thresh.nii.gz -binv $s/processed/ROC_fast4/brain_mask_binv.nii.gz
fslmaths $s/processed/ROC_fast4/brain_mask_binv.nii.gz -mul -1 $s/processed/ROC_fast4/brain_mask_binv_minusone.nii.gz
fslmaths $s/processed/ROC_fast4/brain_mask_binv_minusone.nii.gz -add $s/processed/fast4/*ROI_fast4.nii.gz $s/processed/ROC_fast4/ROI_reg_quick_ROC.nii.gz
fslmaths $s/processed/fast4/*ADC_fast_thresh.nii.gz -roc -1 $s/processed/ROC_fast4/"${s:9}"_ROC_fast4_out.txt $s/processed/ROC_fast4/ROI_reg_quick_ROC.nii.gz



'--------------------------------------------------------------------------ROC analysis dilated fast ROI + FAST image-------------------------------------------------------------------'


fslmaths $s/processed/fast4/*ADC_fast_thresh.nii.gz -mas $s/processed/algo/1_run_pipeline1/ROI_manual_3_dil.nii.gz $s/processed/ROC_fast4_dil/ROI_manual_3_dil.nii.gz

fslmaths $s/processed/ROC_fast4_dil/ROI_manual_3_dil.nii.gz -binv $s/processed/ROC_fast4_dil/ROI_manual_3_binv_dil.nii.gz
fslmaths $s/processed/ROC_fast4_dil/ROI_manual_3_binv_dil.nii.gz -mul -1 $s/processed/ROC_fast4_dil/ROI_manual_3_binv_minusone_dil.nii.gz
fslmaths $s/processed/ROC_fast4_dil/ROI_manual_3_binv_minusone_dil.nii.gz -add $s/processed/fast4/*ROI_fast4.nii.gz $s/processed/ROC_fast4_dil/ROI_reg_quick_ROC_4.nii.gz
fslmaths $s/processed/ROC_fast4_dil/ROI_manual_3_dil.nii.gz -roc -1 $s/processed/ROC_fast4_dil/"${s:9}"_ROC_fast_dil_out.txt $s/processed/ROC_fast4_dil/ROI_reg_quick_ROC_4.nii.gz

'---------------------------------------------------------------------------Output ROC-------------------------------------------------------------------'

# ROC analysis samples at different stepped intervals. Output has to be inverted to find an upper threshold, default output defines a lower threshold. 

#cp $s/processed/ROC_fast4/*txt /home/goschv/CSB_NeuroRad2/goschv/Stats/ROC_fast4/
#cp $s/processed/ROC_fast4_dil/"${s:9}"_ROC_fast_dil_out.txt /home/goschv/CSB_NeuroRad2/goschv/Stats/ROC_fast_4_dil/




done


# references

'https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL
32 Woolrich MW, Jbabdi S, Patenaude B, Chappell M, Makni S, Behrens T, et al. Bayesian analysis of neuroimaging data in FSL. Neuroimage. 2009;45: S173–86
21 Smith SM. Fast robust automated brain extraction. Hum Brain Mapp. 2002;17: 143–155.'
