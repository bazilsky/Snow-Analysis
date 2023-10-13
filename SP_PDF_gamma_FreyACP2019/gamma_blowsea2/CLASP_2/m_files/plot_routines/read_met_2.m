% read met netcdf file in matlab 
clc
clear all

directory_path = '/Users/ananth/Downloads/tower_2_level_v3/'

file_list = dir(fullfile(directory_path, '*.nc'));
[~, sorted_indices] = sort([file_list.datenum]);
file_list = file_list(sorted_indices);


file_path = '/Users/ananth/Downloads/mosmet.metcity.level2v3.1min.20191021.000000.nc';

ncdisp(file_path)

u = ncread(file_path, 'wspd_u_mean_10m');
v = ncread(file_path, 'wspd_v_mean_10m');
w = ncread(file_path, 'wspd_w_mean_10m');


