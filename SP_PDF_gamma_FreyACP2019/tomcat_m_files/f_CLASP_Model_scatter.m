function f_CLASP_Model_scatter(N_SSAmodel)
%f_CLASP_Model_scatter - plot CLASP and pTomCat model output scatter plots
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

t = CLASP.t(:,1);
Ntot = nansum(CLASP.conc(:,1:16),2);
Ntot_i = interp1(t,Ntot,N_SSAmodel(:,1));

dummy = (1:100)';

%***********************************************************************************************
%% PANEL A. CLASP vs OO
figure;
subplot(1,2,1)
plot(N_SSAmodel(:,3)./1e6,Ntot_i,'bo'); % [particle/cm3]
hold on; grid on;
plot(dummy,dummy,'k-');
ylabel('N_{TOT 0.5-20 \mum} (cm^{-3})');
xlabel('SSA_{OO} (cm^{-3})');

%***********************************************************************************************
%% PANEL B. CLASP vs SI
subplot(1,2,2)
plot(N_SSAmodel(:,2)./1e6,Ntot_i,'ro'); % [particle/cm3]
hold on; grid on;
plot(dummy,dummy,'k-');

ylabel('N_{TOT 0.5-20 \mum} (cm^{-3})');
xlabel('SSA_{SI} (cm^{-3})');


%***********************************************************************************************
h = get(gcf,'children'); % get axes handles
set(h,'FontSize',16,'FontName','Times');
set(0,'defaultaxeslinewidth',2); set(0,'defaultlinelinewidth',1);

