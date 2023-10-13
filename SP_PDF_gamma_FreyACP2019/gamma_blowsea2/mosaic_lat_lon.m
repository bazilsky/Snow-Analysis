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
t1 = datenum('01-feb-2020 00:00'); 
t2 = datenum('01-mar-2020 00:00'); % this statement is not read in 

n = find(DATA.t_NOAA(:,1)>=t1 & DATA.t_NOAA(:,1)<t2);

matlab_time = DATA.t_NOAA(n,1)

time = datetime(datestr(DATA.t_NOAA(n,1)));
mosaic_lat = DATA.lat(n);
mosaic_lon = DATA.lon(n);

mosaic_latlon = [matlab_time mosaic_lat mosaic_lon];
mosaic_feb_time = [time];

%writematrix(mosaic_latlon,'mosaic_latlon_feb.csv');
%writematrix(time,'mosaic_time_feb.csv');
