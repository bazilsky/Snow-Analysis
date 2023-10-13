
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


% Initialize a new array to hold the condition values
conditionArray = zeros(size(drift_dens_slice));

% Set values based on your condition
conditionArray(drift_dens_slice > 1e-5) = 1;
conditionArray(drift_dens_slice < 1e-5) = -1;


%% 
% Create the main figure and adjust its size
figure('Position', [100, 100, 1400, 600]);

% Create a datetime vector from spc_time_slice
dtVec = datetime(datestr(spc_time_slice));

% --- Explicitly create axes for Snow Particle Concentration, Ut, and U10m ---
ax1 = axes('Position', [0.13 0.51 0.775 0.38]);

% Plotting the data for Snow Particle Concentration
h1 = plot(dtVec, spc_conc_slice, 'k-', 'LineWidth', 1.5); hold on;
ylabel('Snow Particle Concentration (m^{-3})');

% Plotting data for Ut on the right y-axis
yyaxis right;
h2 = plot(dtVec, Ut_interp, 'r-', 'LineWidth', 1.5);
h3 = plot(dtVec, U1104.U10m(indx2), 'b-.', 'LineWidth', 1.5);
ylabel('U_{10m} (m/s)');
box on;
grid on;
% title('Snow Particle Concentration (m^{-3}, U_10m(m s^{-1}), U_t(m s^(-1)), Drift Density (\mu) (kg m^{-3}))', 'FontSize',18);

legend([h1, h2, h3], {'Snow Particle Concentration', 'Ut', 'U_{10m}'}, 'Location', 'northwest', 'FontSize', 14);

% --- Explicitly create axes for Drift Density Condition ---
ax2 = axes('Position', [0.13 0.13 0.775 0.38]);

% % Plotting drift density condition
% h4 = stairs(dtVec, conditionArray, 'm-', 'LineWidth', 1.5); 
% ylabel('Drift Density Condition');
% ylim([-1.5, 1.5]);
% set(gca, 'YTick', [-1, 1], 'YTickLabel', {'< 10^{-5}', '> 10^{-5}'});
% xlabel('Time');

% Plotting drift density time series
h4 = plot(ax2, dtVec, drift_dens_slice, 'm-', 'LineWidth', 1.5); hold on;

% Overlay the threshold line
h5 = line(ax2, [min(dtVec) max(dtVec)], [1e-5, 1e-5], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5); hold off;
ylabel('Drift Density');
xlabel('Time');


% Adjust the subplot appearance
%box on;
%grid on;

% Ensure both subplots share the same x-axis limits
linkaxes([ax1, ax2], 'x');

% Adjust the x-axis format for better readability
ax2.XAxis.FontSize = 14;
ax2.YAxis.FontSize = 14;
ax2.XAxis.TickLabelFormat = 'dd-MMM-yyyy';
ax2.XAxis.TickLabelRotation = 30;
set(ax2,'YScale','log')
legend(ax2, [h4, h5], {'Drift Density (\mu)', '\mu = 10^{-5}'}, 'Location', 'northwest', 'FontSize', 14);

set(ax1, 'XTickLabel', {}); 

% Extracting the time limits from the x-axis for title
startTime = datestr(t1, 'dd_mmm');
endTime = datestr(t2, 'dd_mmm');
[startDay, startMonth] = strtok(startTime, '_');
[endDay, endMonth] = strtok(endTime, '_');
startMonth = strrep(startMonth, '_', '');
endMonth = strrep(endMonth, '_', '');

% Add main title for the entire figure
sgtitle(sprintf('Snow Particle Number Concentration and Velocity - %s %s to %s %s', startDay, startMonth, endDay, endMonth), 'FontSize', 20);
sgtitle(sprintf('Snow Particle Number Concentration, Wind Velocity and Drift Density - %s %s to %s %s', startDay, startMonth, endDay, endMonth), 'FontSize', 20);
%sgtitle(sprintf('Snow Particle Concentration (m^{-3}, U_10m(m s^{-1}), U_t(m s^(-1)), Drift Density (\mu) (kg m^{-3})) - %s %s to %s %s', startDay, startMonth, endDay, endMonth), 'FontSize', 20);



