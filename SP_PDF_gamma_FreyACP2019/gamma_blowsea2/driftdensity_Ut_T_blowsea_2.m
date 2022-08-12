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
%pth = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/mosaic/newdata_with_metcity/' % new path for data files
pth = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/blowsea/SPC/data/'  % this is the path to the blowsea data files
fname = sprintf('%sSPC_ice_1min.mat',pth);
DATA = load(fname);
DATA2 = load(fname);

%% select period of interest
% 1) example BSn at 0.2 & 29m (IS5)
t1 = datenum('01-Jul-2013 23:15'); 
t2 = datenum('14-Jul-2013 23:26'); % this statement is not read in 

% snowfall only #1 observed 3/7/13 15:00, 4/7/13 0:05 & 6:15
% t1 = datenum('3-Jul-2013 14:30'); t2 = datenum('4-Jul-2013 7:00'); % Nsum of SPC-crw & SPC-ice look similar

velocity_bins = [0,5,10,15,20,25,30];
velocity_bins = [0,5,10];
velocity_bins = [0,2,4,6,8,10,12,14];
velocity_bins = (4:0.2:10);
velocity_bins = (4:0.5:10);

% both lines are important 
velocity_bins = (3.75:0.5:10.25);
new_v_vector  = (4:0.5:10);

% both lines are important 
velocity_bins = (-0.25:0.5:10.25);
new_v_vector  = (0:0.5:10);

% new block of code to automate velocity_bins and new_v_vector 
velocity_bins = (4:0.1:9.5);
new_v_vector = [];


for p = 1: length(velocity_bins)-1
    
    vbin_mean = (velocity_bins(p)+velocity_bins(p+1))/2;
    new_v_vector = [new_v_vector vbin_mean];
    
end


%% estimate the 10m windspeed from the 29m windspeed. 
zo_1 = 5.6e-5; 
zo_2 = 2.3e-4;

U1 = DATA.U10m;

U2_1 = U1 * log(10/zo_1)/log(29/zo_1);

U2_2 = U1 * log(10/zo_2)/log(29/zo_2);

U2_2 = U1;


diff = U2_2 - U2_1;
a1 = datestr(DATA.t, 'mm/dd/YYYY');
a2 = datetime(a1);

%U2 = U1 * log(z2/z0) / log (z1/z0)
%%
%legend(str_temp)

%finding when the campaign happened 

a1 = datestr(DATA.t, 'mm/dd/YYYY');
store_month = []

for i = 1:length(a1)
   %store_month = [store_month str2num(a1(i,1:2))]; % this is the line for month 
   store_month = [store_month str2num(a1(i,7:end))]; % this is the line for year
end

%%%%%%%%%%%%%%%%%%%%%

avg_bin = 10;

density  = movmean(DATA.MU,avg_bin);
time_avg = movmean(DATA.t,avg_bin);
vel_avg  = movmean(U2_1,avg_bin);

x1 = datestr(time_avg);
time_avg = datetime(x1);

% n = find(DATA.t(:,1)>=t1 & DATA.t(:,1)<t2);
% m = find(density<=0.0001 & ~isnan(density) & ~isnan(U2_2));

m = find(density <= 0.0002 & ~isnan(density) & ~isnan(U2_2));
q = find(density <= 0.001 & ~isnan(density) & ~isnan(U2_2));

vbin   = 0:1:9;
vbin_2 = 0.5:1:8.5;
num_points_2 = [];

for i=1:(length(vbin)-1)

    p = find(U2_2(m) > vbin(i) & U2_2(m) < vbin(i+1));
    num_points_2 = [num_points_2 length(p)];

end

Temp_avg = movmean(DATA.T29m,avg_bin);
Temp_avg_2 = movmean(DATA.T_spc,avg_bin);
Temp_diff = Temp_avg - Temp_avg_2;

figure(1)
plot(time_avg,density,'r.')
title('Drift density time series - Weddell Sea','fontsize',20)
xlabel('Time','FontSize',18)
ylabel('Drift density (kg/m3)','FontSize',18)
grid on
set(gca,'YScale','log')

figure(2)
plot(time_avg,density,'b.')
set(gca,'YScale','log')

x = find(density == 0);
dens_zero = density(x);

zeros_index = [];
time_zero = [];
vel_zero = [];
Temp_zero = [];


for i = 1:(length(x)-1)
    if x(i) ~= (x(i+1)-1) & Temp_avg_2(i+1)>-50
    %if x(i) ~= (x(i+1)-1)
       
        zeros_index = [zeros_index x(i+1)]; % these are all the blowing snow events
        time_zero   = [time_zero time_avg(i+1)];
        vel_zero    = [vel_zero  vel_avg(i+1)];
        Temp_zero   = [Temp_zero Temp_avg_2(i+1)];
        
    end
end

count = [];
counter = 0;
t_noaa_4 = [];
sample = [];
T_noaa_skin_2 = [];
T_noaa_2m_2 = [];



T_fine = linspace(-50,10,100);

Ut0 = 6.975;

Ut = Ut0 + 0.0033.*(T_fine+27.27).^2;

delta = std(Ut);

plot(T_fine,Ut,'r-','LineWidth',2)
hold on
plot(T_fine,Ut+2*delta,'r--',T_fine,Ut-2*delta,'r--')
plot(Temp_zero,vel_zero,'b.','MarkerSize',20)
title('U10m vs T2m -- WEDELL sea','Fontsize',20)
xlabel('T2m (C)','FontSize',18)
ylabel('U10m (m/s)','FontSize',18)


T_bins = -50:0.5:10;
%T_bins = -50:0.2:-49.6
mean_Tbin = [];
mean_Tbin_2m =[];
mean_vel_zero = [];
vel25 = [];
vel75 = [];

vel25_2m =[];
vel75_2m = [];

for i=1:(length(T_bins)-1)

    a = find(Temp_zero>=T_bins(i) & Temp_zero<=T_bins(i+1))
    
    if ~isnan(nanmean(Temp_zero(a)))
        mean_Tbin = [mean_Tbin nanmean(Temp_zero(a))];
        mean_vel_zero = [mean_vel_zero nanmean(vel_zero(a))];
        %mean_Tbin_2m = [mean_Tbin_2m nanmean(T_noaa_2m_2(a))];
        vel25  = [vel25 prctile(vel_zero(a),25)];
        vel75  = [vel75 prctile(vel_zero(a),75)];
    end

end

figure(4)
plot(T_fine,Ut,'r-','LineWidth',2)
hold on
plot(T_fine,Ut+2*delta,'r--',T_fine,Ut-2*delta,'r--')
plot(mean_Tbin,mean_vel_zero,'m.','MarkerSize',20)
title('U10m vs T_{skin} -- Weddell Sea','Fontsize',20)
xlabel('T_{skin} (C)','FontSize',18)
ylabel('U10m (m/s)','FontSize',18)





