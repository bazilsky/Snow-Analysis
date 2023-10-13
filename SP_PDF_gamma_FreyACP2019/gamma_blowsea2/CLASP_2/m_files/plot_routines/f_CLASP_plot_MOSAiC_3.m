%function f_CLASP_plot_MOSAiC(days)
%f_CLASP_plot_MOSAiC - plot CLASP on day
%   f_CLASP_plot_MOSAiC(day) - plot CLASP on days
%   call function from RUN_CLASP.m
%     
%
%   MF Trumpington, 1.04.2021

%% Parameters
% path from HERE to input
%pth_in = '../../data/';
%pth_PS_AWS = '../../../../0_ship_met_data/data/';
%pth_SPC = '../../../SPC/data/';      % path from HERE to data
clear all
close all
clc


pth_in = '/Users/ananth/Desktop/bas_github_scripts/bas_github_scripts/SP_PDF_gamma_FreyACP2019/gamma_blowsea2/CLASP_2/data/'
pth_PS_AWS = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/mosaic/newdata_with_metcity/' % wind speed data
pth_SPC = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/mosaic/newdata_with_metcity/'  % spc data and wind data in the file
pth_SPC = '/Users/ananth/Desktop/bas_github_scripts/bas_github_scripts/SP_PDF_gamma_FreyACP2019/data_2/'
% Load CLASP data
fname = sprintf('%sclasp_all_1min.mat',pth_in);
if(exist(fname,'file') == 0)
    sprintf('ERROR: unable to find %s',fname)
    return
else
    load(fname);
end

spc_file = sprintf('%sU1104_8cm_1min.mat',pth_SPC);



% Load PS_AWS data
%PS_AWS_file = sprintf('%sPS_AWS_2020-05-24.mat',pth_PS_AWS);
%MET = load(PS_AWS_file);
MET = load(spc_file)

% Load SPC data
%U1104_file = sprintf('%sSPC_Unit1104_8cm_1min.mat',pth_SPC);
%U1206_file = sprintf('%sSPC_Unit1206_10m_1min.mat',pth_SPC);

U1104 = load(spc_file)
%U1104 = load(U1104_file);
%U1206 = load(U1206_file);

%openfig ./temp3.fig;
openfig /Users/ananth/Desktop/bas_github_scripts/bas_github_scripts/SP_PDF_gamma_FreyACP2019/gamma_blowsea2/CLASP_2/data/temp3.fig

h = get(gcf,'children'); % get axes handles

t1 = datenum('01-Dec-2019 23:15'); 
t2 = datenum('01-Jun-2020 23:26'); %


%t1 = days(1); t2 = days(end);
n0 = find(CLASP.t(:,1)>=t1 & CLASP.t(:,1)<=t2);
n1 = find(MET.t>=t1 & MET.t<=t2);
n2 = find(U1104.t(:,1)>=t1 & U1104.t(:,1)<=t2);
%n3 = find(U1206.t(:,1)>=t1 & U1206.t(:,1)<=t2);



% %***********************************************************************************************
% %% PANEL A. Meteo (T29m, U39m)
% set(gcf,'CurrentAxes',h(1));
% if n1
%     h1 = plotyy(MET.t(n1),MET.U39m(n1),MET.t(n1),MET.T29m(n1));
%     set(gcf,'CurrentAxes',h1(1));
%     set(gca,'YLim',[0 25],'YTick',[0 10 20 30 40],'YTickLabel',[0 10 20 30 40 -45]);
%     ylabel('U_{39m} (m s^{-1})', ...
%         'Rotation',90, ...
%         'VerticalAlignment','bottom', ...
%         'FontSize',18,'FontName','Times');
% 
%     set(gcf,'CurrentAxes',h1(2));
%     li = get(gca,'children');
%     set(li,'LineWidth',1);
%     set(gca,'YLim',[-45 0],'YTick',[-40 -30 -20 -10 0],'YTickLabel',[-40 -30 -20 -10 0]);
%     ylabel('T_{29m} (^{\circ}C)', ...
%         'Rotation',270, ...
%         'VerticalAlignment','bottom', ...
%         'FontSize',18,'FontName','Times');
% 
%     set(h1, 'XLim',[t1 t2], ...
%         'XGrid','on', ...
%         'GridLineStyle','-');
%     datetick(h1(1),'keeplimits');
%     datetick(h1(2),'keeplimits');
%     set(h1,'XTickLabel',[]);
% end
% 
% title(['N_{0.5-20\mum} from ' datestr(t1,'dd/mm/yyyy') ' to ' datestr(t2,'dd/mm/yyyy')], ...
%     'FontName','Times','FontSize',20);