% Saving the figure to the file
filenameStr = sprintf('spc_%s_%s_to_%s_%s.png', startDay, startMonth, endDay, endMonth);
filenameStr2 = sprintf('spc_%s_%s_to_%s_%s.fig', startDay, startMonth, endDay, endMonth);
saveas(gcf, fullfile('/Users/ananth/Desktop/new_data/spc_time_series_plots/',filenameStr));
saveas(gcf, fullfile('/Users/ananth/Desktop/new_data/spc_time_series_plots/',filenameStr2));



%% 
% 
% 
% % Increase the width of the figure to better accommodate the y-axes
% figure('Position', [100, 100, 1800, 450]);
% 
% % Create a datetime vector from spc_time_slice
% dtVec = datetime(datestr(spc_time_slice));
% 
% % Plotting the data on the left y-axis
% yyaxis left;
% h1 = plot(dtVec, spc_conc_slice, 'k-', 'LineWidth', 1.5);
% ylabel('Snow Particle Concentration (/m^3)');
% set(gca,'YColor','k')
% 
% % Plotting data on the first right y-axis
% yyaxis right;
% h2 = plot(dtVec, Ut_interp, 'r-', 'LineWidth', 1.5); hold on;
% h3 = plot(dtVec, U1104.U10m(indx2), 'b-.', 'LineWidth', 1.5); hold off;  % changed to dashed line for distinction
% 
% % Labeling the first right y-axis
% ylabel('U_{10m} (m/s)');
% set(gca, 'YColor', 'b');
% %
% % Labeling the x-axis
% xlabel('Time');
% 
% % Adjusting the datetime format for better readability
% ax1 = gca;
% ax1.XAxis.FontSize = 14;
% ax1.YAxis(1).FontSize = 14;
% ax1.YAxis(2).FontSize = 14;
% ax1.XAxis.TickLabelFormat = 'dd-MMM-yyyy';  % Added year for clarity
% ax1.XAxis.TickLabelRotation = 45;
% 
% % Create a new axis for drift density condition, pushing it further to the right
% ax2 = axes('Position', [ax1.Position(1) + ax1.Position(3) + 0.02, ax1.Position(2), 0.1, ax1.Position(4)], 'YAxisLocation', 'right', 'Color', 'none', 'XColor', 'none');
% set(ax2, 'YColor', 'm', 'YTick', [-1, 1], 'YTickLabel', {'< 10^{-5}', '> 10^{-5}'});
% 
% % Adjust the y-limits and plot the drift density condition
% ylim(ax2, [-1.5, 1.5]);
% h4 = stairs(ax2, dtVec, conditionArray, 'm-', 'LineWidth', 1.5);
% ylabel(ax2, 'Drift Density Condition');
% 
% 
% % Extracting the time limits from the x-axis
% startTime = datestr(t1, 'dd_mmm');
% endTime = datestr(t2, 'dd_mmm');
% 
% % Parsing the day and month for start and end times
% [startDay, startMonth] = strtok(startTime, '_');
% [endDay, endMonth] = strtok(endTime, '_');
% 
% % Removing underscore from the month strings
% startMonth = strrep(startMonth, '_', '');
% endMonth = strrep(endMonth, '_', '');
% 
% % Creating the title string
% titleStr = sprintf('Snow Particle Number Concentration and Velocity - %s %s to %s %s', startDay, startMonth, endDay, endMonth);
% title(titleStr, 'FontSize', 20, 'FontName', 'Times New Roman');
% 
% % Creating the legend
% axes(ax1);  % Set focus back to the first right y-axis
% legend([h1, h2, h3, h4], {'Snow Particle Concentration', 'Ut', 'U_{10m}', 'Drift Density Condition'}, 'Location', 'northwest', 'FontSize', 14, 'FontName', 'Times New Roman');
% 
% % Creating the filename string
% filenameStr = sprintf('spc_%s_%s_to_%s_%s.png', startDay, startMonth, endDay, endMonth);
% filenameStr2 = sprintf('spc_%s_%s_to_%s_%s.fig', startDay, startMonth, endDay, endMonth);
% 
% % Saving the figure to the file
% saveas(gcf, fullfile('/Users/ananth/Desktop/new_data/spc_time_series_plots/',filenameStr));
% saveas(gcf, fullfile('/Users/ananth/Desktop/new_data/spc_time_series_plots/',filenameStr2));
% 
% 
