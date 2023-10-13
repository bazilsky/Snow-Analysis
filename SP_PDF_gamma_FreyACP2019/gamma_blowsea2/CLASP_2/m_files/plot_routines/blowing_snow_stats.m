
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
MET = load(spc_file)
U1104 = load(spc_file)


spc_conc = nansum(U1104.N,2); % spc concentration time series
spc_time = U1104.t(:,1);
U10m = U1104.U10m;

t1 = datenum('07-Dec-2019 00:00');
t2 = datenum('11-Dec-2019 00:00');

indx = find(spc_time>t1 & spc_time<t2);

spc_conc_slice = spc_conc(indx);
spc_time_slice = spc_time(indx);


%% calculate the threshold 
T_pth = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/mosaic/newdata_with_metcity/'
fname2 = sprintf('%stower_NOAA_1min.mat',T_pth);
DATA2 = load(fname2)

rolling_mean_width = 10; % 10min average
t_noaa = movmean(DATA2.tower_NOAA.t,rolling_mean_width);
T_noaa_skin = movmean(DATA2.tower_NOAA.skin_temp_surface,rolling_mean_width);


Ut0 = 6.975;

Ut = Ut0 + 0.0033.*(T_noaa_skin+27.27).^2;
%plot(t_noaa,Ut,'r')

% this code is to make sure that the wind speed has the same size array as
% spc_time_slice
T_noaa_interp = interp1(t_noaa, T_noaa_skin, spc_time_slice, 'nearest');
Ut_interp = Ut0 + 0.0033.*(T_noaa_interp+27.27).^2;

% indx2 = 

indx2 = find(U1104.t_NOAA>t1 & U1104.t_NOAA<t2);
indx3 = find(U1104.t>t1 & U1104.t<t2);

% figure;
% diff = U1104.U10m_ex(indx2) - U1104.U10m(indx2);
% % plot(U1104.t_NOAA(indx2),U1104.U10m(indx2))
% % hold on 
% % plot(U1104.t(indx3),U1104.U10m_ex(indx3))
% 
% plot(U1104.t(indx2), diff)

% figure;
% plot(datetime(datestr(spc_time_slice)),spc_conc_slice)
% yyaxis right
% plot(datetime(datestr(spc_time_slice)),U1104.U10m(indx2),'b')
% hold on 
% plot(datetime(datestr(spc_time_slice)),Ut_interp,'r')



%{
figure;
% Set the position and size of the figure [left, bottom, width, height]
set(gcf, 'Position', [100, 100, 1200, 400]);  % Adjust the width and height values as needed

% Plotting the data on the left y-axis
plot(datetime(datestr(spc_time_slice)),spc_conc_slice);
ylabel('Snow particle concentration (/m3)','FontSize',18)
% Selecting and plotting data on the right y-axis
yyaxis right;
plot(datetime(datestr(spc_time_slice)),Ut_interp,'r');
hold on 
plot(datetime(datestr(spc_time_slice)),U1104.U10m(indx2),'b');



% Changing the color of the right y-axis to blue
ylabel('U10m (m/s)','Color','b', 'FontSize',18);
xlabel('Time','Fontsize', 18)





% startTime = datestr(spc_time_slice(1));
% endTime = datestr(spc_time_slice(end));
% 
% % Creating the title string
% titleStr = sprintf('Snow Particle Number Concentration and Velocity - %s to %s', startTime, endTime);
% 
% % Adding the title to the figure
% title(titleStr, 'FontSize', 12);



%%
% Extracting the time limits from the x-axis
% timeLimits = xlim;
startTime = datestr(t1, 'dd_mmm');
endTime = datestr(t2, 'dd_mmm');

% Parsing the day and month for start and end times
[startDay, startMonth] = strtok(startTime, '_');
[endDay, endMonth] = strtok(endTime, '_');

% Removing underscore from the month strings
startMonth = strrep(startMonth, '_', '');
endMonth = strrep(endMonth, '_', '');

% Creating the title string
titleStr = sprintf('Snow Particle Number Concentration and Velocity - %s %s to %s %s', startDay, startMonth, endDay, endMonth);
title(titleStr,'FontSize', 20);

% Creating the filename string
filenameStr = sprintf('spc_%s_%s_to_%s_%s.png', startDay, startMonth, endDay, endMonth);
filenameStr2 = sprintf('spc_%s_%s_to_%s_%s.fig', startDay, startMonth, endDay, endMonth);

% Changing the color of the right y-axis to blue
set(gca, 'YColor', 'b');
% Saving the figure to the file
% saveas(gcf, filenameStr);


saveas(gcf, strcat('/Users/ananth/Desktop/new_data/spc_time_series_plots/',filenameStr))
saveas(gcf, strcat('/Users/ananth/Desktop/new_data/spc_time_series_plots/',filenameStr2))

%}

