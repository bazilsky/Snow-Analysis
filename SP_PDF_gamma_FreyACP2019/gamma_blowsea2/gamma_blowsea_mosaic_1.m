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
pth = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/mosaic/data/' % new path for data files
fname = sprintf('%sSPC_Unit1104_8cm_1min.mat',pth);
% fname = sprintf('%sSPC_ice_1min.mat',pth);
DATA = load(fname);



%% select period of interest
% 1) example BSn at 0.2 & 29m (IS5)
t1 = datenum('01-Jul-2013 23:15'); t2 = datenum('14-Jul-2013 23:26'); % this statement is not read in 

% snowfall only #1 observed 3/7/13 15:00, 4/7/13 0:05 & 6:15
% t1 = datenum('3-Jul-2013 14:30'); t2 = datenum('4-Jul-2013 7:00'); % Nsum of SPC-crw & SPC-ice look similar

velocity_bins = [0,5,10,15,20,25,30]
velocity_bins = [0,5,10]
velocity_bins = [0,2,4,6,8,10,12,14]
velocity_bins = (4:0.2:10)
velocity_bins = (4:0.5:10)
alpha = []
beta  = []
alpha_1p = []
beta_1p = []
legend_lable = []
str_temp = []
num_points = []
meanT = []
Nsum_array = []
uncertainty_of_mean = []

for i = 1:(length(velocity_bins)-1)

    %n = find(DATA.t(:,1)>=t1 & DATA.t(:,1)<t2);
    n = find(DATA.U5cm(:,1)>=velocity_bins(i) & DATA.U5cm(:,1)<velocity_bins(i+1));
    num_points = [num_points length(n)];

    nonnan_count = nnz(~isnan(DATA.N(n)));
    uncertainty_of_mean = [uncertainty_of_mean nanstd(DATA.N(n))/sqrt(nonnan_count)]
    % 2) example diamond dust/ snow crystals
    % diamond dust #1 observed at 29/07/13 21:38
    % t1 = datenum('29-Jul-2013 20:00'); t2 = datenum('29-Jul-2013 23:00');
    % diamond dust #2 observed at 30/07/13 9:15
    % t1 = datenum('30-Jul-2013 7:30'); t2 = datenum('30-Jul-2013 10:30');
    %% x-data: 64 SPC particle size bins
    x = DATA.dp_bins(:,3)'; % dp in micron
    binWidth = DATA.dp_bins(:,4)'; % binwidth in micron
    % remove bottom & top bin of spc number densities because spurious particle detection
    x(1) = []; x(end) = [];
    binWidth(1) = []; binWidth(end) = [];

%% y-data (pdf) & other
% average if more than one line
    N = nanmean(DATA.N(n,:),1);
    T = nanmean(DATA.T(n,:),1);
    %dp_mean = nanmean(DATA.dp_mean(n,:),1);
    %ust = nanmean(DATA.ust(n));
    %U10m = nanmean(DATA.U10m(n));
    % remove bot & top bin of spc number densities because spurious particle detection
    N(:,1) = []; N(:,end) = [];
    %T(:,1) = []; T(:,end) = [];
    % compute PDF
    N_sum = nansum(N,2);
    pdf = N./(binWidth.*N_sum); 
    % pdf = N./N_sum; % area=1 but wrong paramters if x_org used

    %% set up data to fit
    % replace NaN or zero with a small number to ensure stable fit
    m = find(isnan(pdf) | pdf==0);
    pdf(m) = 1e-12;
    
    %% Fit the best 2P gamma distribution to the noisy data
    h = @f_2p_gamma_diff;       % name of function for search  
    data.x = x;                 % structure for the data
    data.y = pdf;
    p_init = [2.1 70];         % 1st guess for search [shape scale];

    %% send the information to f_generic_fit
    % this returns the least square fitted P (p_ret) and the 1-sigma uncertainty in P (ep_ret)
    [p_ret, ep_ret] = f_generic_fit(data,p_init,h,1);
    
    %% Plot best fit to scaled data
    x_fine = (0:0.01:max(x))';       % nice smooth line
    pdf_ret = f_build_2p_gamma(x_fine,p_ret);   % calc the curve
    
    Nsum_slice = nansum(DATA.N_sum(n))/1e6;
    Nsum_array = [Nsum_array Nsum_slice]

    figure(1)   % show it as a bar plot
    

    %str = sprintf('\\alpha %5.2f \\pm %0.2f, \\beta %5.2f \\pm %0.2f, \\alpha\\beta %3.0f \\mum, d_{p} %3.0f \\mum, U = %d-%2d',...
    %   p_ret(1), ep_ret(1),p_ret(2), ep_ret(2), p_ret(1).*p_ret(2),alpha, velocity_bins(i),velocity_bins(i+1));

    str = sprintf('\\alpha %5.2f \\pm %0.2f, \\beta %5.2f \\pm %0.2f, U = %2d-%2d m/s',...
       p_ret(1), ep_ret(1),p_ret(2), ep_ret(2), velocity_bins(i),velocity_bins(i+1));


    %str2 = sprintf('U = %d','%d', velocity_bins(i), velocity_bins(i+1), ' ')

    %str = strcat(str2, str)
    
    %
    %str_temp = [str_temp ;str]
    alpha = [alpha p_ret(1)];
    beta  = [beta  p_ret(2)];
    meanT = [meanT T]
    title('Size distribution for each wind velocity bin','fontsize',20);
    hold on 
    %bar(x,pdf)
    plot(x_fine,pdf_ret,'linewidth',2);
    xlabel('d_p (\mum)','fontsize',20);
    ylabel('PDF','fontsize',20);
    %legend (str)

    %{
    %alpha and beta estimation using xins method
    totsd = nansum(nansum(DATA.N(n,:).*(DATA.SP_data(n,:) - nanmean(DATA.SP_data(n,:))).^2));
    beta_1p_temp = totsd/nansum(nansum(DATA.N(n,:)))/nansum(nanmean(DATA.SP_data(n,:)));
    alpha_1p_temp = nanmean(nanmean(DATA.SP_data(n,:)))/beta_1p_temp;
    
    alpha_1p = [alpha_1p alpha_1p_temp]
    beta_1p  = [beta_1p beta_1p_temp]
    %}



