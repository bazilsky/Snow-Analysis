% do_gamma_blowsea
% 2-parameter gamma distribution fitting based on gamma_testbed.m by P. Anderson
% 	This version to loop through time series of N
%
% MF L'Estaque 28.09.2018

close all
clear all
clc
%% load blowsea data
%pth = '~/Documents/research/Antarctica/BLOWSEA/DATA/SPC/data/';      % path from HERE to data
pth = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/blowsea/SPC/data/';
fname = sprintf('%sSPC_crow_1min.mat',pth);
% fname = sprintf('%sSPC_ice_1min.mat',pth);
DATA = load(fname);
%% select period of interest
t1 = datenum('16-Jun-2013 00:00'); t2 = datenum('1-Jul-2013 00:00');
%t1 = datenum('14-Jul-2013 23:15'); t2 = datenum('14-Jul-2013 23:26');
% t1 = DATA.t(1); t2 = DATA.t(end);
n = find(DATA.t(:,1)>=t1 & DATA.t(:,1)<=t2);
%% x-data: 64 SPC particle size bins
x_org = DATA.dp_bins(:,3)'; %original line
x = 1:length(x_org); % i) index - acceptable fit
% remove bot & top bin of spc number densities because spurious particle detection
x(1) = []; x(end) = [];
%% y-data (pdf) & other
N = DATA.N(n,:);
t = DATA.t(n);
D_mean = DATA.dp_mean(n);
ust = DATA.ust(n);
U10m = DATA.U10m(n);

% remove bot & top bin of spc number densities because spurious particle detection
N(:,1) = []; N(:,end) = [];
% % compute PDF (area under curve = 1) only for times when snow particles are detected
N_sum = nansum(N,2);
o = find(N_sum==0);
N(o,:) = [];
N_sum(o) = [];
t(o) = [];
D_mean(o) = [];
ust(o) = [];
U10m(o) = [];
pdf = N./N_sum; % scale to get area 1

%% data fit loop
[r c] = size(pdf);
p_ret = nan(length(t),2);
ep_ret = nan(length(t),2);
exitflag = nan(length(t),1);
matrix = nan(length(t),1);

for i=1:r
    dummy = pdf(i,:);
    % replace NaN or zero with a small number to ensure stable fit
    m = find(isnan(dummy) | dummy==0);
    dummy(m) = 1e-12;
    
    %% Fit the best 2P gamma distribution to the noisy data
    h = @f_2p_gamma_diff;       % name of function for search  
    data.x = x;                 % structure for the data
    data.y = dummy;
    p_init = [2.1 5];         % 1st guess for search [shape scale];

    %% send the information to f_generic_fit
    % this returns the least square fitted P (p_ret) and the 1-sigma uncertainty in P (ep_ret)
    [p_ret(i,:), ep_ret(i,:), exitflag(i), matrix(i)] = f_generic_fit(data,p_init,h,1);
    
end

OUT = [t p_ret ep_ret exitflag matrix D_mean ust U10m N_sum];
% filter output
% i) exitflag=0 - Maximum number of function evaluations has been exceeded
n = find(OUT(:,6)==0);
OUT(n,:) = [];
% ii) matrix=1 - Hessian matrix is singular, close to singular or badly scaled
n = find(OUT(:,7)>=1);
OUT(n,:) = [];

%% plot gamma results  - crows nest
close('all')
%pth = '~/Documents/research/documents/publications/BLOWSEA_frey/graphs_final/';      % path from HERE to data
pth = '/Users/ananth/Desktop/scripts/graphs_final/'
fname = sprintf('%sdata_plotted.mat',pth);
load(fname);

% ANTXXIX/6 (8 June and 12 August)
t1 = datenum('12-Jun-2013 0:00'); t2 = datenum('12-Aug-2013 0:00');
% ANTXXIX/7 (August 14 and October 16)
% t1 = datenum('14-Aug-2013 0:00'); t2 = datenum('17-Oct-2013 0:00');

openfig ./temp_gamma.fig;
h = get(gcf,'children'); % get axes handles
% panel (a) N
set(gcf,'CurrentAxes',h(1))
title('2-p gamma PDF fitting results - Crows Nest','FontSize',14);
hold on;
plot(OUT_crw(:,1),OUT_crw(:,11),'k.');
grid on;
set(gca,'XLim',[t1 t2]);
datetick(gca,'x','DD','keeplimits');
set(gca,'XTickLabel',[]);
ylabel('N (m^{-3})');
% panel (b) d_p
set(gcf,'CurrentAxes',h(2))
plot(OUT_crw(:,1),OUT_crw(:,8),'k.');
hold on; grid on;
set(gca,'XLim',[t1 t2]);
datetick(gca,'x','DD','keeplimits');
set(gca,'XTickLabel',[]);
ylabel('d_p (\mu m)');
% panel (c) alpha
set(gcf,'CurrentAxes',h(3))
plot(OUT_crw(:,1),OUT_crw(:,2),'k.');
hold on; grid on;
set(gca,'XLim',[t1 t2],'YLim',[0 50]);
datetick(gca,'x','DD','keeplimits');
ylabel('\alpha');

set(h,'FontSize',16,'FontName','Times');
set(0,'defaultaxeslinewidth',2,'defaultlinelinewidth',1);
linkaxes(h,'x');

%% plot gamma results  - sea ice
close('all')
%pth = '~/Documents/research/documents/publications/BLOWSEA_frey/graphs_final/';      % path from HERE to data
pth = '/Users/ananth/Desktop/scripts/graphs_final/';
fname = sprintf('%sdata_plotted.mat',pth);
load(fname);

% ANTXXIX/6 (8 June and 12 August)
t1 = datenum('12-Jun-2013 0:00'); t2 = datenum('12-Aug-2013 0:00');
% ANTXXIX/7 (August 14 and October 16)
% t1 = datenum('14-Aug-2013 0:00'); t2 = datenum('17-Oct-2013 0:00');

openfig ./temp_gamma.fig;
h = get(gcf,'children'); % get axes handles
% panel (a) N
set(gcf,'CurrentAxes',h(1))
title('2-p gamma PDF fitting results - Sea Ice','FontSize',14);
hold on;
plot(OUT_ice(:,1),OUT_ice(:,11),'k.');
grid on;
set(gca,'XLim',[t1 t2]);
datetick(gca,'x','DD','keeplimits');
set(gca,'XTickLabel',[]);
ylabel('N (m^{-3})');
% panel (b) d_p
set(gcf,'CurrentAxes',h(2))
plot(OUT_ice(:,1),OUT_ice(:,8),'k.');
hold on; grid on;
set(gca,'XLim',[t1 t2]);
datetick(gca,'x','DD','keeplimits');
set(gca,'XTickLabel',[]);
ylabel('d_p (\mu m)');
% panel (c) alpha
set(gcf,'CurrentAxes',h(3))
plot(OUT_ice(:,1),OUT_ice(:,2),'k.');
hold on; grid on;
set(gca,'XLim',[t1 t2],'YLim',[0 50]);
datetick(gca,'x','DD','keeplimits');
ylabel('\alpha');

set(h,'FontSize',16,'FontName','Times');
set(0,'defaultaxeslinewidth',2,'defaultlinelinewidth',1);
linkaxes(h,'x');

%%  other stuff

% % find N_sum
% [r c] = size(OUT_ice(:,1));
% id = [];
% for i = 1:r
%     dummy = find(DATA.t>=OUT_ice(i,1));
%     id(i) = dummy(1);
% end

    