%% new code

% Your previous code remains unchanged ...

% Set the position and size of the figure [left, bottom, width, height]
figure('Position', [100, 100, 1200, 400]);  % Adjust the width and height values as needed

% Create a datetime vector from spc_time_slice
dtVec = datetime(datestr(spc_time_slice));

% Plotting the data on the left y-axis
yyaxis left;
plot(dtVec, spc_conc_slice, 'k-', 'LineWidth', 2);
ylabel('Snow Particle Concentration (/m^3)', 'FontSize', 18, 'FontName', 'Times New Roman');
set(gca,'YColor','k')

% Selecting and plotting data on the right y-axis
yyaxis right;
plot(dtVec, Ut_interp, 'r-', 'LineWidth', 2); hold on;
plot(dtVec, U1104.U10m(indx2), 'b-', 'LineWidth', 2); hold off;

% Labeling the y-axis and changing its color to blue
ylabel('U_{10m} (m/s)', 'Color', 'b', 'FontSize', 18, 'FontName', 'Times New Roman');
set(gca, 'YColor', 'b');

% Labeling the x-axis
xlabel('Time', 'FontSize', 18, 'FontName', 'Times New Roman');

% Adjusting the datetime format for better readability
ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis(1).FontSize = 14;
ax.YAxis(2).FontSize = 14;
ax.XAxis.TickLabelFormat = 'dd-MMM';
ax.XAxis.TickLabelRotation = 45;

% Extracting the time limits from the x-axis
startTime = datestr(t1, 'dd_mmm');
endTime = datestr(t2, 'dd_mmm');

% Parsing the day and month for start and end times
[startDay, startMonth] = strtok(startTime, '_');
[endDay, endMonth] = strtok(endTime, '_');

% Removing underscore from the month strings
startMonth = strrep(startMonth, '_', '');
endMonth = strrep(endMonth, '_', '');

% Creating the title string
titleStr = sprintf('Snow Particle Number Concentration and Velocity - %s %s to %s %s', startDay, startMonth, endDay, endMonth);
title(titleStr, 'FontSize', 20, 'FontName', 'Times New Roman');

% Creating the legend
legend({'Snow Particle Concentration', 'Ut', 'U_{10m}'}, 'Location', 'northwest', 'FontSize', 14, 'FontName', 'Times New Roman');

% Creating the filename string
filenameStr = sprintf('spc_%s_%s_to_%s_%s.png', startDay, startMonth, endDay, endMonth);
filenameStr2 = sprintf('spc_%s_%s_to_%s_%s.fig', startDay, startMonth, endDay, endMonth);

% Saving the figure to the file
saveas(gcf, fullfile('/Users/ananth/Desktop/new_data/spc_time_series_plots/',filenameStr));
saveas(gcf, fullfile('/Users/ananth/Desktop/new_data/spc_time_series_plots/',filenameStr2));
%%






