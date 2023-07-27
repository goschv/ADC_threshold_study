#!/bin/bash

# path to data

DATA_DIR=/home/goschv/CSB_NeuroRad2/goschv/DATA/Repro

cd $DATA_DIR

for s in CSB*

do

echo $s

mkdir $s/processed/algo
rm -r $s/processed/algo/1_run_pipeline1
mkdir $s/processed/algo/1_run_pipeline1




# This script combines ADC and TRACE information first by dividing them. Then the result is normalized along the z axis before applying a threshold to create an estimated map. This map is dilated and applied to the original ADC. An absolute ADC threshold excludes false positives. 



'--------------------------------------------------------------------------------PREPROCESSING IMAGES--------------------------------------------------------------'

# create and apply brainmask (b0-bin)to ADC and TRACE
fslmaths $s/processed/quickb02mni_Warped.nii.gz -bin $s/processed/algo/1_run_pipeline1/b0_bet_bin.nii.gz
fslmaths $s/processed/quickTRACE.nii.gz -mas $s/processed/algo/1_run_pipeline1/b0_bet_bin.nii.gz $s/processed/algo/1_run_pipeline1/TRACE_bet.nii.gz
fslmaths $s/processed/quickADC.nii.gz -mas $s/processed/algo/1_run_pipeline1/b0_bet_bin.nii.gz $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz

# div TRACE by ADC
fslmaths $s/processed/algo/1_run_pipeline1/TRACE_bet.nii.gz -div $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz $s/processed/algo/1_run_pipeline1/TRACE_div_ADC.nii.gz  

# normalization in every slice seperatly
fslsplit $s/processed/algo/1_run_pipeline1/TRACE_div_ADC.nii.gz $s/processed/algo/1_run_pipeline1/TRACEdivADC -z

for i in $s/processed/algo/1_run_pipeline1/TRACEdivADC00*

do

meant=$(fslstats $i -M)
fslmaths $i -div $meant $i

done

fslmerge -z $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged.nii.gz $s/processed/algo/1_run_pipeline1/TRACEdivADC00*


# smoothing via gaussian kernel AND correct edges 
fslmaths $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged.nii.gz -kernel boxv 5 -fmean $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12.nii.gz -mas $s/processed/algo/1_run_pipeline1/b0_bet_bin.nii.gz $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12.nii.gz



'--------------------------------------------------------------------------------FSLSWAP ADJUSTMENTS--------------------------------------------------------------'

# fslswapdim method with using zerovoxel to reduce asymmetric subtraction

fslswapdim $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12.nii.gz -x y z $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_swap.nii.gz

fslmaths $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_swap.nii.gz -mas $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12.nii.gz $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_swap.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12.nii.gz -sub $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_swap.nii.gz $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_swap_sub.nii.gz

fslmaths $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_swap.nii.gz -binv $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_swap_binv.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_swap_sub.nii.gz -sub $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_swap_binv.nii.gz $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_swap_sub_binv.nii.gz 



'----------------------------------------------------------------------------------CREATE A MASK------------------------------------------------------------------'

# apply relative threshold to smoothed image
fslmaths $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_swap_sub_binv.nii.gz -thr 0.75 $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_thr2.nii.gz

# dilate mask 
fslmaths $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_thr2.nii.gz -dilD $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_thr2_dil.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_thr2_dil.nii.gz -dilD $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_thr2_dil2.nii.gz

# fill mask 
fslmaths $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_thr2_dil2.nii.gz -fillh26 $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_thr2_dil2_fill.nii.gz 
 


'----------------------------------------------------------------------------APPLY MASK AND THRESHOLDS----------------------------------------------------------------'

# apply mask and absolute threshold
fslmaths $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz -mas $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_thr2_dil2_fill.nii.gz  $s/processed/algo/1_run_pipeline1/masked_ADC_bet.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/masked_ADC_bet.nii.gz -thr 200 -uthr 620 $s/processed/algo/1_run_pipeline1/6ROI.nii.gz

fslmaths $s/processed/algo/1_run_pipeline1/TRACE_bet.nii.gz -thrp 95 $s/processed/algo/1_run_pipeline1/TRACE_bet_95.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/6ROI.nii.gz -mas $s/processed/algo/1_run_pipeline1/TRACE_bet_95.nii.gz $s/processed/algo/1_run_pipeline1/6ROI_95.nii.gz

# fill ROI
fslmaths $s/processed/algo/1_run_pipeline1/6ROI_95.nii.gz -fillh $s/processed/algo/1_run_pipeline1/6ROI_95_fill.nii.gz



