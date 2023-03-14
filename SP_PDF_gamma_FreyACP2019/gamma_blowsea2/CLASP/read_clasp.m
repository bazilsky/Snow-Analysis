
clear all
clc


data = load('clasp_all_1min.mat');

x = data.CLASP;
y= x.t; % output the time array

% process if the data in arrays are correct or not, y1, y2 and y3
y1_1 = datestr(y(:,1), 'mm/dd/YYYY');
y1 = datetime(y1_1);

y1_2 = datestr(y(:,2), 'mm/dd/YYYY');
y2 = datetime(y1_2);

y1_3 = datestr(y(:,3), 'mm/dd/YYYY');
y3 = datetime(y1_3);

diff1 = y1 - y2;
diff2 = y2 - y3;
diff3 = y1 - y3;

conc_arr = x.conc;




% seems like diff1, diff2, diff3 are all equal

% save data into csv file
writematrix(conc_arr, 'clasp_conc.csv')
writematrix(y1,'clasp_time.csv')

% plot time series of concentration vs time 


% plot time series of concentration vs time .. from this axis, then
% velocity vs time from the other data set 


% plot drift density time series and mark which point had blowing snow
% events 


% new plot with coarse aerosol plot contour plot as a function of windspeed
% with bins
