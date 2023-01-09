% This script loops through the patient folders in the 1000plus dataset and
% converts manually delineated .roi files into ANALYZE

% Written on 05.09.2020 by Ahmed Khalil, MD PhD
% Requirements:
        % * .roi file
        % * original file on which the ROI was delineated - this MUST be in ANALYZE
        % format 
        
        % add necessary paths
        addpath('/home/goschv/CSB_NeuroRad2/goschv/DATA') 
        addpath('/home/goschv/CSB_NeuroRad2/khalila/PROJECTS/DWI_lesion_segmentation_UCL/SCRIPTS/spm')
        
% set working directory
data_dir = '/home/goschv/CSB_NeuroRad2/goschv/DATA/Repro';
cd (data_dir)
       
% get names of all folders
all_dir = dir;


for k = 2:2 % loop through all folders
    %% 
    curr_dir = all_dir(k).name; % get the current subdirectory name
      fList = dir(curr_dir); % get the file list in the subdirectory
      cd(fullfile(data_dir, curr_dir, '/ROI'))
      roi = dir('*.roi'); % find the .roi file
      dwi = dir('*.img');% find the TRACE/ADC file
      
      roi2analyze(fullfile(data_dir,curr_dir,'/ROI',roi.name),fullfile(data_dir,curr_dir,'/ROI',dwi.name),1) % convert ROI file to ANALYZE
end

% references

% roi2analyze function 2-2007 by H.Schuetze, Dept. Neurology II, Magdeburg
% additional info at: http://www.sph.sc.edu/comd/rorden/roiformat/
