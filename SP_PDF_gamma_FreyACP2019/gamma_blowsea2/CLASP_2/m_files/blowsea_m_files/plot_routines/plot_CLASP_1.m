% plot_CLASP_1
% 
% plot total N time series  - N-ICE 2015
%
% MF San Pancho 14/12/2015

clear;                 % clear variables and
close('all');          % ...close figures
pth = '~/Documents/research/Arctic/N-ICE_2015/DATA/CLASP/data/';      % path from HERE to data
fname = sprintf('%sCLASP_crow_1min.mat',pth);
CRW = load(fname);
fname = sprintf('%sCLASP_lower_1min.mat',pth);
LOW = load(fname);
fname = sprintf('%sCLASP_upper_1min.mat',pth);
UP = load(fname);

% time interval of averaging & plotting
t1 = datenum('22-Feb-2015 00:00:00'); t2 = datenum('28-Mar-2015 00:00:00'); % leg 2
% t1 = CRW.t(1,1); t2 = CRW.t(end,1); % ALL data
n0 = find(CRW.t(:,1)>=t1 & CRW.t(:,1)<=t2);

% BSn Index to create Shaded TimeSeries
period = [datenum('28-Feb-2015 03:10:00') datenum('04-Mar-2015 18:49:00'); ...
    datenum('13-Mar-2015 21:34:00') datenum('21-Mar-2015 06:03:00')]; % (Leg 2)
[r, c] = size(period);
index0 = zeros(length(CRW.ws1_org(:,1)),1);
for i = 1:r
    n = find(CRW.ws1_org(:,1)>=period(i,1) & CRW.ws1_org(:,1)<period(i,2));
    index0(n) = 1;
end
index1 = zeros(length(CRW.t),1);
for i = 1:r
    n = find(CRW.t>=period(i,1) & CRW.t<period(i,2));
    index1(n) = 1;
end
index2 = zeros(length(UP.t),1);
for i = 1:r
    n = find(UP.t>=period(i,1) & UP.t<period(i,2));
    index2(n) = 1;
end

openfig ./temp1.fig;
h = get(gcf,'children'); % get axes handles

%***********************************************************************************************
% PANEL A. wspd
set(gcf,'CurrentAxes',h(1));

% a) shaded time series
shadedTimeSeries(CRW.ws1_org(:,1),CRW.ws1_org(:,2),index0,'',{''},[0.7 0.7 0.7],10);
% b) regular plot
% plot(CRW.t,CRW.ws1);

set(gcf,'CurrentAxes',h(1));
set(h(1),'YLim',[0 30], ...
    'YTick',[5 10 15 20 25 30], ...
    'YTickLabel',[5 10 15 20 25 30], ...
    'YColor','k', ...
    'Box','on');
li = get(h(1),'children');
set(li(1),'LineStyle','-','Color','k','LineWidth',1,'Marker','none');
ylabel('wspd (m s^{-1})', ...
    'Rotation',90, ...
    'VerticalAlignment','bottom', ...
    'FontSize',18,'FontName','Times');

title(['Total SSA number densities (0.35-10\mum) from ' datestr(t1,'dd/mm/yyyy') ' to ' datestr(t2,'dd/mm/yyyy')], ...
    'FontName','Times','FontSize',20);
set(h(1), 'XLim',[t1 t2], ...
    'XGrid','on');
s = legend(li(1),'23 m','Location','NorthWest');
set(s,'FontSize',18);
datetick(h(1),'keepticks','keeplimits');
set(h(1),'XTickLabel',[]);


% Create line
annotation(gcf,'line',[0.150617283950617 0.851921274601687],...
    [0.90112130479103 0.900302114803625],'LineWidth',1);

%***********************************************************************************************
% PANEL B. SSA at 25m (CROWS nest)
set(gcf,'CurrentAxes',h(2));
% remove zeros
yi = nansum(CRW.N'); n = find(yi==0); yi(n) = NaN;
% a) shaded time series
shadedTimeSeries(CRW.t,yi./1e7,index1,'',{''},[0.7 0.7 0.7],10);
% b) regular plot
% plot(CRW.t(:,1), nansum(CRW.N')/1e5,'b.');

li = get(h(2),'children');
set(li(1),'LineStyle','none','Marker','.','MarkerFaceColor','b','MarkerEdgeColor','b');

grid on;
set(gca,'YLim',[0 10],...
    'XLim',[t1 t2]);
ylabel('N x10^7 (m^{-3})','FontName','Times','FontSize',18) 
s = legend(li(1),'25 m','Location','NorthWest');
set(s,'FontSize',18);
datetick(gca,'keepticks','keeplimits');
set(gca,'XTickLabel',[]);

%***********************************************************************************************
% PANEL C. SSA at 1.7 / 7m (SEA ICE)
set(gcf,'CurrentAxes',h(3));
% upper (black)
yi = nansum(UP.N'); n = find(yi==0); yi(n) = NaN; % remove zeros
xi = UP.t;
y = interp1(xi,yi,CRW.t);
shadedTimeSeries(CRW.t,y./1e7,index1,'',{''},[0.7 0.7 0.7],10);

li = get(h(3),'children');
set(li(1),'LineStyle','none','Marker','.','MarkerFaceColor','k','MarkerEdgeColor','k');
hold on; grid on;

% lower (red)
yi = nansum(LOW.N'); n = find(yi==0); yi(n) = NaN; % remove zeros
% % regular plot
xi = LOW.t;
y = interp1(xi,yi,CRW.t);
plot(CRW.t,y./1e7,'r.');

set(h(3),'YAxisLocation','right', ...
    'YLim',[0 3.6],...
    'XLim',[t1 t2]);
ylabel('N x10^7 (m^{-3})',...
    'Rotation',270, ...
    'VerticalAlignment','bottom', ...
    'FontSize',18) 
xlabel('time (UTC)','FontSize',18)
li = get(h(3),'children');
s = legend(li(1:2),'1.7 m','7m','Location','NorthWest');
set(s,'FontSize',18);
datetick(gca,'keepticks','keeplimits');

%***********************************************************************************************
set(h,'FontSize',18,'FontName','Times');
set(0,'defaultaxeslinewidth',1.5); set(0,'defaultlinelinewidth',1); 
linkaxes(h,'x');