%{
%% read in xianda acsm_data

% 
% pth_ss = '/Users/ananth/Desktop/new_data/acsm_data/';
% ss_name = sprintf('%sACSM_to_Ananth.csv',pth_ss);
% 
% ss_data = readtable(ss_name);
% 
% so4_mass = ss_data(2,1);
% no3_mass = ss_data(2,2);
% nh4_mass = ss_data(2,3);
% org_mass = ss_data(2,4);
% 
% total_mass_main = ss_data(2,5);
% ss_time = ss_data(:,6);
% 
% slice_mass = so4_mass+no3_mass+nh4_mass+org_mass;

[ss_time_slice, seasalt_perc] = calc_ss();


% figure(2)
% ss_time_slice, seasalt_percentage = calc_ss()
% plot(ss_time_slice,seasalt_perc,'b')




%openfig ./temp3.fig;
openfig /Users/ananth/Desktop/bas_github_scripts/bas_github_scripts/SP_PDF_gamma_FreyACP2019/gamma_blowsea2/CLASP_2/data/temp3.fig

h = get(gcf,'children'); % get axes handles
t1 = datenum('02-Dec-2019 23:15'); 
t2 = datenum('09-May-2020 23:26'); %

% 
t1 = datenum('15-Mar-2020 23:15'); % this time slice was used for plot in deliverable report
t2 = datenum('31-Mar-2020 23:26'); 

t1 = datenum('02-Dec-2019 23:15'); % this time slice was used in Xianda's paper
t2 = datenum('13-Dec-2019 23:26'); 

%t1 = days(1); t2 = days(end);
n0 = find(CLASP.t(:,1)>=t1 & CLASP.t(:,1)<=t2);
n1 = find(MET.t>=t1 & MET.t<=t2);
n2 = find(U1104.t(:,1)>=t1 & U1104.t(:,1)<=t2);
%n3 = find(U1206.t(:,1)>=t1 & U1206.t(:,1)<=t2);

%%calculate the correlation
% U1104.U10m_ex(n2)
% U1104.t(n2)
% ss_time_slice
% seasalt_perc





%% PANEL A. velocity 
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

ylim([0,20])

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
plot(U1104.t(n2(idx_above_threshold),1), U1104.U10m_ex(n2(idx_above_threshold)), 'k.','MarkerSize',6);

% Plot grey line for values below threshold windspeed
idx_below_threshold = U1104.U10m_ex(n2) <= Ut_interp;
plot(U1104.t(n2(idx_below_threshold), 1), U1104.U10m_ex(n2(idx_below_threshold)), '.', 'Color', [0.5 0.5 0.5], 'MarkerSize', 6);

% new code for 2nd y axis

yyaxis right; % Switch to the second y-axis on the right
plot(datenum(ss_time_slice), seasalt_perc, 'b.','MarkerSize',14); % Plotting seasalt_perc in green for example
% ylabel('Sea salt (%)', 'FontSize', 18, 'FontName', 'Times');

% ylabel('Sea salt (%)', 'FontSize', 18, 'FontName', 'Times', 'Rotation', 270,'Position',[1.059109232964 0.729002931267316 0]);

ht = text(gca,'FontName','Times New Roman','FontSize',20,...
    'Rotation',270,...
    'String','Sea salt (%)',...
    'Units','normalized',...
    'Position',[1.059109232964 0.729002931267316 0], 'Color','blue');

ylim([min(seasalt_perc) max(seasalt_perc)]); % Adjust this as needed
ax = gca; % Get the current axes handle
ax.YAxis(2).Color = 'b'; 

legend('U_t','U_{10m} > U_t','U_{10m} < U_t','Sea Salt %','Location','northeast','Fontsize',17);



%% Panel B - snow particle concentration 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X = [U1104.t(n2) U1104.N(n2,:)];
dlogD = log10(U1104.dp_bins(:,2))-log10(U1104.dp_bins(:,1));
X(:,2:end) = X(:,2:end)./dlogD';
dNdlogD_2 = U1104.N(n2,:)./dlogD';

v = [0 10 100 1e3 1e4 1e5 1e6 1e7]; % color scheme; include zero counts

%vl = string(num2str(v, '%.1e'));
vl = ["0","10^1", "10^2", "10^3", "10^4", "10^5", "10^6", "10^7"];
%vl = ['0','10^1', '10^2', '10^3', '10^4', '10^5', '10^6', '10^7'];
y = [36 50 75 100 125 150 175 200 225 250 275 300 325 350 375 400 425 450 475 500];     % y-axis ticks at meanD
yl = {'' '50' '75' '100' '' '' '' '200' '' '' '' '300' '' '' '' '' '' '' '' '500'};     % y-axis labels
set(gcf,'CurrentAxes',h(2));

[C,hc] = contourf(X(:,1),log10(U1104.dp_bins(:,3)),log10(X(:,2:end)'),log10(v));


set(hc,'edgecolor','none');
caxis([0 log10(v(end))]); % scale colormap of this plot
s = get(gca,'Position'); % remember axis position
cb = colorbar('EastOutside');

cb.TickLabels = vl;
set(gca,'Position',s);


set(h(2), 'XLim',[t1 t2],'XGrid','off','GridLineStyle','-',...
         'YLim',log10([y(1) y(end)]),'YTick',log10(y),'YTickLabel',yl,...
         'YAxisLocation','left');


ylabel('D_p (\mu m)')

ht = text(gca,'FontName','Times New Roman','FontSize',20,...
    'Rotation',270,...
    'String','dN/dlog D_p (m^{-3})',...
    'Units','normalized',...
    'Position',[1.059109232964 0.729002931267316 0]);

% Remove xticks
set(gca,'XTickLabel',[]);
%datetick('x','mm/dd HH','keepticks','keeplimits');
%xlabel('UTC','FontSize',16,'FontName','Times');


%% PANEL C. CLASP contour plot of aerosol number concentration 

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

set(hc,'edgecolor','none');
ylabel('D_p (\mu m)','FontSize',18,'FontName','Times');
xlabel('Time','FontSize',35,'FontName','Times');
% axes
set(gca,'YLim',[CLASP.meanR(1,1)*2 10],'YScale','log','XLim',[t1 t2], ...
    'XGrid','off','YGrid','off','GridLineStyle','-');
datetick(gca,'keepticks','keeplimits');

%***********************************************************************************************
set(h,'FontSize',16,'FontName','Times');
set(0,'defaultaxeslinewidth',2); set(0,'defaultlinelinewidth',1);
ht = text(gca,'FontName','Times New Roman','FontSize',20,...
    'Rotation',270,...
    'String','dN/dlog D_p (cm^{-3})',...
    'Units','normalized',...
    'Position',[1.059109232964 0.729002931267316 0]);


% Interpolate using the 'nearest' method
corresponding_U10m_ex = interp1(U1104.t(n2), U1104.U10m_ex(n2), datenum(ss_time_slice), 'nearest');
nearest_U1104_time = interp1(U1104.t(n2), U1104.t(n2), datenum(ss_time_slice), 'nearest');


path_to_save = '/Users/ananth/Desktop/new_data/new_plots/fig1.png'

saveas(gcf,path_to_save)



% figure(2)
% % plot(nearest_U1104_%time,datenum(ss_time_slice),'b.','MarkerSize',13)
% plot(corresponding_U10m_ex,seasalt_perc)
% % R_val = corrcoef(corresponding_U10m_ex,seasalt_perc);

% Find indices where neither value is NaN
valid_indices = ~isnan(corresponding_U10m_ex) & ~isnan(seasalt_perc);

% Filter the arrays
filtered_U10m_ex = corresponding_U10m_ex(valid_indices);
filtered_seasalt_perc = seasalt_perc(valid_indices);

% Now compute the correlation coefficient
R_val = corrcoef(filtered_U10m_ex, filtered_seasalt_perc);


%%%%%% new panel C


function [ss_time_slice, seasalt_percentage] = calc_ss()
    pth_ss = '/Users/ananth/Desktop/new_data/acsm_data/';
    ss_name = sprintf('%sACSM_to_Ananth.csv', pth_ss);
    
    ss_data = readtable(ss_name);
    
    so4_mass = ss_data{2:end,1};  % Use curly braces to extract values
    no3_mass = ss_data{2:end,2};  % Use curly braces to extract values
    nh4_mass = ss_data{2:end,3};  % Use curly braces to extract values
    org_mass = ss_data{2:end,4};  % Use curly braces to extract values
    
    total_mass_main = ss_data{2:end,5};  % Use curly braces to extract values
    ss_time = ss_data{2:end,6};  % Use curly braces to extract values
    
    slice_mass = so4_mass + no3_mass + nh4_mass + org_mass;
    
    t1 = datetime('02-Dec-2019 00:00');
    t2 = datetime('13-Dec-2019 00:00');
    
    t_filter = find(ss_time>t1 & ss_time<t2);
    
    ss_time_slice = ss_time(t_filter);
    total_mass_main_slice = total_mass_main(t_filter);
    slice_mass_slice = slice_mass(t_filter);
    
    % plot(ss_time_slice,total_mass_main_slice,'r')
    % hold on
    % plot(ss_time_slice, slice_mass_slice,'b')
    
    % Remove NaN, negative, and zero values before calculating seasalt_frac
    valid_indices = ~isnan(total_mass_main_slice) & ~isnan(slice_mass_slice) & ...
                    total_mass_main_slice > 0 & slice_mass_slice >= 0 & total_mass_main_slice>slice_mass_slice;
    % 
    ss_time_slice = ss_time_slice(valid_indices);
    total_mass_main_slice = total_mass_main_slice(valid_indices);
    slice_mass_slice = slice_mass_slice(valid_indices);
    
    
    seasalt_frac = (total_mass_main_slice - slice_mass_slice)./(total_mass_main_slice)*100;

    seasalt_percentage = seasalt_frac;
end


%%calculate the correlation
% U1104.U10m_ex(n2)
% U1104.t(n2)
% 
% 
% ss_time_slice
% seasalt_perc

%}