%***********************************************************************************************


%% PANEL A. Total Snow Particles
set(gcf,'CurrentAxes',h(1));

%plot(U1104.t(n2,1),nansum(U1104.N(n2,:)/1e6,2),'r-'); % total snow particles [1/cm3]

plot(U1104.t(n2,1),U1104.U10m_ex(n2),'k-'); % U10m wind speed

hold on; grid on;
% plot(U1206.t(n3,1),nansum(U1206.N(n3,:)/1e6,2),'b-'); % total snow particles [1/cm3]
set(gca,'XLim',[t1 t2],'YAxisLocation','left');
ylabel('U_{10m} (ms^{-1})', ...
    'Rotation',90, ...
    'VerticalAlignment','bottom', ...
    'FontSize',18,'FontName','Times');
datetick(gca,'keeplimits');
set(gca,'YLim',[0 6],'XTickLabel',[]);
title(['U_{10m} from ' datestr(t1,'dd/mm/yyyy') ' to ' datestr(t2,'dd/mm/yyyy')], ...
    'FontName','Times','FontSize',20);
ylim([0,20])
% legend('Snow Particles at 10cm','Location','northwest');

% %***********************************************************************************************
% %% PANEL B. total CLASP particles
%{
set(gcf,'CurrentAxes',h(2));
plot(CLASP.t(n0,:),nansum(CLASP.conc(n0,1:16),2),'b-');
hold on; grid on;

set(gca,'XLim',[t1 t2],'YAxisLocation','right');
ylabel('N_{TOT} (cm^{-3})', ...
    'Rotation',270, ...
    'VerticalAlignment','bottom', ...
    'FontSize',18,'FontName','Times');
% s = legend(li(1),'25 m','Location','NorthWest');
% set(s,'FontSize',18);
datetick(gca,'keeplimits');
set(gca,'YLim',[0 100],'XTickLabel',[]);
% datetick(gca,'keepticks','keeplimits');
%}
% Calculation of spc panel with diameter and particle number concentration
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X = [U1104.t(n2) U1104.N(n2,:)];
dlogD = log10(U1104.dp_bins(:,2))-log10(U1104.dp_bins(:,1));
X(:,2:end) = X(:,2:end)./dlogD';
dNdlogD_2 = U1104.N(n2,:)./dlogD';

v = [0 10 100 1e3 1e4 1e5 1e6 1e7]; % color scheme; include zero counts
vl = {'0' '10^1' '10^2' '10^3' '10^4' '10^5' '10^6' '10^7'}; % color scheme labels
y = [36 50 75 100 125 150 175 200 225 250 275 300 325 350 375 400 425 450 475 500];     % y-axis ticks at meanD
yl = {'' '50' '75' '100' '' '' '' '200' '' '' '' '300' '' '' '' '' '' '' '' '500'};     % y-axis labels
set(gcf,'CurrentAxes',h(2));

