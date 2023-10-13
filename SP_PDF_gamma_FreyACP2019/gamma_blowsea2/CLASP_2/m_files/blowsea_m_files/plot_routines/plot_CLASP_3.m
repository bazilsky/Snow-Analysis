function plot_SPC_3()
% Plot CLASP size spectra vs time (2-D contour plot)
%
% a. meteo b. CLASP-crows nest c. CLASP-seaice (7m or 1.74m)
%
% MF San Francisco, 14.12.2015


clear;                 % clear variables and
close('all');          % ...close figures
pth = '~/Documents/research/Arctic/N-ICE_2015/DATA/CLASP/data/';      % path from HERE to data
fname = sprintf('%sCLASP_crow_1min.mat',pth);
CRW = load(fname);
fname = sprintf('%sCLASP_lower_1min.mat',pth);
LOW = load(fname);
fname = sprintf('%sCLASP_upper_1min.mat',pth);
UP = load(fname);

openfig ./temp3.fig;
h = get(gcf,'children'); % get axes handles
% data subset
% t1 = datenum('3-Mar-2015'); t2 = datenum('05-Mar-2015'); % TEST
% t1 = datenum('28-Feb-2015 03:10:00'); t2 = datenum('04-Mar-2015 18:49:00'); % CASE 1
% t1 = datenum('04-Mar-2015 18:49:00'); t2 = datenum('13-Mar-2015 21:34:00'); % CASE 2
t1 = datenum('13-Mar-2015 21:34:00'); t2 = datenum('21-Mar-2015 06:03:00'); % CASE 3
% t1 = datenum('24-Feb-2015'); t2 = datenum('28-Mar-2015'); %Leg 2
% t1 = datenum('28-Feb-2015 03:10:00'); t2 = datenum('06-Mar-2015'); %

%  v = logspace(0,6,100);
v = linspace(0,1e6,100);

%***********************************************************************************************
%% PANEL A. METEO
set(gcf,'CurrentAxes',h(1));

% i) Wspd & T
h1 = plotyy(CRW.ws1_org(:,1),CRW.ws1_org(:,2),CRW.Ta1_org(:,1),CRW.Ta1_org(:,2));
set(gcf,'CurrentAxes',h1(1));
set(gca,'YLim',[0 25],'YTick',[0 10 20 30 40],'YTickLabel',[0 10 20 30 40]);
ylabel('wspd (m s^{-1})', ...
    'Rotation',90, ...
    'VerticalAlignment','bottom', ...
    'FontSize',18,'FontName','Times');

set(gcf,'CurrentAxes',h1(2));
li = get(gca,'children');
set(li,'LineWidth',2);
set(gca,'YLim',[-35 0],'YTick',[-30 -20 -10 0],'YTickLabel',[-30 -20 -10 0]);
ylabel('T_{air} (^{\circ}C)', ...
    'Rotation',270, ...
    'VerticalAlignment','bottom', ...
    'FontSize',18,'FontName','Times');

% ii) Wspd & Wdir
% h1 = plotyy(t,ws1_25m,t,wd1);
% set(gcf,'CurrentAxes',h1(1));
% set(gca,'YTick',[0 10 20 30 40],'YTickLabel',[0 10 20 30 40]);
% ylabel('wspd (m s^{-1})', ...
%     'Rotation',90, ...
%     'VerticalAlignment','bottom', ...
%     'FontSize',18,'FontName','Times');
% 
% set(gcf,'CurrentAxes',h1(2));
% set(gca,'YTick',[0 90 180 270 360],'YTickLabel',[0 90 180 270 360]);
% ylabel('wdir (\circ)', ...
%     'Rotation',270, ...
%     'VerticalAlignment','bottom', ...
%     'FontSize',18,'FontName','Times');

% iii) Wspd & RH
% h1 = plotyy(t,ws1_25m,t,RH1);
% set(gcf,'CurrentAxes',h1(1));
% set(gca,'YTick',[0 10 20 30 40],'YTickLabel',[0 10 20 30 40]);
% ylabel('wspd (m s^{-1})', ...
%     'Rotation',90, ...
%     'VerticalAlignment','bottom', ...
%     'FontSize',18,'FontName','Times');
% 
% set(gcf,'CurrentAxes',h1(2));
% set(gca,'YTick',[50 60 70 80 90 100],'YTickLabel',[50 60 70 80 90 100]);
% ylabel('RH (%)', ...
%     'Rotation',270, ...
%     'VerticalAlignment','bottom', ...
%     'FontSize',18,'FontName','Times');


set(h1, 'XLim',[t1 t2], ...
    'XGrid','on', ...
    'GridLineStyle','-');
