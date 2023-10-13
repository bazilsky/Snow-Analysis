% script to plot hygroscopicity from the MOSAIC campaign 
clc
clear all


kappa_path = '/Users/ananth/Desktop/jupyter_local/jupyter_local/netcdf/kappa_1.txt'
kappa_time_path = '/Users/ananth/Desktop/jupyter_local/jupyter_local/netcdf/kappa_time_1.txt'


kappa_data = importdata(kappa_path);

%plot(time,kappa_data)



% Open the file for reading
fileID = fopen(kappa_time_path, 'r');

% Read the strings from the file into a cell array
data = textscan(fileID, '%s', 'Delimiter', '\n');

% Close the file
fclose(fileID);

% Access the cell array of strings
strings = data{1};

% Display the cell array of strings
disp(strings);

datetime_obj = datetime(strings, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
disp(datetime_obj);

% remove all data where kappa = 0

new_kappa = kappa_data(kappa_data>=0);
new_time  = datetime_obj(kappa_data>=0); 

plot(new_time, new_kappa,'b.')
title('Hygroscopicity time series during MOSAIC')
xlabel('Time','FontSize', 18)
ylabel('Kappa', 'FontSize', 18)
set(gca, 'FontSize', 16)






