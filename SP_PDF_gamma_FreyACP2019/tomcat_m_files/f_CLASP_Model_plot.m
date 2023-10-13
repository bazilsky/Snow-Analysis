function f_CLASP_Model_plot(N_SSAmodel)
%f_CLASP_Model_plot - plot CLASP and pTomCat model output time series
%     panel a: SPC (01.m)
%     panel b: CLASP (2.0m) sea ice (SI) open ocean (OO) 
%
%   MF Cambridge, 24.03.2023

% clear;
close('all');

%% Parameters
% path from HERE to input
pth_CLASP = '../../CLASP/data/';
pth_SPC = '../../SPC/data/';      % path from HERE to data

% Load data
fname = sprintf('%sclasp_all_1min.mat',pth_CLASP);
load(fname);
fname = sprintf('%sU1104_8cm_1min.mat',pth_SPC);
U1104 = load(fname);
fname = sprintf('%sU1206_10m_1min.mat',pth_SPC);
U1206 = load(fname);

openfig ./temp4.fig;
h = get(gcf,'children'); % get axes handles
t1 = datenum('15-Oct-2019'); t2 = datenum('15-Aug-2020');


%***********************************************************************************************
%% PANEL A. Total Snow Particles
set(gcf,'CurrentAxes',h(1));
plot(U1104.t(:,1),nansum(U1104.N(:,:)/1e6,2),'k-'); % total snow particles at 0.1m [1/cm3]
hold on; grid on;
% plot(U1206.t(n3,1),nansum(U1206.N(n3,:)/1e6,2),'b-'); % total snow particles [1/cm3]
% Sset(gca,'XLim',[t1 t2],'YAxisLocation','left');
ylabel('N_{TOT 50-500 \mum} (cm^{-3})', ...
    'Rotation',90, ...
    'VerticalAlignment','bottom', ...
    'FontSize',18,'FontName','Times');
datetick(gca,'keeplimits');
set(gca,'YLim',[0 10],'XLim',[t1 t2],'XTickLabel',[]);
% title('N_{0.5-20\mum}', ...
%     'FontName','Times','FontSize',20);
legend('SPC 0.1m','Location','northwest');

% %***********************************************************************************************
%% PANEL B. total CLASP particles (observations vs model)
set(gcf,'CurrentAxes',h(2));
plot(CLASP.t(:,1),nansum(CLASP.conc(:,1:16),2),'k-'); % [particle/cm3]
hold on; grid on;
plot(N_SSAmodel(:,1),N_SSAmodel(:,3)./1e6,'b-'); % [particle/cm3]
plot(N_SSAmodel(:,1),N_SSAmodel(:,2)./1e6,'r-'); % [particle/cm3]

set(gca,'XLim',[t1 t2],'YAxisLocation','right');
ylabel('N_{TOT 0.5-20 \mum} (cm^{-3})', ...
    'Rotation',270, ...
    'VerticalAlignment','bottom', ...
    'FontSize',18,'FontName','Times');

% set(s,'FontSize',18);
set(gca,'YLim',[0 200]);
datetick(gca,'keeplimits');
xlabel('UTC','FontSize',18,'FontName','Times');
legend('CLASP 2.0m','OO','SI','Location','NorthWest');

%***********************************************************************************************
set(h,'FontSize',16,'FontName','Times');
set(0,'defaultaxeslinewidth',2); set(0,'defaultlinelinewidth',1);
linkaxes(h,'x');

