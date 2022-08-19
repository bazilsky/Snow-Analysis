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
fname2 = sprintf('%stower_NOAA_1min.mat',pth);
precip_fname = sprintf('PWDM1_leg1_3.mat',precip_path);
kazr_fname = sprintf('KAZR_derivedS_matrosov_1h.mat',precip_path);
DATA = load(fname);
DATA2 = load(fname2);

% THIS IS THE PRECIPITATION DATA 
PWDM1 = load(precip_fname);
PWDM1 = sortrows([datenum(PWDM1.DateTimeUTC),PWDM1.precip_ratemmhr],1);
t_PWDM1 = datetime(datestr(PWDM1(:,1)));
PWDM1 = PWDM1(:,2);

KAZR = load(kazr_fname);

precip_filter = find(PWDM1~=0); % time when there is precipitation
t_precip = t_PWDM1(precip_filter);
t_org = datetime(datestr(DATA.t));

ismem_1 = ismember(t_org,t_precip); % ~ismim is the filter for taking out precipitation values
 
plot(t_PWDM1,PWDM1,'r.')

kazr_time = datetime(datestr(KAZR.Time));
kazr_filter1 = find(KAZR.VarName3~=0);
t_kazr1 = kazr_time

ismem_2 = ismember(t_org,kazr_time); % check kazr data

% ismem_3 = ismem_1 + ismem_2;
ismem_3 = ismem_1; % for now I have not included the KAZR data
ismem = changem(ismem_3,1,2);

%ismem(ismem>1) == 1;

figure(1)
plot(kazr_time, KAZR.VarName3,'b.','MarkerSize',10);
hold on
plot(kazr_time, KAZR.VarName4,'r.','MarkerSize',10);
plot(kazr_time, KAZR.VarName5,'g.','MarkerSize',10);
title('KAZIR preciptation data time series','FontSize',20)
xlabel('Time','FontSize',18)
ylabel('Snowfall rate','FontSize',18)
lgd = legend({'Kazr varname3','Kazr varname4','Kazr varname5'},FontSize=12)
set(gca,'YScale','log');
grid on




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

U1 = DATA.U10m_ex(~ismem);

U2_1 = U1 * log(8e-2/zo_1)/log(10/zo_1);

U2_2 = U1 * log(8e-2/zo_2)/log(10/zo_2);

U2_2 = U1; 

DATA.t = DATA.t(~ismem);  % altering main time variable

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

DATA.MU = DATA.MU(~ismem)


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



rolling_mean_width = 10; % 10min average


roll_t = movmean(DATA.t,rolling_mean_width);
roll_density = movmean(density,rolling_mean_width);

roll_t_2 = datestr(roll_t);
roll_t_3 = datetime(roll_t_2);

roll_vel = movmean(U2_2,rolling_mean_width);
%roll_temp = movmean();

t_noaa = movmean(DATA2.tower_NOAA.t,rolling_mean_width);
T_noaa_skin = movmean(DATA2.tower_NOAA.skin_temp_surface,rolling_mean_width);
T_noaa_2m = movmean(DATA2.tower_NOAA.temp_2m,rolling_mean_width);

T_noaa_diff = T_noaa_skin - T_noaa_2m;


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

figure(7)
plot(x, roll_t(x),'b.')
title('Time vs Index', 'fontsize',20)
xlabel('Index','FontSize',18)
ylabel('Time','fontsize',18)

zeros_index = [];
time_zero = [];
time_zero_2 = [];
vel_zero = [];

for i = 1:(length(x)-1)
    if x(i) ~= (x(i+1)-1) % made a mistake with the drift density
%     calculation
%     if (density(x(i)) ~= density(x(i)+5)) && (~isnan(density(x(i)+5)))
        zeros_index = [zeros_index x(i+1)]; % these are all the blowing snow events
        time_zero_2 = [time_zero_2 roll_t];
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
new_vel_zero = [];
new_time_zero = [];
% new_time_zero = [];

