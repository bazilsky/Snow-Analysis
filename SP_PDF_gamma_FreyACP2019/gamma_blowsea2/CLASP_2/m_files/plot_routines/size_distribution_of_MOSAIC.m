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
%openfig /Users/ananth/Desktop/bas_github_scripts/bas_github_scripts/SP_PDF_gamma_FreyACP2019/gamma_blowsea2/CLASP_2/data/temp3.fig

%h = get(gcf,'children'); % get axes handles

t1 = datenum('02-Dec-2019 23:15'); 
t2 = datenum('09-May-2020 23:26'); %

% t1 = datenum('15-Mar-2020 23:15'); 
% t2 = datenum('31-Mar-2020 23:26'); %



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

%{
%% PANEL A. Total Snow Particles
set(gcf,'CurrentAxes',h(1));


%plot(U1104.t(n2,1),U1104.U10m_ex(n2),'k-'); % U10m wind speed

hold on; grid on;
% plot(U1206.t(n3,1),nansum(U1206.N(n3,:)/1e6,2),'b-'); % total snow particles [1/cm3]
set(gca,'XLim',[t1 t2],'YAxisLocation','left');
ylabel('U_{10m} (ms^{-1})', ...
    'Rotation',90, ...
    'VerticalAlignment','bottom', ...
    'FontSize',18,'FontName','Times');
datetick(gca,'keeplimits');
set(gca,'YLim',[0 6],'XTickLabel',[]);
% title(['U_{10m} from ' datestr(t1,'dd/mm/yyyy') ' to ' datestr(t2,'dd/mm/yyyy')], ...
%     'FontName','Times','FontSize',20);
ylim([0,20])

% calc threshold windspeed
%T_fine = linspace(-50,10,100);
T_pth = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/mosaic/newdata_with_metcity/'
fname2 = sprintf('%stower_NOAA_1min.mat',T_pth);
DATA2 = load(fname2)

rolling_mean_width = 10; % 10min average
t_noaa = movmean(DATA2.tower_NOAA.t,rolling_mean_width);
T_noaa_skin = movmean(DATA2.tower_NOAA.skin_temp_surface,rolling_mean_width);




Ut0 = 6.975;

Ut = Ut0 + 0.0033.*(T_noaa_skin+27.27).^2;
plot(t_noaa,Ut,'r')

T_noaa_interp = interp1(t_noaa, T_noaa_skin, U1104.t(n2,1), 'nearest');
Ut_interp = Ut0 + 0.0033.*(T_noaa_interp+27.27).^2;

% Plot black line for values above threshold windspeed
idx_above_threshold = U1104.U10m_ex(n2) > Ut_interp;
plot(U1104.t(n2(idx_above_threshold),1), U1104.U10m_ex(n2(idx_above_threshold)), 'k.','MarkerSize',15);

% Plot grey line for values below threshold windspeed
idx_below_threshold = U1104.U10m_ex(n2) <= Ut_interp;
%plot(U1104.t(n2(idx_below_threshold),1), U1104.U10m_ex(n2(idx_below_threshold)),'.','Color', [0.5 0.5 0.5]);
plot(U1104.t(n2(idx_below_threshold), 1), U1104.U10m_ex(n2(idx_below_threshold)), '.', 'Color', [0.5 0.5 0.5], 'MarkerSize', 15);


%legend('U_t','U_{10m} > U_t','U_{10m} < U_t','Location','northeast');


%plot(t_noaa, Ut);



% legend('Snow Particles at 10cm','Location','northwest');
%% 
%% 

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
%vl = ['0' '10^1' '10^2' '10^3' '10^4' '10^5' '10^6' '10^7']'; % color scheme labels
%vl = ['0','10^1', '10^2', '10^3', '10^4', '10^5', '10^6', '10^7'];
%vl = string(num2str(v, '%.1e'));
vl = ["0","10^1", "10^2", "10^3", "10^4", "10^5", "10^6", "10^7"];
%vl = ['0','10^1', '10^2', '10^3', '10^4', '10^5', '10^6', '10^7'];
y = [36 50 75 100 125 150 175 200 225 250 275 300 325 350 375 400 425 450 475 500];     % y-axis ticks at meanD
yl = {'' '50' '75' '100' '' '' '' '200' '' '' '' '300' '' '' '' '' '' '' '' '500'};     % y-axis labels
set(gcf,'CurrentAxes',h(2));

[C,hc] = contourf(X(:,1),log10(U1104.dp_bins(:,3)),log10(X(:,2:end)'),log10(v));
% [C,hc] = contourf(X(:,1),U1104.dp_bins(:,3),dNdlogD_2',v);
%[C,hc] = contourf(CLASP.t(n0,1),CLASP.meanR(1,:)*2,dNdlogD',v);
%[C,hc] = contourf(X(:,1),U1104.dp_bins(:,3),X(:,2:end)',v);
%[C,hc] = contourf(X(:,1),U1104.dp_bins(:,3),X(:,2:end)',v);

set(hc,'edgecolor','none');
caxis([0 log10(v(end))]); % scale colormap of this plot
s = get(gca,'Position'); % remember axis position
cb = colorbar('EastOutside');
%cb.Ticks = vl
%cb.Ticks = v;
cb.TickLabels = vl;
set(gca,'Position',s);

% set(h(2), 'XLim',[t1 t2],'XGrid','off','GridLineStyle','-',...
%          'YLim',[y(1) y(end)],'YTick',y,'YTickLabel',yl,...
%          'YAxisLocation','left');

set(h(2), 'XLim',[t1 t2],'XGrid','off','GridLineStyle','-',...
         'YLim',log10([y(1) y(end)]),'YTick',log10(y),'YTickLabel',yl,...
         'YAxisLocation','left');
% 
% ylabel('D_p (\mu m) at 8cm',...
%      'Rotation',270, ...
%      'VerticalAlignment','bottom', ...
%     'FontSize',16,'FontName','Times');

% ht = text(gca,'FontName','Times New Roman','FontSize',16,...
%     'Rotation',270,...
%     'String','dN/dlog D_p (cm^{-3})',...
%     'Units','normalized',...
%     'Position',[1.059109232964 0.729002931267316 0]);

ylabel('D_p (\mu m)')

datetick('x','mm/dd HH','keepticks','keeplimits');
%xlabel('UTC','FontSize',16,'FontName','Times');


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
%}

%% PANEL C. CLASP contour plot

dlogD = diff(log10(CLASP.calibr(1).lowerR*2));

D = CLASP.calibr(1).lowerR*2;
dNdlogD = CLASP.conc(n0,1:16)./dlogD;

% do the plot
%  v = logspace(0,3,100); % colour bar space
v = linspace(0,50,100); % colour bar space

%[C,hc] = contourf(CLASP.t(n0,1),CLASP.meanR(1,:)*2,dNdlogD',v);

%***********************************************************************************************
dNdlogD_mean = nanmean(dNdlogD,1)
% figure(3)
% % semilogx(dlogD, dNdlogD,'o')
plot(D(1:15),dNdlogD_mean(1:15),'r','LineWidth',2)

set(gca,'XScale','log')
set(gca,'YScale','log')
% xlabel('Diameter (Dp)')
% ylabel('dN/dlogD')
% title('Size Distribution')
grid on
set(gca,'FontSize',16)
xlabel('D_p (\mum)','FontSize',18)
ylabel('dN/dlog{D_p}', 'FontSize',18)

title('Size distribution during MOSAIC','FontSize',20)










