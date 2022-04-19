% RUN_tower_NOAA
%   RUN_tower_NOAA calls f_*.m (e.g. plots data in range of days)
%   Check all parameters are set correctly in f_*.m
%
%   MF Todtnauberg, 8.03.2022

clear; close('all');
days = [datenum('1-Dec-2019 0:00:00'):datenum('3-Dec-2019 0:00:00')]'; % range of days

f_proc_tower_NOAA(days);     % 1) Read (plot) daily 1min-resolution netcdf-files in range (days) and save to *.mat

% for i = 1:size(days,1)
%     f_proc_tower_NOAA(days(i));     % 1) Read (plot) daily 10s-resolution netcdf-files and save to *.mat 
%     f_CLASP_average_MOSAiC(days(i));    % 2) Average processed data
% end

% f_CLASP_combine_MOSAiC(days);   % 3) combine daily mat-files
% f_CLASP_plot_MOSAiC(days);        % 4)plot CLASP on days