datetick(h1(1),'keeplimits');
datetick(h1(2),'keeplimits');
set(h1,'XTickLabel',[]);

annotation(gcf,'textbox',...
    [0.160694004779899 0.823685772952851 0.041704857928506 0.0641025641025641],...
    'String',{'a.'},...
    'LineStyle','none',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off');

%***********************************************************************************************
%% PANEL B. CLASP-CROW contour plot
n = find(CRW.t(:,1)>=t1 & CRW.t(:,1)<t2);
set(gcf,'CurrentAxes',h(2)); 
[C,hc] = contourf(CRW.t(n,1),CRW.meanD,CRW.N(n,:)',v);
set(hc,'edgecolor','none');
% annotate
ylabel('D_m (\mu m)','FontSize',18,'FontName','Times');

set(h(2), 'XLim',[t1 t2], ...
        'XGrid','off','YGrid','off',...
    'GridLineStyle','-');
datetick(h(2),'keeplimits');
set(h(2),'XTickLabel',[]);

s = get(gca,'Position');
colorbar('EastOutside');
set(gca,'Position',s);

annotation(gcf,'textbox',...
    [0.165884316198584 0.638406585135592 0.041704857928506 0.0641025641025641],...
    'String',{'b.'},...
    'LineStyle','none',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off');

%***********************************************************************************************
%% PANEL C. CLASP-UPPER contour plot
% n = find(UP.t(:,1)>=t1 & UP.t(:,1)<t2);
% y = UP.N(n,:);
% set(gcf,'CurrentAxes',h(3)); 
% [C,hc] = contourf(UP.t(n,1),UP.meanD,y',v);
% 
%% PANEL C. CLASP-LOWER contour plot
n = find(LOW.t(:,1)>=t1 & LOW.t(:,1)<t2);
y = LOW.N(n,:);
set(gcf,'CurrentAxes',h(3)); 
[C,hc] = contourf(LOW.t(n,1),LOW.meanD,y',v);


% annotate
set(hc,'edgecolor','none');
ylabel('D_m (\mu m)','FontSize',18,'FontName','Times');
xlabel('UTC','FontSize',18,'FontName','Times');
% axes
set(h(3), 'XLim',[t1 t2], ...
        'XGrid','off','YGrid','off',...
    'GridLineStyle','-');
datetick(h(3),'keeplimits');

annotation(gcf,'textbox',...
    [0.165884316198584 0.327492879551836 0.041704857928506 0.0641025641025642],...
    'String','c.',...
    'LineStyle','none',...
    'FontSize',20,...
    'FontName','Times New Roman',...
    'FitBoxToText','off');

%***********************************************************************************************
H = [h;h1(2)];
set(H,'FontSize',16,'FontName','Times');
set(0,'defaultaxeslinewidth',2); set(0,'defaultlinelinewidth',1);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%SUBROUTINES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y2 = interpolieren(x1,y1,x2)
% Remove NaNs & negative values
X = [x1 y1];
X = sortrows(X,1);
n = find(isnan(X(:,2)));
X(n,:) = [];
n = find(X(:,2)<0);
X(n,:) = [];
x1 = X(:,1); y1 = X(:,2);

% y2 = interp1(x1,y1,x2,'linear');
% y2 = interp1(x1,y1,x2,'linear','extrap');
% y2 = interp1(x1,y1,x2,'nearest');
% y2 = interp1(x1,y1,x2,'nearest','extrap');

y2 = interp1(x1,y1,x2,'pchip'); %use this one (equivalent to cubic)
% y2 = interp1(x1,y1,x2,'spline'); % NOTE: erroneous results


function plot_vertline1(x)
% plot_vertline(x)
% plots vertical line at x (in a row!!) in current axes
%
% MM Frey Cambridge, 30.07.2008
% MM Frey Cambridge, 4.12.2010 (update)

y_limits = get(gca,'YLim');
X= [x;x]; Y = [ones(size(x)); ones(size(x))];
Y(1,:) = Y(1,:).*y_limits(1); Y(2,:) = Y(2,:).*y_limits(2);
hold on; line(X,Y,'Color','k','LineWidth',1,'LineStyle','--');

function plot_vertline2(x)
% plot_vertline(x)
% plots vertical line at x (in a row!!) in current axes
%
% MM Frey Cambridge, 30.07.2008
% MM Frey Cambridge, 4.12.2010 (update)

y_limits = get(gca,'YLim');
X= [x;x]; Y = [ones(size(x)); ones(size(x))];
Y(1,:) = Y(1,:).*y_limits(1); Y(2,:) = Y(2,:).*y_limits(2);
hold on; line(X,Y,'Color','k','LineWidth',2,'LineStyle','--');






