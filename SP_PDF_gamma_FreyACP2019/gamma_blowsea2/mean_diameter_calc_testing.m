%% gamma_blowsea2
% 2-parameter gamma distribution fitting to real data
% based on gamma_testbed.m
% by Phil Anderson, 27th Aug 2012; % modified 14th Feb 2014
%
%
% MF L'Estaque 26.09.2018
% MF Cambridge 17.03.2019

close all
clear all
clc
%% load blowsea data
%pth = '~/Documents/research/Antarctica/BLOWSEA/DATA/SPC/data/';      % path from HERE to data
pth = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/mosaic/newdata_with_metcity/' % new path for data files
fname = sprintf('%sU1104_8cm_1min.mat',pth);
DATA = load(fname);



%% select period of interest
% 1) example BSn at 0.2 & 29m (IS5)
t1 = datenum('01-Jul-2013 23:15'); 
t2 = datenum('14-Jul-2013 23:26'); % this statement is not read in 

% snowfall only #1 observed 3/7/13 15:00, 4/7/13 0:05 & 6:15
% t1 = datenum('3-Jul-2013 14:30'); t2 = datenum('4-Jul-2013 7:00'); % Nsum of SPC-crw & SPC-ice look similar

velocity_bins = [0,5,10,15,20,25,30]
velocity_bins = [0,5,10]
velocity_bins = [0,2,4,6,8,10,12,14]
velocity_bins = (4:0.2:10);
velocity_bins = (4:0.5:10);

% both lines are important 
velocity_bins = (3.75:0.5:10.25);
new_v_vector  = (4:0.5:10)

% both lines are important 
velocity_bins = (-0.25:0.5:10.25);
new_v_vector  = (0:0.5:10)

% new block of code to automate velocity_bins and new_v_vector 
velocity_bins = (1:0.1:9.5);
new_v_vector = []

for p = 1: length(velocity_bins)-1
    vbin_mean = (velocity_bins(p)+velocity_bins(p+1))/2;
    new_v_vector = [new_v_vector vbin_mean];
end


alpha = [];
beta  = [];
alpha_1p = [];
beta_1p = [];
legend_lable = [];
str_temp = [];
num_points = [];
meanT = [];
Nsum_array = [];
uncertainty_of_mean = [];

%calculate mean diameter 
N_a = DATA.N;
dp_a = DATA.dp_bins(:,3);
dp_mean = zeros(length(N_a),1);
sum_a = 0;
sum_b = 0;
for i=1:length(N_a)
    for j = 1:length(dp_a)
        sum_a = sum_a+N_a(i,j)*dp_a(j);
        sum_b = sum_b+N_a(i,j);
    end
    dp_mean(i) = sum_a/sum_b;
    sum_a = 0;
    sum_b = 0;
end 


