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
precip_path = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/mosaic/newdata_with_metcity/precip/precipitation_Wagner_May2022/' % path for the precipitation files




fname = sprintf('%sU1104_8cm_1min.mat',pth);

precip_fname = sprintf('PWDM1_leg1_3.mat',precip_path)
kazr_fname   = sprintf('KAZR_derivedS_matrosov_1h.mat',precip_path)


DATA = load(fname);

% % THIS IS THE PRECIPITATION DATA 
% PWDM1 = load(precip_fname);
% PWDM1 = sortrows([datenum(PWDM1.DateTimeUTC),PWDM1.precip_ratemmhr],1);
% t_PWDM1 = datetime(datestr(PWDM1(:,1)));
% PWDM1 = PWDM1(:,2);
% 
% KAZR = load(kazr_fname);
% 
% 
% precip_filter = find(PWDM1~=0); % time when there is precipitation
% t_precip = t_PWDM1(precip_filter);
% 
% t_org = datetime(datestr(DATA.t));
% 
% ismem_1 = ismember(t_org,t_precip); % ~ismim is the filter for taking out precipitation values
%  
% plot(t_PWDM1,PWDM1,'r.')

figure(1)
snow_depth = DATA.snow_depth;
t_noaa = datetime(datestr(DATA.t_NOAA));
plot(t_noaa,snow_depth,'b-','LineWidth',2);
ax = gca
ax.FontSize = 16
xlabel('Time','FontSize',18)
ylabel('Snow Depth (cm)','FontSize',18)
title('Snow depth time series - MOSAIC','FontSize',20)


