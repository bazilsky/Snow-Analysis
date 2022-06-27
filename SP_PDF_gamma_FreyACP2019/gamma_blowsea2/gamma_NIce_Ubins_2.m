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
%pth = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/blowsea/SPC/data/' % new path for data files
pth_2 = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/mosaic/newdata_with_metcity/' % path for mosaic data
pth = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/N-ICE/data/' % nice path 
%fname = sprintf('%sSPC_crow_1min.mat',pth);
fname_2 = sprintf('%sU1104_8cm_1min.mat',pth_2);
fname = sprintf('%sSPC_ice_1min.mat',pth); %surface data for NIce campaign


% fname = sprintf('%sSPC_ice_1min.mat',pth);
DATA = load(fname);
DATA_2 = load(fname_2);
%% estimate two extrapolated wind speeds
zo_1 = 5.6e-5; 
zo_2 = 2.3e-4;

U1 = DATA.ws1_1m;

U2_1 = U1 * log(8e-2/zo_1)/log(1/zo_1);

U2_2 = U1 * log(8e-2/zo_2)/log(1/zo_2);
U2_2 = U1;
%%

%% select period of interest
% 1) example BSn at 0.2 & 29m (IS5)
t1 = datenum('14-Jul-2013 23:15'); t2 = datenum('14-Jul-2013 23:26');
% snowfall only #1 observed 3/7/13 15:00, 4/7/13 0:05 & 6:15
% t1 = datenum('3-Jul-2013 14:30'); t2 = datenum('4-Jul-2013 7:00'); % Nsum of SPC-crw & SPC-ice look similar
u_lower =  4.1
u_higher = 4.2


%n = find(DATA.t(:,1)>=t1 & DATA.t(:,1)<t2);
%n = find(DATA.U8cm_ex > u_lower & DATA.U8cm_ex<u_higher)
n = find(U2_2 > u_lower & U2_2<u_higher)

%calculate mean diameter %%%%%%%%%%%
N_a = DATA.N;
dp_a = DATA_2.dp_bins(:,3);
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
%%%%%%%%%%%%%
dp_mean_arr = []

% 2) example diamond dust/ snow crystals
% diamond dust #1 observed at 29/07/13 21:38
% t1 = datenum('29-Jul-2013 20:00'); t2 = datenum('29-Jul-2013 23:00');
% diamond dust #2 observed at 30/07/13 9:15
% t1 = datenum('30-Jul-2013 7:30'); t2 = datenum('30-Jul-2013 10:30');
%% x-data: 64 SPC particle size bins
x = DATA_2.dp_bins(:,3)'; % dp in micron
binWidth = DATA_2.dp_bins(:,4)'; % binwidth in micron
% remove bot & top bin of spc number densities because spurious particle detection
x(1) = []; x(end) = [];
binWidth(1) = []; binWidth(end) = [];

%% y-data (pdf) & other
% average if more than one line
N = nanmean(DATA.N(n,:),1);
dp_mean_final = nanmean(dp_mean(n,:),1);
%ust = nanmean(DATA.ust(n));
%U10m = nanmean(DATA.U10m(n));
% remove bot & top bin of spc number densities because spurious particle detection
N(:,1) = []; N(:,end) = [];
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

figure(1)   % show it as a bar plot
clf
%str = sprintf('\\alpha %5.2f \\pm %0.2f, \\beta %5.2f \\pm %0.2f, \\alpha\\beta %3.0f \\mum',...
%    p_ret(1), ep_ret(1),p_ret(2), ep_ret(2), p_ret(1).*p_ret(2));

str = sprintf('\\alpha %5.2f \\pm %0.2f, \\beta %5.2f \\pm %0.2f, \\alpha\\beta %3.0f \\mum, d_{p} %3.0f \\mum',...
    p_ret(1), ep_ret(1),p_ret(2), ep_ret(2), p_ret(1).*p_ret(2),dp_mean_final);

title(str,'fontsize',14);
hold on 
bar(x,pdf)
plot(x_fine,pdf_ret,'r-','linewidth',2);
ylim([0 0.025])
xlabel('d_p (\mum)','fontsize',14);
ylabel('PDF','fontsize',14);


%% estimate the 8cm wind speed using a different roughness length 



diff = U2_2 - U2_1
a1 = datestr(DATA.t, 'mm/dd/YYYY');
a2 = datetime(a1);
figure(2)
plot(a2,diff,'b*')
%ylim([0 0.015])
xlabel('Time','fontsize',14);
ylabel('U8cm difference (m/s)','fontsize',14);
title('( U8cm @z0 = 2.3e-4 ) - (U8cm @z0 = 5.6e-5)','fontsize', 22);
%U2 = U1 * log(z2/z0) / log (z1/z0)



a3 = datestr(DATA.t(n,:), 'mm/dd/YYYY');
a4 = datetime(a3);

% figure(3)
% plot(a4, DATA.U8cm_ex(n,:),'b*')
% title('U8cm (m/s) vs Time','fontsize',20)
% xlabel('Time','fontsize',18)
% ylabel('U8cm (m/s)','fontsize',18)
% no_of_data_points = length(a2);


% figure(4)
% diff = DATA.U8cm_ex - U2_1;
% plot(a2,diff,'r.');