'---------------------------------------------------------GENERATE DICE SCORE AND OTHER MEASURES TO EVALUATE SCRIPT-----------------------------------------------------'

# remove old txt files
rm $s/processed/algo/1_run_pipeline1/*.txt

# 3ddot create txt file with DICE score DWI d0 thresholding/manual ROIs
3ddot -dodice $s/processed/ROI_reg_quick.nii.gz $s/processed/algo/1_run_pipeline1/6ROI_95_fill.nii.gz >> $s/processed/algo/1_run_pipeline1/6ROI_95_fill.txt
3ddot -dodice $s/processed/ROI_reg_quick.nii.gz $s/processed/algo/1_run_pipeline1/6ROI.nii.gz >> $s/processed/algo/1_run_pipeline1/6ROI.txt
3ddot -dodice $s/processed/ROI_reg_quick.nii.gz $s/processed/algo/1_run_pipeline1/6ROI_95.nii.gz >> $s/processed/algo/1_run_pipeline1/6ROI_95.txt
3ddot -dodice $s/processed/ROI_reg_quick.nii.gz $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_thr2_dil2_fill.nii.gz >> $s/processed/algo/1_run_pipeline1/dil2.txt
3ddot -dodice $s/processed/ROI_reg_quick.nii.gz $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_thr2_dil.nii.gz >> $s/processed/algo/1_run_pipeline1/dil1.txt
3ddot -dodice $s/processed/ROI_reg_quick.nii.gz $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_thr2.nii.gz >> $s/processed/algo/1_run_pipeline1/trh2.txt 

# does the mask cover the infarct? DICE and percentage of voxels
fslmaths $s/processed/ROI_reg_quick.nii.gz -mas $s/processed/algo/1_run_pipeline1/TRACEdivADC_merged_kernelbox12_thr2_dil2_fill.nii.gz $s/processed/algo/1_run_pipeline1/ROI_sub_mask.nii.gz
3ddot -dodice $s/processed/ROI_reg_quick.nii.gz $s/processed/algo/1_run_pipeline1/ROI_sub_mask.nii.gz >> $s/processed/algo/1_run_pipeline1/maskedRoi.txt

fslstats $s/processed/algo/1_run_pipeline1/ROI_sub_mask.nii.gz -V > $s/processed/algo/1_run_pipeline1/ROI_sub_mask_voxels.txt
fslstats $s/processed/ROI_reg_quick.nii.gz -V > $s/processed/algo/1_run_pipeline1/ROI_voxels.txt

# extract values out of ROI
fslmaths $s/processed/algo/1_run_pipeline1/TRACE_bet.nii.gz -mas $s/processed/ROI_reg_quick.nii.gz $s/processed/algo/1_run_pipeline1/TRACE_bet_ROIextract.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz -mas $s/processed/ROI_reg_quick.nii.gz $s/processed/algo/1_run_pipeline1/ADC_bet_ROIextract.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz -mas $s/processed/algo/1_run_pipeline1/6ROI_95_fill.nii.gz $s/processed/algo/1_run_pipeline1/ADC_bet_auto_ROIextract.nii.gz

# generate output ROI as a map
fslmeants -i $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz -o $s/processed/algo/1_run_pipeline1/manual_ADC_d0.txt -m $s/processed/ROI_reg_quick.nii.gz --showall
fslmeants -i $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz -o $s/processed/algo/1_run_pipeline1/auto_ADC_d0.txt -m $s/processed/algo/1_run_pipeline1/6ROI_95_fill.nii.gz --showall

# dilate manual ROI for ROC analysis
fslmaths $s/processed/ROI_reg_quick.nii.gz -dilD $s/processed/algo/1_run_pipeline1/ROI_manual_1_dil.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/ROI_manual_1_dil.nii.gz -mas $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz $s/processed/algo/1_run_pipeline1/ROI_manual_1_dil.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/ROI_manual_1_dil.nii.gz -dilD $s/processed/algo/1_run_pipeline1/ROI_manual_2_dil.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/ROI_manual_2_dil.nii.gz -mas $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz $s/processed/algo/1_run_pipeline1/ROI_manual_2_dil.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/ROI_manual_2_dil.nii.gz -dilD $s/processed/algo/1_run_pipeline1/ROI_manual_3_dil.nii.gz
fslmaths $s/processed/algo/1_run_pipeline1/ROI_manual_3_dil.nii.gz -mas $s/processed/algo/1_run_pipeline1/ADC_bet.nii.gz $s/processed/algo/1_run_pipeline1/ROI_manual_3_dil.nii.gz

done

cd $DATA_DIR

for s in CSB*

do

echo $s

# cat DSC
cat $s/processed/algo/1_run_pipeline1/6ROI_95_fill.txt
cat $s/processed/algo/1_run_pipeline1/6ROI_95.txt
cat $s/processed/algo/1_run_pipeline1/6ROI.txt
cat $s/processed/algo/1_run_pipeline1/dil2.txt
cat $s/processed/algo/1_run_pipeline1/dil1.txt
cat $s/processed/algo/1_run_pipeline1/trh2.txt

done

cd $DATA_DIR

for s in CSB*

do

echo $s

# cat DSC
cat $s/processed/algo/1_run_pipeline1/maskedRoi.txt

done




'--------------------------------------------------------------------------------------------OUTPUT STATA----------------------------------------------------------------------'

#cd $DATA_DIR

#for s in CSB*

#do

#echo $s

#cp $s/processed/algo/1_run_pipeline1/6ROI_95_fill.txt /home/goschv/CSB_NeuroRad2/goschv/Stats/STATA/"${s:9}"_pipeline1_auto_DSC_d0.txt
#cp $s/processed/algo/1_run_pipeline1/maskedRoi.txt /home/goschv/CSB_NeuroRad2/goschv/Stats/STATA/"${s:9}"_pipeline1_mask_manual_DSC_d0.txt

#fslstats $s/processed/algo/1_run_pipeline1/6ROI_95_fill.nii.gz -V >> /home/goschv/CSB_NeuroRad2/goschv/Stats/STATA/"${s:9}"_pipeline1_auto_VOL_d0.txt
#fslstats $s/processed/algo/1_run_pipeline1/ADC_bet_ROIextract.nii.gz -V >> /home/goschv/CSB_NeuroRad2/goschv/Stats/STATA/"${s:9}"_pipeline1_manual_VOL_d0.txt

#fslstats $s/processed/algo/1_run_pipeline1/ADC_bet_auto_ROIextract.nii.gz -M >> /home/goschv/CSB_NeuroRad2/goschv/Stats/STATA/"${s:9}"_pipeline1_auto_MEAN_d0.txt
#fslstats $s/processed/algo/1_run_pipeline1/ADC_bet_ROIextract.nii.gz -M >> /home/goschv/CSB_NeuroRad2/goschv/Stats/STATA/"${s:9}"_pipeline1_manual_MEAN_d0.txt


#cp $s/processed/algo/1_run_pipeline1/auto_ADC_d0.txt /home/goschv/CSB_NeuroRad2/goschv/Stats/STATA/"${s:9}"_pipeline1_auto_ADC_d0.txt
#cp $s/processed/algo/1_run_pipeline1/manual_ADC_d0.txt /home/goschv/CSB_NeuroRad2/goschv/Stats/STATA/"${s:9}"_pipeline1_manual_ADC_d0.txt


#cp $s/processed/algo/1_run_pipeline1/maskedRoi.txt /home/goschv/CSB_NeuroRad2/goschv/Stats/STATA/"${s:9}"_pipeline1_manual_mask_DSC_d0.txt
#cp $s/processed/algo/1_run_pipeline1/ROI_sub_mask_voxels.txt /home/goschv/CSB_NeuroRad2/goschv/Stats/STATA/"${s:9}"_pipeline1_manual_mask_VOL_d0.txt



#done


# The final applied absolute threshold can vary; Used threshold derived from the study Purushotham et al. 2015 (see references)

'---------------------------------------------------------------------------------------------DATA STRUCTURE-------------------------------------------------------------------'

# $s/X/"${s:9}" 
# Save everything as a txt file, also ADC maps! Encode output as following:
#$s/X/"${s:9}" / TRHreg1 / auto / “output”
#identifier    / pipeline    / modality / “output” → Use Stats/DATA 


# references

' Written by Vitus Gosch - Universitätsmedizin Berlin, corporate member of Freie Universität Berlin and Humboldt-Universität zu Berlin, Center for Stroke Research Berlin, Berlin, Germany
https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL
32 Woolrich MW, Jbabdi S, Patenaude B, Chappell M, Makni S, Behrens T, et al. Bayesian analysis of neuroimaging data in FSL. Neuroimage. 2009;45: S173–86
10 Purushotham A, Campbell BCV, Straka M, Mlynash M, Olivot J-M, Bammer R, et al. Apparent diffusion coefficient threshold for delineation of ischemic core. Int J Stroke. 2015;10: 348–353.'


