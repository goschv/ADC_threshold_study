# ADC threshold project

Code and data for "A comparison between automated, threshold-based acute ischemic stroke lesion delineation and expert manual delineation" study

Authors: Vitus Gosch, Doctoral Candidate – Center for Stroke Research Berlin, Charité Universitätsmedizin Berlin


## Background
This repository contains bash, matlab and R scripts for image preprocessing, automated lesion delineation and statistical analysis. It provides data used for the study. 


## Structure

### **`data`** 
All raw data collected from your experiments as well as copies of the transformed data from your processing code. 

### **`image processing`** 
Matlab and shell scripts written for image preprocessing, automated lesion delineation and data extraction. They all work on image level and require DICOM or NIFTI file input. Output are text files. Running the bash scripts requires the FMRIB Software Library, Release 6.0 (c) 2018, The University of Oxford (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Licence). Additional software if needed is mentioned in the reference section of each script.

### **`statistical analysis`** 
R-scripts used for the study. RStudio Version 2022.07.1 © was used. Packages are mentioned in each script.


## License 
Own work MIT licensed. Third party ressources are cited and referred to within the files.
