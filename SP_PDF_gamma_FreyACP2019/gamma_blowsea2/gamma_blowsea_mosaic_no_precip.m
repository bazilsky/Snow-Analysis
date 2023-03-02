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
ismem_2 = ismember(t_org,kazr_time); % check kazr data

% ismem_3 = ismem_1 + ismem_2;

ismem_3 = ismem_1; % correct ismem_2 later

ismem = changem(ismem_3,1,2);

%ismem(ismem>1) == 1;

hold on
plot(kazr_time, KAZR.VarName4,'b-');

new_time_array = [];

% 
% for i=1:size(t_no_precip)
%     %length = length(t_no_precip);
%     counter = i;
%     time_filter = find(t_org == t_precip(i));
%     if length(time_filter) ~= 0
%         time_filter
%         t_org(time_filter) = [] ;
%     end
% end 


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
velocity_bins = (5.25:0.1:12.05);
velocity_bins = (1:0.1:9);
new_v_vector = []


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

U2_2 = U1; % using 10m windspeed for this parametrization. 

diff = U2_2 - U2_1;

DATA.t = DATA.t(~ismem);  % altering main time variable

a1 = datestr(DATA.t, 'mm/dd/YYYY');
a2 = datetime(a1);
figure(2)
plot(a2,diff,'b*')
xlabel('Time','fontsize',14);
ylabel('U8cm difference (m/s)','fontsize',14);
title('( U8cm @z0 = 2.3e-4 ) - (U8cm @z0 = 5.6e-5)','fontsize', 22);

%U2 = U1 * log(z2/z0) / log (z1/z0)
%%

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
N_a = DATA.N(~ismem,:);
dp_a = DATA.dp_bins(:,3);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
dp_mean = zeros(length(N_a),1);
sum_a = 0;
sum_b = 0;
for i=1:length(N_a)
    
    for j = 1:length(dp_a)
        sum_a = sum_a + N_a(i,j)*dp_a(j);
        sum_b = sum_b + N_a(i,j);
    end
    
    dp_mean(i) = sum_a/sum_b;
    sum_a = 0;
    sum_b = 0;
end 

dp_mean_arr = [];
dp_25_arr = [];
dp_75_arr = [];

DATA.N = DATA.N(~ismem,:);
DATA.T = DATA.T(~ismem,:);
DATA.MU = DATA.MU(~ismem,:);

