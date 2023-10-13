
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

%reading in the drift density 
drift_dens = nansum(U1104.mu,2)


%event 1 - dec
t1 = datenum('07-Dec-2019 00:00');t2 = datenum('11-Dec-2019 00:00');

%event 2 - dec
t1 = datenum('16-Dec-2019 00:00');t2 = datenum('19-Dec-2019 00:00');

%event 3 - jan
t1 = datenum('01-Jan-2020 00:00');t2 = datenum('5-Jan-2020 00:00');

%event 4 - Jan
t1 = datenum('16-Jan-2020 12:00');t2 = datenum('18-Jan-2020 00:00');

%event 5 - Feb 
t1 = datenum('02-Feb-2020 00:00');t2 = datenum('05-Feb-2020 00:00');

indx = find(spc_time>t1 & spc_time<t2);

spc_conc_slice = spc_conc(indx);
spc_time_slice = spc_time(indx);
drift_dens_slice = drift_dens(indx);


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

indx2 = find(U1104.t_NOAA>t1 & U1104.t_NOAA<t2);
indx3 = find(U1104.t>t1 & U1104.t<t2);

%% new code

% Set the position and size of the figure [left, bottom, width, height]
figure('Position', [100, 100, 1200, 400]);  % Adjust the width and height values as needed

% Create a datetime vector from spc_time_slice
dtVec = datetime(datestr(spc_time_slice));

% Plotting the data on the left y-axis
yyaxis left;
h1 = plot(dtVec, spc_conc_slice, 'k-', 'LineWidth', 2);
ylabel('Snow Particle Concentration (/m^3)', 'FontSize', 18, 'FontName', 'Times New Roman');
set(gca,'YColor','k')

% Selecting and plotting data on the right y-axis
yyaxis right;
ax1 = gca;
h2 = plot(dtVec, Ut_interp, 'r-', 'LineWidth', 2); hold on;
h3 = plot(dtVec, U1104.U10m(indx2), 'b-', 'LineWidth', 2); hold off;

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

%%
% Initialize a new array to hold the condition values
conditionArray = zeros(size(drift_dens_slice));

% Set values based on your condition
conditionArray(drift_dens_slice > 1e-5) = 1;
conditionArray(drift_dens_slice < 1e-5) = -1;

ax2 = axes('Position', get(gca, 'Position'), 'YAxisLocation', 'right', 'Color', 'none', 'XColor', 'none');
set(ax2, 'YColor', 'm', 'YTick', [-1, 1], 'YTickLabel', {'< 10^{-5}', '> 10^{-5}'});
set(ax2,'Position',get(ax2,'Position')+[0.12 0 0 0]); % Offset the second right y-axis

% Plot the conditionArray using stairs function for a step plot
h4 = stairs(ax2, dtVec, conditionArray, 'm-', 'LineWidth', 2);
ylabel(ax2, 'Drift Density Condition', 'Color', 'm', 'FontSize', 18, 'FontName', 'Times New Roman');



%%

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
%legend({'Snow Particle Concentration', 'Ut', 'U_{10m}'}, 'Location', 'northwest', 'FontSize', 14, 'FontName', 'Times New Roman');
axes(ax1);  % Set focus back to the first right y-axis
% legend({'Snow Particle Concentration', 'Ut', 'U_{10m}'}, 'Location', 'northwest', 'FontSize', 14, 'FontName', 'Times New Roman');
legend([h1, h2, h3, h4], {'Snow Particle Concentration', 'Ut', 'U_{10m}', 'Drift Density Condition'}, 'Location', 'northwest', 'FontSize', 14, 'FontName', 'Times New Roman');


% ... rest of your code for title and saving the figure ...



% Creating the filename string
filenameStr = sprintf('spc_%s_%s_to_%s_%s.png', startDay, startMonth, endDay, endMonth);
filenameStr2 = sprintf('spc_%s_%s_to_%s_%s.fig', startDay, startMonth, endDay, endMonth);

% Saving the figure to the file
saveas(gcf, fullfile('/Users/ananth/Desktop/new_data/spc_time_series_plots/',filenameStr));
saveas(gcf, fullfile('/Users/ananth/Desktop/new_data/spc_time_series_plots/',filenameStr2));
%%



