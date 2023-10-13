% read met data from new met file 

clc
clear all 


pth_met = '/Users/ananth/Downloads/'

met_file = sprintf('%stower_NOAA_1min.mat',pth_met);

met_info = sprintf('%stower_NOAA_info.mat',pth_met);

met_data = load(met_file)

met_info = load(met_info)