end 
%legend(str_temp)

figure(2)
%plot(velocity_bins(1:(length(velocity_bins)-1)), num_points,'b*-','linewidth',2);
bar(velocity_bins(1:(length(velocity_bins)-1)), num_points);
xlabel('Velocity bins (m/s)','fontsize',20)
ylabel('No: of Data points', 'fontsize', 20)
title('Number of data points per velocity bin','fontsize',20)
%legend('0-2','asdasd')
%legend (legend_lable')

figure(3)
plot(velocity_bins(1:(length(velocity_bins)-1)),alpha, 'r*-','linewidth', 3)
hold on
plot(velocity_bins(1:(length(velocity_bins)-1)),beta, 'b*-','linewidth', 3)
set(gca, 'YScale', 'log')
xlabel('Velocity bins (m/s)','fontsize',18)
ylabel('alpha', 'fontsize', 18)
title('(alpha & beta) vs windspeed', 'fontsize', 20)
legend('alpha','beta')

figure(4)
plot(velocity_bins(1:(length(velocity_bins)-1)),alpha.*beta, 'r*-','linewidth', 3)
xlabel('Velocity bins (m/s)','fontsize',18)
ylabel('alpha*beta', 'fontsize', 18)
title('Mean diameter (microns) vs windspeed', 'fontsize', 20)

poly_order = 10;
alpha_error = zeros(poly_order,2);
beta_error = zeros(poly_order,2);
all_error = zeros(poly_order,4);
% polynomial fit to data 
for k=1:poly_order
    velocity_fit_data = velocity_bins(1:2:(length(velocity_bins)-1))
    alpha_fit_data = alpha(1:2:end)
    beta_fit_data = beta(1:2:end)

    velocity_test_data = velocity_bins(2:2:(length(velocity_bins)-1))
    alpha_test_data = alpha(2:2:end)
    beta_test_data = beta(2:2:end)
    
    alpha_poly = polyfit(velocity_fit_data,alpha_fit_data,k);
    xtemp = min(velocity_fit_data):0.1:max(velocity_fit_data);
    alpha_fit_val = polyval(alpha_poly,xtemp);
    
    beta_poly = polyfit(velocity_fit_data,beta_fit_data,k);
    xtemp = min(velocity_fit_data):0.1:max(velocity_fit_data);
    beta_fit_val = polyval(beta_poly,xtemp);

    alpha_fit_error = sum((polyval(alpha_poly,velocity_fit_data) - alpha_fit_data).^2);
    beta_fit_error = sum((polyval(beta_poly,velocity_fit_data) - beta_fit_data).^2);

    alpha_test_error = sum((polyval(alpha_poly,velocity_test_data) - alpha_test_data).^2)
    beta_test_error = sum((polyval(beta_poly,velocity_test_data) - beta_test_data).^2)
    
    alpha_error(k,1) = alpha_fit_error
    alpha_error(k,2) = alpha_test_error

    beta_error(k,1) = beta_fit_error
    beta_error(k,2) = beta_test_error
    

end
all_error = [alpha_error beta_error]
writematrix(all_error,'mosaic_alphabeta_error.csv')

%{ 
% This is the original working code
alpha_poly = polyfit(velocity_bins(1:(length(velocity_bins)-1)),alpha,4);
xtemp = min(velocity_bins(1:(length(velocity_bins)-1))):0.1:max(velocity_bins(1:(length(velocity_bins)-1)));
alpha_fit_val = polyval(alpha_poly,xtemp);

beta_poly = polyfit(velocity_bins(1:(length(velocity_bins)-1)),beta,4);
xtemp = min(velocity_bins(1:(length(velocity_bins)-1))):0.1:max(velocity_bins(1:(length(velocity_bins)-1)));
beta_fit_val = polyval(beta_poly,xtemp);
%}


figure(5)
plot(velocity_bins(1:(length(velocity_bins)-1)),alpha, 'r*-','linewidth', 3)
hold on
plot(xtemp,alpha_fit_val, 'k--','linewidth', 2)
hold on
plot(velocity_bins(1:(length(velocity_bins)-1)),beta, 'b*-','linewidth', 3)
hold on
plot(xtemp,beta_fit_val, 'k.-','linewidth', 2)
hold on
set(gca,'YScale','log')
xlabel('Velocity bins (m/s)','fontsize',18)
ylabel('Alpha & Beta', 'fontsize', 18)
title('(Alpha & Beta) vs windspeed', 'fontsize', 20)
%title('alpha and beta vs ')
legend({'Alpha','Alpha fit','Beta','Beta fit'},'fontsize',14)


figure(6)
plot(velocity_bins(1:(length(velocity_bins)-1)),meanT, 'r*-','linewidth', 3)
xlabel('Velocity bins (m/s)','fontsize',20)
ylabel('mean Temperture', 'fontsize',20)
title('mean Temperature vs velocity bins','fontsize',22)


figure(7)
bar(velocity_bins(1:(length(velocity_bins)-1)),Nsum_array)
xlabel('Velocity bins (m/s)','fontsize',20)
ylabel('N_{Total} (particles /cm3)', 'fontsize',20)
title('N_{Total} (/cm3) vs velocity bins','fontsize',22)

qw = [alpha.*beta;uncertainty_of_mean];

figure(8)
yyaxis left
plot(velocity_bins(1:(length(velocity_bins)-1)),alpha.*beta,'b*-','linewidth',2)
xlabel('Velocity bins (m/s)','fontsize',20)
set(gca,'YScale','log')
ylabel('Mean Diameter (microns)','fontsize',20)
yyaxis right
plot(velocity_bins(1:(length(velocity_bins)-1)),uncertainty_of_mean,'r*-','linewidth',2)
ylabel('Uncertainty of mean','fontsize',20)



%{
figure(7)

t_series = datenum(DATA.t);
t_org = datetime(t_series,'ConvertFrom','datenum');

N_Total = nansum(DATA.N,2);
U_series = DATA.U5cm;
dmean_series = nanmean(DATA.SP_data,2);
Temp_series = DATA.T;

subplot(3,1,1)
plot(t_org,DATA.N_sum/1e6)
set(gca,'YScale','log')
title('Total Aerosol number concentration (/cm3) vs Time','fontsize',14)
xlabel('Time','fontsize',14)
ylabel('N_{Total}','fontsize',14)

subplot(3,1,2)
plot(t_org,U_series)
title('Wind Velocity vs Time','fontsize',14)
xlabel('Time','fontsize',14)
ylabel('U (m/s)','fontsize',14)

subplot(3,1,3)
plot(t_org,Temp_series)
title('Temperature vs Time','fontsize',14)
xlabel('Time','fontsize',14)
ylabel('Temperature (C)','fontsize',14)

%}



%{
% single parameter fit .. using xins method 
figure(6)
plot(velocity_bins(1:(length(velocity_bins)-1)),alpha_1p, 'r*-','linewidth', 3)
hold on
plot(velocity_bins(1:(length(velocity_bins)-1)),beta_1p, 'b*-','linewidth', 3)
hold on
set(gca,'YScale','log')
%}