%[C,hc] = contourf(X(:,1),log10(U1104.dp_bins(:,3)),log10(X(:,2:end)'),log10(v));
[C,hc] = contourf(X(:,1),U1104.dp_bins(:,3),dNdlogD_2',v);
%[C,hc] = contourf(CLASP.t(n0,1),CLASP.meanR(1,:)*2,dNdlogD',v);
%[C,hc] = contourf(X(:,1),U1104.dp_bins(:,3),X(:,2:end)',v);
%[C,hc] = contourf(X(:,1),U1104.dp_bins(:,3),X(:,2:end)',v);

set(hc,'edgecolor','none');
caxis([0 v(end)]); % scale colormap of this plot
s = get(gca,'Position'); % remember axis position
colorbar('EastOutside');
set(gca,'Position',s);

set(h(2), 'XLim',[t1 t2],'XGrid','off','GridLineStyle','-',...
         'YLim',[y(1) y(end)],'YTick',y,'YTickLabel',yl,...
         'YAxisLocation','left');

% set(h(2), 'XLim',[t1 t2],'XGrid','off','GridLineStyle','-',...
%          'YLim',log10([y(1) y(end)]),'YTick',log10(y),'YTickLabel',yl,...
%          'YAxisLocation','left');

ylabel('D_p (\mu m) at 8cm',...
     'Rotation',270, ...
     'VerticalAlignment','bottom', ...
    'FontSize',16,'FontName','Times');

datetick('x','mm/dd HH','keepticks','keeplimits');
xlabel('UTC','FontSize',16,'FontName','Times');


%***********************************************************************************************
%% PANEL B. LaserRef
% set(gcf,'CurrentAxes',h(2));
% plot(CLASP.status.t_status(:,1),CLASP.status.LaserRef(:,1),'b-');
% hold on; grid on;
% 
% set(gca,'XLim',[t1 t2],'YAxisLocation','right');
% ylabel('LaserRef (mV)', ...
%     'Rotation',270, ...
%     'VerticalAlignment','bottom', ...
%     'FontSize',18,'FontName','Times');
% datetick(gca,'keeplimits');
% set(gca,'YLim',[0 4000],'XTickLabel',[]);
% hline(CLASP.calibr(1).laser_ref + 500,'r--');
% hline(CLASP.calibr(1).laser_ref - 300,'r--');
% hline(CLASP.calibr(1).laser_ref,'r-');


%% PANEL C. CLASP contour plot
% see discussion of presentation/ properties of size distributions N(dlogDp) (Seinfeld pp.416)
set(gcf,'CurrentAxes',h(3));
% compute dN/dlogDp
dlogD = diff(log10(CLASP.calibr(1).lowerR*2));
dNdlogD = CLASP.conc(n0,1:16)./dlogD;

% do the plot
%  v = logspace(0,3,100); % colour bar space
v = linspace(0,50,100); % colour bar space
% [C,hc] = contourf(CLASP.t(n0,1),CLASP.meanR(1,:)*2,dNdlogD',log10(v));
[C,hc] = contourf(CLASP.t(n0,1),CLASP.meanR(1,:)*2,dNdlogD',v);

s = get(gca,'Position');
colorbar('EastOutside');
set(gca,'Position',s);

% annotate colour scheme
ht = text(gca,'FontName','Times New Roman','FontSize',16,...
    'Rotation',270,...
    'String','dN/dlog D_p (cm^{-3})',...
    'Units','normalized',...
    'Position',[1.059109232964 0.729002931267316 0]);

set(hc,'edgecolor','none');
ylabel('D_p (\mu m)','FontSize',18,'FontName','Times');
xlabel('UTC','FontSize',18,'FontName','Times');
% axes
set(gca,'YLim',[CLASP.meanR(1,1)*2 10],'YScale','log','XLim',[t1 t2], ...
    'XGrid','off','YGrid','off','GridLineStyle','-');
datetick(gca,'keepticks','keeplimits');

%***********************************************************************************************
set(h,'FontSize',16,'FontName','Times');
set(0,'defaultaxeslinewidth',2); set(0,'defaultlinelinewidth',1);



