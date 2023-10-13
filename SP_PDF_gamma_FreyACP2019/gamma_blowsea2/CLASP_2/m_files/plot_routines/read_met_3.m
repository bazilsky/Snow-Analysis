% read met netcdf file in matlab 
clc
clear all

directory_path = '/Users/ananth/Downloads/tower_2_level_v3/'

file_list = dir(fullfile(directory_path, '*.nc'));
[~, sorted_indices] = sort([file_list.datenum]);
file_list = file_list(sorted_indices);

u = [];
v = [];
w = [];

start_date_str = '2019-10-15 00:00:00';

start_date = datetime(start_date_str);
temp_time = start_date;
time_arr = [];

for i = 1:length(file_list)
%for i = 1:2    
    disp('value of i = ')
    disp(i)
    filename = strcat(directory_path, file_list(i).name);
    u_temp = ncread(filename, 'wspd_u_mean_10m');
    v_temp = ncread(filename, 'wspd_v_mean_10m');
    w_temp = ncread(filename, 'wspd_w_mean_10m');
    
    u = vertcat(u,u_temp);
    v = vertcat(v,v_temp);
    w = vertcat(w,w_temp);
    %time_arr = vertcat(time_arr, temp_time);
    

    %temp_time = temp_time + minutes(1);
    % datetime object with starting time and add 1 everytime the loop runs
end

for i= 1:length(u)
    time_arr = vertcat(time_arr,temp_time);
    temp_time = start_date+minutes(i);
end

save('uvw_test.mat', 'time_arr','u','v','w')


% file_path = '/Users/ananth/Downloads/mosmet.metcity.level2v3.1min.20191021.000000.nc';
% 
% ncdisp(file_path)
% 
% u = ncread(file_path, 'wspd_u_mean_10m');
% v = ncread(file_path, 'wspd_v_mean_10m');
% w = ncread(file_path, 'wspd_w_mean_10m');
% 

