function plot_SPC5a()
%PLOT_SPC5a - plot SPC time series
%   Plot to SPC & precipitation data
% 
%   a. U10m / T29m
%   b. precipitation from PWDM1 & KAZR
%   c. contour plot SPC-Unit1104 - corrected 
%
%   MF Cambridge, 23.05.2022


clear;                 % clear variables and
close('all');          % ...close figures
pth = '../../data/';      % path from HERE to data
fname = sprintf('%sU1104_8cm_1min.mat',pth);
U1104 = load(fname);
fname = sprintf('%sU1206_10m_1min.mat',pth);
U1206 = load(fname);
pth = '../../data/DavidWagner_files/SPC_archive_13052022/';      % path from HERE to data
fname = sprintf('%sKAZR_derivedS_matrosov_1h.mat',pth);
KAZR = load(fname);
fname = sprintf('%sPWDM1_leg1_3.mat',pth);
PWDM1 = load(fname);

openfig ./temp_SPC1.fig;
h = get(gcf,'children'); % get axes handles

t1 = datenum('1-Jan-2020 0:00:00'); t2 = datenum('1-Feb-2020 0:00:00');


%*******************************CALCULUS********************************************************

% drift threshold U10m (Li and Pomeroy, 1997)
Ut = 6.975 + 0.0033.*(U1104.T10m+27.27).^2;
test = U1104.U10m-Ut;
n = find(test>=0);
m = find(test<0);
Udrift = U1104.U10m;
Udrift(m) = NaN;

%***********************************************************************************************
%% PANEL A. METEO - U10m / T29m
set(gcf,'CurrentAxes',h(1));
h1 = plotyy(U1104.t_NOAA,U1104.U10m,U1104.t_NOAA,U1104.T10m);
set(gcf,'CurrentAxes',h1(1));
hold on;
plot(U1104.t_NOAA,Udrift,'k-');
plot(U1104.t_NOAA,Ut,'r--');
li = get(gca,'children');
set(li(3),'LineStyle','-','LineWidth',1,'Color',[0.5 0.5 0.5]);
yl = {'' '5' '10' '15' '20' '25' '30'}; % y-axis labels
set(gca,'Box','off','YLim',[0 20],'YTick',[0 5 10 15 20 25 30],'YTickLabel',yl,'YColor','k');
ylabel('U_{10m} (m s^{-1})', ...
    'Rotation',90, ...
    'VerticalAlignment','bottom', ...
    'FontSize',18,'FontName','Times');
% l1 = vline(datenum('14-July-2013 12:00'),'r');
% l2 = vline(datenum('16-July-2013 00:00'),'r');
% set(l1,'LineWidth',2);set(l2,'LineWidth',2);
title('MOSAiC 2019-20','FontSize',24)
set(gcf,'CurrentAxes',h1(2));
li = get(gca,'children');
set(li,'LineStyle','-','LineWidth',1,'Color','b');
hold on;

yl = {'-40' '-30' '-20' '-10' '0' '10'};
set(gca,'YLim',[-45 10],'YColor','b','YTick',[-40 -30 -20 -10 0 10],...
    'YTickLabel',yl);
ylabel('T_{10m} (^{\circ}C)', ...
    'Rotation',270, ...
    'VerticalAlignment','bottom', ...±
    'FontSize',16,'FontName','Times');

set(h1, 'XLim',[t1 t2], ...
    'XGrid','on', ...
    'GridLineStyle','-');
datetick(h1(1),'keeplimits');
datetick(h1(2),'keeplimits');
set(h1,'XTickLabel',[]);

% Create line
annotation(gcf,'line',[0.100740740740741 0.901481481481482],...
    [0.900153609831029 0.901689708141321],'LineWidth',2);

%***********************************************************************************************
%% PANEL B. Precipitation from PWDM1 & KAZR
set(gcf,'CurrentAxes',h(2)); 
%sort rows
PWDM1 = sortrows([datenum(PWDM1.DateTimeUTC),PWDM1.precip_ratemmhr],1);
t_PWDM1 = PWDM1(:,1);PWDM1 = PWDM1(:,2);
% KAZR = sortrows([datenum(KAZR.Time),KAZR.VarName3,KAZR.VarName4,KAZR.VarName5,KAZR.VarName6],1);
% t_KAZR = KAZR(:,1); KAZR = KAZR(:,2:end);

plot(t_PWDM1, PWDM1,'k-');
hold on; grid on;
plot(datenum(KAZR.Time), KAZR.VarName3,'r-');
plot(datenum(KAZR.Time), KAZR.VarName4,'b-');
plot(datenum(KAZR.Time), KAZR.VarName5,'g-');

ylabel('precipitation rate (mm hr^{-1})');
set(gca, 'XLim',[t1 t2],'YLim',[0 1],'XTickLabel',[]);
legend('PWDM1','KAZR-153m','KAZR-183m','KAZR-213m','Location','northwest');


%***********************************************************************************************
%% PANEL C. U1104 with T-correction
% % compute dN/dlogDp
n = find(U1104.t>=t1 & U1104.t<t2);
X = [U1104.t(n) U1104.N(n,:)]; % unit [m-3]
% X = rm_double(X,1);
dlogD = log10(U1104.dp_bins(:,2))-log10(U1104.dp_bins(:,1));
X(:,2:end) = X(:,2:end)./dlogD';

% do the plot
v = [0 10 100 1e3 1e4 1e5 1e6 1e7]; % color scheme; include zero counts
vl = {'0' '10^1' '10^2' '10^3' '10^4' '10^5' '10^6' '10^7'}; % color scheme labels
y = [36 50 75 100 125 150 175 200 225 250 275 300 325 350 375 400 425 450 475 500]; % y-axis ticks at meanD
yl = {'' '50' '75' '100' '' '' '' '200' '' '' '' '300' '' '' '' '' '' '' '' '500'}; % y-axis labels

set(gcf,'CurrentAxes',h(3)); 
if n
    [C,hc] = contourf(X(:,1),log10(U1104.dp_bins(:,3)),log10(X(:,2:end)'),log10(v));
    set(hc,'edgecolor','none');
    caxis([0 log10(v(end))]); % scale colormap of this plot
    s = get(gca,'Position'); % remember axis position
    set(gca,'Position',s);
end
% format axes
set(h(3), 'XLim',[t1 t2],'XGrid','off','GridLineStyle','-',...
        'YLim',log10([y(1) y(end)]),'YTick',log10(y),'YTickLabel',yl,...
        'YAxisLocation','right');
ylabel('D_p (\mu m) at 8cm',...
    'Rotation',270, ...
    'VerticalAlignment','bottom', ...
    'FontSize',16,'FontName','Times');

datetick('x','mm/dd HH','keepticks','keeplimits');
xlabel('UTC','FontSize',16,'FontName','Times');


%***********************************************************************************************
H = [h;h1(2)];
set(H,'FontSize',16,'FontName','Times');
set(0,'defaultaxeslinewidth',2); set(0,'defaultlinelinewidth',1);
linkaxes(H,'x');




