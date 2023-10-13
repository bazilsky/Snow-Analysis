% RUN_CLASP
%   RUN_CLASP loops through selected days and calls f_*.m
%   Check all parameters are set correctly in f_*.m
%
%   MF Trumpington, 31.03.2021

clear; close('all');
% days = [datenum('14-Oct-2019 0:00:00'):datenum('1-Dec-2019 0:00:00')]'; % range of days
% days = [datenum('1-Dec-2019 0:00:00'):datenum('1-Jan-2020 0:00:00')]';
% days = [datenum('1-Jan-2020 0:00:00'):datenum('1-Feb-2020 0:00:00')]';
% days = [datenum('1-Feb-2020 0:00:00'):datenum('1-Mar-2020 0:00:00')]';
% days = [datenum('1-Mar-2020 0:00:00'):datenum('1-Apr-2020 0:00:00')]';
% days = [datenum('1-Apr-2020 0:00:00'):datenum('15-May-2020 0:00:00')]';
% days = [datenum('25-Jun-2020 0:00:00'):datenum('31-Jul-2020 0:00:00')]';
days = [datenum('27-Aug-2020 0:00:00'):datenum('15-Sep-2020 0:00:00')]';

 
% days = datenum('17-Jul-2020'); % single day for plotting

% for i = 1:size(days,1)
% %     f_CLASP_proc_MOSAiC(days(i));     % 1) Process (& plot) raw data
% %     f_CLASP_average_MOSAiC(days(i));    % 2) Average processed data
% end

% f_CLASP_combine_MOSAiC(days);   % 3) combine daily mat-files
f_CLASP_plot_MOSAiC(days);        % 4)plot CLASP on days