for i = 1:(length(velocity_bins)-1)

    %n = find(DATA.t(:,1)>=t1 & DATA.t(:,1)<t2);
    % below line is taking into account the 8cm wind speed
    %n = find(DATA.U8cm_ex(:,1)>=velocity_bins(i) & DATA.U8cm_ex(:,1)<velocity_bins(i+1));

    n = find(U2_2>=velocity_bins(i) & U2_2<velocity_bins(i+1));
    % below line is for the 2m wind speed 
    %n = find(DATA.U2m(:,1)>=velocity_bins(i) & DATA.U2m_ex(:,1)<velocity_bins(i+1));

    num_points = [num_points length(n)];

    nonnan_count = nnz(~isnan(DATA.N(n)));
    uncertainty_of_mean = [uncertainty_of_mean nanstd(DATA.N(n))/sqrt(nonnan_count)];

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
%  average if more than one line
    N = nanmean(DATA.N(n,:),1);
    T = nanmean(DATA.T(n,:),1);
    dp_mean_obs = nanmean(dp_mean(n,:),1);
    dp_25_obs   = prctile(dp_mean(n,:),25);
    dp_75_obs   = prctile(dp_mean(n,:),75); 
    % ust = nanmean(DATA.ust(n));
    % U10m = nanmean(DATA.U10m(n));
    % remove bot & top bin of spc number densities because spurious particle detection
    N(:,1) = []; N(:,end) = [];
    % T(:,1) = []; T(:,end) = [];
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
    %p_init = [5 100];     
    %% send the information to f_generic_fit
    % this returns the least square fitted P (p_ret) and the 1-sigma uncertainty in P (ep_ret)
    [p_ret, ep_ret] = f_generic_fit(data,p_init,h,1);
    
    %% Plot best fit to scaled data
    x_fine = (0:0.01:max(x))';       % nice smooth line
    pdf_ret = f_build_2p_gamma(x_fine,p_ret);   % calc the curve
    

    Nsum_temp = nansum(DATA.N,2); % this new line because Nsum doesn't exist 

    Nsum_slice = nansum(Nsum_temp(n))/1e6;


    %Nsum_slice = nansum(DATA.N_sum(n))/1e6;
    Nsum_array = [Nsum_array Nsum_slice];

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
    meanT = [meanT T];
    dp_mean_arr = [dp_mean_arr dp_mean_obs];
    dp_25_arr   = [dp_25_arr dp_25_obs];
    dp_75_arr   = [dp_75_arr dp_75_obs];

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
bar(new_v_vector, num_points);
xlabel('Velocity bins (m/s)','fontsize', 20)
ylabel('No: of Data points', 'fontsize', 20)
title('Number of data points per velocity bin','fontsize',20)
%legend('0-2','asdasd')
%legend (legend_lable')

figure(3)
plot(new_v_vector,alpha, 'r*-','linewidth', 3)
hold on
plot(new_v_vector,beta, 'b*-','linewidth', 3)
set(gca, 'YScale', 'log')
xlabel('Velocity bins (m/s)','fontsize',18)
ylabel('alpha', 'fontsize', 18)
title('(alpha & beta) vs windspeed', 'fontsize', 20)
legend('alpha','beta')

figure(4)
plot(new_v_vector,alpha.*beta, 'r*-','linewidth', 3)
xlabel('Velocity bins (m/s)','fontsize',18)
ylabel('alpha*beta', 'fontsize', 18)
title('Mean diameter (microns) vs windspeed', 'fontsize', 20)

poly_order = 1;
alpha_error = zeros(poly_order,2);
beta_error = zeros(poly_order,2);
all_error = zeros(poly_order,4);
% polynomial fit to data


for k=1:poly_order
    
    velocity_fit_data = new_v_vector(1:2:end);
    alpha_fit_data = alpha(1:2:end);
    beta_fit_data = beta(1:2:end);

    velocity_test_data = new_v_vector(2:2:end);
    alpha_test_data = alpha(2:2:end);
    beta_test_data = beta(2:2:end);
    
    [alpha_poly,S1] = polyfit(velocity_fit_data,alpha_fit_data,k);
    xtemp = min(velocity_fit_data):0.1:max(velocity_fit_data);
    [alpha_fit_val,std1] = polyval(alpha_poly,xtemp,S1);
    
    [beta_poly,S2] = polyfit(velocity_fit_data,beta_fit_data,k);
    xtemp = min(velocity_fit_data):0.1:max(velocity_fit_data);
    [beta_fit_val,std2] = polyval(beta_poly,xtemp,S2);

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

yyaxis left

plot(new_v_vector,alpha, 'b*','linewidth', 3)
hold on
plot(xtemp,alpha_fit_val, 'b.-','linewidth', 3)
hold on
ylabel('\alpha', 'fontsize', 18)
%plot(xtemp,alpha_fit_val+2*std1,'r--',xtemp,alpha_fit_val-2*std1,'r--')
%hold on

yyaxis right
plot(new_v_vector,beta, 'r*','linewidth', 3)
hold on
plot(xtemp,beta_fit_val, 'r.-','linewidth', 3)
hold on
%plot(xtemp,beta_fit_val+2*std2,'b--',xtemp,beta_fit_val-2*std2,'b--')
%hold on
%set(gca,'YScale','log')
xlabel('U10m (m/s)','fontsize',18)
ylabel('\beta', 'fontsize', 18)
title('\alpha , \beta vs U10m', 'fontsize', 20)
%title('alpha and beta vs ')
%legend({'Alpha','Alpha fit','Beta','Beta fit'},'fontsize',14)


figure(6)
plot(new_v_vector,meanT, 'r*-','linewidth', 3)
xlabel('Velocity bins (m/s)','fontsize',20)
ylabel('Mean Temperature', 'fontsize',20)
title('Mean Temperature vs velocity bins','fontsize',22)


figure(7)
bar(new_v_vector,Nsum_array)
set(gca, 'YScale', 'log')
xlabel('U8cm (m/s)','fontsize',20)
ylabel('particles /m3 ', 'fontsize',20)
title('snow particle concentration (/m3) vs velocity bins','fontsize',22)

qw = [alpha.*beta;uncertainty_of_mean];

figure(8)
yyaxis left
plot(new_v_vector,alpha.*beta,'b*-','linewidth',2)
xlabel('U8cm (m/s)','fontsize',20)
set(gca,'YScale','log')
ylabel('Mean Diameter (\mum)','fontsize',20)
yyaxis right
plot(new_v_vector,num_points,'r*-','linewidth',2)
ylabel('Number of data points','fontsize',20)
title('Mean Diamter (\mum) vs Surface windspeed (m/s)','fontsize',18)

figure(9)
ydots = 0:1:200; % this is for the length of the vertical line for thresold 
% windspeed in the plot
ut = 5.25;  % Thresold windspeed for the mosaic campaign
%ut = 7.5; % using this for the N-ICE campaign. 
xdots = zeros(length(ydots),1);
xdots(:) = ut;

%plot(new_v_vector,alpha.*beta,'k.-','linewidth',1.5)
hold on 


%set(gca,'YScale','log')
xlabel('U10m (m/s)','fontsize',20)
%ylim([0 210])

%set(gca,'YScale','log')
ylabel('Mean Diameter (\mum) (surface SPC)','fontsize',20)
title('Mean Diamter at surface (\mum) vs U10m (m/s) - MOSAIC','fontsize',18)


hold on
plot(new_v_vector,dp_mean_arr,'k.-','linewidth',2)

p1 = patch([new_v_vector fliplr(new_v_vector)], [dp_25_arr fliplr(dp_75_arr)], 'k')
p1.FaceAlpha = 0.3;
scatter(new_v_vector,alpha.*beta,100,num_points,'filled')
%plot(xdots,ydots,'b--','linewidth',4) % plotting a vertical line indicating the thresold windspeed



plot(new_v_vector,dp_25_arr,'k-')
plot(new_v_vector,dp_75_arr,'k-')
hcb = colorbar
hcb.Title.String = "Number of data points";
hcb.FontSize = 12

%lgd = legend({'Obs mean','Obs interquartile range','\alpha \beta','Thresold windspeed'},'FontSize',14)

lgd = legend({'Obs mean','Obs interquartile range','\alpha \beta'},'FontSize',14)
%finding when the campaign happened 

a1 = datestr(DATA.t, 'mm/dd/YYYY');
store_month = []

for i = 1:length(a1)
   

   %store_month = [store_month str2num(a1(i,1:2))]; % this is the line for month 
   store_month = [store_month str2num(a1(i,7:end))]; % this is the line for year


end

figure(10)
plot(store_month,store_month)

%%%%%%%%%%%%%%%%%%%%%

density = DATA.MU;
%n = find(DATA.t(:,1)>=t1 & DATA.t(:,1)<t2);
m = find(density<=0.0001 & ~isnan(density) & ~isnan(U2_2));

figure(11)
%plot(U2_2(~isnan(density)),density(~isnan(density)),'r*')
plot(U2_2(m),density(m),'r.')
xlabel('U8cm (m/s)','fontsize',20)
ylabel('Drift density (kg/m3)','fontsize',20)
title('Drift density (kg/m3) vs U8cm (m/s)','fontsize',18)

figure(12)

vbin = 0:1:9;
vbin_2 = 0.5:1:8.5;
num_points_2 = [];

for i=1:(length(vbin)-1)
    
    p = find(U2_2(m)>vbin(i) & U2_2(m)<vbin(i+1));
    num_points_2 = [num_points_2 length(p)];

end

bar(vbin_2,num_points_2)
title('Number of data points vs windspeed','fontsize',20);
xlabel('U8cm','fontsize',18);
ylabel('Number of data points','fontsize',18);

