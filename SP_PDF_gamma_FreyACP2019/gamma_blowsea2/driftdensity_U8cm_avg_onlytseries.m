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
fname2 = sprintf('%stower_NOAA_1min.mat',pth);
DATA = load(fname);
DATA2 = load(fname2);

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


%% estimate new 8cm velocity 
zo_1 = 5.6e-5; 
zo_2 = 2.3e-4;

U1 = DATA.U10m_ex;

U2_1 = U1 * log(8e-2/zo_1)/log(10/zo_1);

U2_2 = U1 * log(8e-2/zo_2)/log(10/zo_2);

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

density = movmean(DATA.MU,avg_bin);
U2_2 = movmean(U2_2,avg_bin);
time_avg = movmean(DATA.t,avg_bin);

%n = find(DATA.t(:,1)>=t1 & DATA.t(:,1)<t2);
%m = find(density<=0.0001 & ~isnan(density) & ~isnan(U2_2));
m = find(density <= 0.0002 & ~isnan(density) & ~isnan(U2_2));
q = find(density <= 0.001 & ~isnan(density) & ~isnan(U2_2));




vbin = 0:1:9;
vbin_2 = 0.5:1:8.5;
num_points_2 = []
for i=1:(length(vbin)-1);
    p = find(U2_2(m)>vbin(i) & U2_2(m)<vbin(i+1));
    num_points_2 = [num_points_2 length(p)];

end




%movmean(DATA2.tower_NOAA.t,60),movmean(DATA2.tower_NOAA.skin_temp_surface;

Temp_avg = movmean(DATA2.tower_NOAA.skin_temp_surface,avg_bin);

tslice_2 = time_avg(q);
density_slice_2 = density(q);
U2_slice_2 = U2_2(q);
Temp_slice_2 = Temp_avg(q);





density_slice = density(m);
U2_slice = U1(m); % 10m windspeed
t_1 = time_avg(m);
t_2 = t_1(1:(length(t_1)-1),:);
diff_arr = [];
Ut_arr = [];
t_arr_1 = [];
del_drift = []; 
slope_arr = [];
test = [];



t_noaa = movmean(DATA2.tower_NOAA.t,avg_bin);
T_noaa_skin = movmean(DATA2.tower_NOAA.skin_temp_surface,avg_bin);
T_noaa_2m = movmean(DATA2.tower_NOAA.temp_2m,avg_bin);

t_filter = find(t_noaa>733750);



diff_min = 0.00002;

for i = 1:(length(density_slice)-1)
    
    density_diff= density_slice(i+1)-density_slice(i);
    time_diff = t_1(i+1)-t_1(i);
    density_slope = density_diff/time_diff;
    diff_arr = [diff_arr density_diff];
    slope_arr = [slope_arr density_slope];
    
    if atand(density_slope)>45
        test = [test density_slope];
    end

    if (density_diff > diff_min)
        Ut     = U2_slice(i);
        t_arr_1  = [t_arr_1;t_2(i,:)];
        Ut_arr = [Ut_arr Ut];
        del_drift = [del_drift density_diff];
    end

end

slope_arr_degrees = atand(slope_arr);
%slope_arr_degrees = slope_arr_degrees';
p = find(slope_arr_degrees(:)>45 & slope_arr_degrees(:)<80);



rolling_mean_width = 10;


roll_t = movmean(DATA.t,rolling_mean_width);
roll_density = movmean(density,rolling_mean_width);

roll_t_2 = datestr(roll_t);
roll_t_3 = datetime(roll_t_2);

roll_vel = movmean(U2_2,rolling_mean_width);
%roll_temp = movmean();

t_noaa = movmean(DATA2.tower_NOAA.t,rolling_mean_width);
T_noaa_skin = movmean(DATA2.tower_NOAA.skin_temp_surface,rolling_mean_width);
T_noaa_2m = movmean(DATA2.tower_NOAA.temp_2m,rolling_mean_width);

t_noaa_2 = datestr(t_noaa);
t_noaa_3 = datetime(t_noaa_2);

b1 = datestr(roll_t);
b2 = datetime(b1);

x = find(roll_density == 0);
dens_zero = roll_density(x);


figure(1)
%yyaxis left
xlabel('Time','FontSize',18)
%plot(roll_t,roll_density,'b.')
plot(b2,roll_density,'b.')
ylim([1e-7 1e-2])
set(gca,'YScale','log')
ylabel('Drift density','FontSize',18)
title(' Drift density vs time ','fontsize',20)
grid on

time_diff = 0;

figure(2)
plot(x, roll_t(x),'b.')
title('Time vs Index', 'fontsize',20)
xlabel('Index','FontSize',18)
ylabel('Time','fontsize',18)

zeros_index = [];
time_zero = [];
vel_zero = [];
for i = 1:(length(x)-1)
    if x(i) ~= (x(i+1)-1)
        zeros_index = [zeros_index x(i+1)]; % these are all the blowing snow events
        time_zero = [time_zero roll_t_3(i+1)];
        vel_zero =  [vel_zero  roll_vel(i+1)];
        
    end
end

count = [];
counter = 0;
t_noaa_4 = [];
sample = [];
T_noaa_skin_2 = [];
T_noaa_2m_2 = [];

for i = 1:length(time_zero)
    
    qw = find(t_noaa_3 == time_zero(i));
    if length(qw) == 0
        sample = [sample i];
    end
    t_noaa_4 =[t_noaa_4 t_noaa_3(qw)];
    T_noaa_skin_2 = [T_noaa_skin_2 T_noaa_skin(qw)];
    T_noaa_2m_2 = [T_noaa_2m_2 T_noaa_2m(qw)];
    count = [count qw];
    counter = counter + 1;

end


T_fine = linspace(-50,10,100);

Ut0 = 6.975;

Ut = Ut0 + 0.0033.*(T_fine+27.27).^2;

delta = std(Ut);

plot(T_fine,Ut,'r-','LineWidth',2)
hold on
plot(T_fine,Ut+2*delta,'r--',T_fine,Ut-2*delta,'r--')
plot(T_noaa_skin_2,vel_zero,'b.','MarkerSize',20)
title('U10m vs T2m','Fontsize',20)
xlabel('T2m (C)','FontSize',18)
ylabel('U10m (m/s)','FontSize',18)