for i = 1:length(time_zero)
    
    qw = find(t_noaa_3 == time_zero(i));
    if length(qw) ~= 0
        sample = [sample i];
    

    t_noaa_4 =[t_noaa_4 t_noaa_3(qw)];
    T_noaa_skin_2 = [T_noaa_skin_2 T_noaa_skin(qw)];
    T_noaa_2m_2 = [T_noaa_2m_2 T_noaa_2m(qw)];
    new_vel_zero = [new_vel_zero vel_zero(i)]; % new vel zero vector added
    new_time_zero = [new_time_zero time_zero_2(i)];
%     old
    count = [count qw];
    counter = counter + 1;
    end 

end

new_time_zero_str = datetime(datestr(new_time_zero));


T_fine = linspace(-50,10,100);

Ut0 = 6.975;

Ut = Ut0 + 0.0033.*(T_fine+27.27).^2;

delta = std(Ut);
figure(2)
plot(T_fine,Ut,'r-','LineWidth',2)
hold on
plot(T_fine,Ut+2*delta,'r--',T_fine,Ut-2*delta,'r--')

scatter(T_noaa_skin_2,new_vel_zero,100,new_time_zero,'filled')
%plot(T_noaa_skin_2,new_vel_zero,'b.','MarkerSize',20)
% plot(T_noaa_skin_2,vel_zero,'b.','MarkerSize',20)
hcb = colorbar
hcb.Title.String = "Time";
hcb.FontSize = 12
title('U10m vs T2m','Fontsize',20)
xlabel('T_skin (C)','FontSize',18)
ylabel('U10m (m/s)','FontSize',18)
% hcb.TickLabels = datestr(new_time_zero_str);


T_bins = -50:0.2:10;
%T_bins = -50:0.2:-49.6
mean_Tbin = [];
mean_Tbin_2m =[];
mean_vel_zero = [];
vel25 = [];
vel75 = [];

vel25_2m =[];
vel75_2m = [];

for i=1:(length(T_bins)-1)

    a = find(T_noaa_skin_2>=T_bins(i) & T_noaa_skin_2<=T_bins(i+1))
    
    if ~isnan(nanmean(T_noaa_skin_2(a)))
        mean_Tbin = [mean_Tbin nanmean(T_noaa_skin_2(a))];
        mean_vel_zero = [mean_vel_zero nanmean(vel_zero(a))];
        mean_Tbin_2m = [mean_Tbin_2m nanmean(T_noaa_2m_2(a))];
        vel25  = [vel25 prctile(vel_zero(a),25)];
        vel75  = [vel75 prctile(vel_zero(a),75)];
        

    end

end




figure(4)

plot(T_fine,Ut,'r-','LineWidth',2)
hold on
plot(T_fine,Ut+2*delta,'r--',T_fine,Ut-2*delta,'r--')
plot(mean_Tbin,mean_vel_zero,'b.','MarkerSize',20)
title('U10m vs T_{skin}','Fontsize',20)
xlabel('T_{skin} (C)','FontSize',18)
ylabel('U10m (m/s)','FontSize',18)


figure(5)
plot(mean_Tbin,mean_vel_zero,'b','LineWidth',2)
hold on
plot(mean_Tbin_2m,mean_vel_zero,'g','LineWidth',2)
plot(T_fine,Ut,'r-','LineWidth',2)

plot(T_fine,Ut+2*delta,'r--',T_fine,Ut-2*delta,'r--')

plot(mean_Tbin,vel25,'b','LineWidth',1)
plot(mean_Tbin,vel75,'b','LineWidth',1)
lgd = legend({'U_{10m} vs T_{skin}','U_{10m} vs T_{2m}'},'FontSize',14)

p1 = patch([mean_Tbin fliplr(mean_Tbin)], [vel25 fliplr(vel75)], 'k');

%p1 = patch([new_v_vector fliplr(new_v_vector)], [dp_25_arr fliplr(dp_75_arr)], 'k')
%p1.FaceAlpha = 0.3;

title('U10m vs T','Fontsize',20)
xlabel('T(C)','FontSize',18)
ylabel('U_{10m} (m/s)','FontSize',18)

figure(6)
new_t_noaa = datetime(datestr(t_noaa));
plot(new_t_noaa,T_noaa_diff,'r.','MarkerSize',6)
title('T_{skin} - T_{2m}','FontSize',20)
xlabel('Time','FontSize',18)
ylabel('T_{skin} - T_{2m}','fontsize',18)







