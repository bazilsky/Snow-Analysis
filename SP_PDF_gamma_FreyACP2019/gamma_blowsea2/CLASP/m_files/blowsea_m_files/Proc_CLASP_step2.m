% Proc_CLASP_step2
%
% QC & convert again to N (../all_1s_raw) to (../all_1s)
%
% (A) Convert to particle number density (particle m-3), i.e. apply flow correction 
        % flow correction with 1hr-running average of pump flowrate; flag/do not use
        % if flow out of calibration range; final units of N, particle number density 
        % (particle m-3)
% (B) pollution filter (Crows Nest only)
%
% run separately:
% (C) compute 1-min data (NOTE: SUM of histogram, but MEAN of N)
% 
%
        % N = h * SR * Q-1
        % 
        % N, particle number density (particle m-3)
        % h, particle count histogram (-)
        % SR, sample rate (s-1)
        % Q, pump flow rate at STP (m3 s-1)
        % 
        % NOTE: Matlab Variable histogram = h * SR (particle s-1 or particle min-1) of raw data
% 
% MF Polarstern, 24/07/2013
% UPDATES:
% MF Cambridge, 7/02/2014
% MF Cambridge, 9/02/2014
%
%
%*************************************************************************************
clear;                           
close all;                       
% Open raw 1-s files (../all_1s_raw)
pth = '~/Documents/research/Arctic/N-ICE_2015/DATA/CLASP/data/all_1s_raw/';
fname = sprintf('%sCLASP_lower2_1s_raw.mat',pth);
load(fname);
Hz = 10;

%% (A) Convert to particle number density (particle m-3), i.e. apply flow correction 
% interp NaNs of 10s record of ThisFLow & calc 1hr rmean
dummy = [t status_parameter.ThisFlow];
n = find(isnan(dummy(:,2)));
dummy(n,:) = [];
real_flow = interp1(dummy(:,1),dummy(:,2),t);
real_flow_rm = nanmoving_average(real_flow,1800); %half window width: 1800 s

% Creat flag data where 1hr rmean of pump flow rates out of calibration
% range (during start up and/or mal functioning of instrument) as this will
% lead to erroneous N values (note: flags.flow is too rigorous (e.g. 2355+-5))
lim = [min(calibr.realflow) max(calibr.realflow)];
id_badflow = find(real_flow_rm<lim(1) | real_flow_rm>lim(2));
real_flow_rm(id_badflow) = NaN; % if average flow out of range, N not computed
flags.badflow = zeros(length(t),1); % create flag
flags.badflow(id_badflow) = 1;

% calculate
[P,S,MU] = polyfit(calibr.realflow,calibr.TSIflow,3); % scaling & centering of x-values: same P, but suppresses alert message
flow = polyval(P,real_flow_rm,[],MU); % flow rate at STP (L min-1)
flow_correction = ((flow/60)/1000)/Hz; % flow rate at STP (m3 s-1) / sample rate (s-1) or Q/SR
flow_correction = repmat(flow_correction,1,16);
N = histogram./flow_correction; % N = h * SR * Q-1, (particle m-3)
flow_correction = flow_correction(:,1);
% 
% % check flowrate filter
figure
subplot(2,1,1)
plot(t,status_parameter.ThisFlow,'k-')
hold on; grid on;
plot(t,real_flow_rm,'b-');
h1 = gca;
set(gca,'YLim',[1500 3500]);
title('Flowrate Filter');
datetick;
ylabel('ThisFlow');
legend('raw','1hr-rmean');
xlabel('UTC');

subplot(2,1,2)
plot(t,nansum(histogram')','k.');
h2 = gca;
hold on; grid on;
n = find(flags.badflow==0);
plot(t(n),nansum(histogram(n,:)')','r-');
datetick;
title('Flowrate Filter');
linkaxes([h1 h2],'x');
legend('raw','filtered');
ylabel('histogram');
xlabel('UTC');
% 
% % %% (B) pollution filter (Crows Nest only)
% % % remove N values inside the wind sector 135-225
% % wdir_rel = interp1(AWS.t, AWS.wdir_rel,t); %interpolate 1min ShipData to time stamp
% % n = find(wdir_rel>=135 & wdir_rel<=225);
% % N_uncorr = N;
% % N(n,:) = NaN;
% % % check pollution filter
% % figure
% % plot(t,nansum(N_uncorr')','k.');
% % hold on; grid on;
% % plot(t,nansum(N')','r-');
% % datetick;
% % title('Pollution Filter: 135-225\circ Wind Sector');
% % legend('raw','filtered');
% % xlabel('UTC');
% 
clear AWS P S dummy n MU N_uncorr real_flow flow_correction h1 h2;

%% (C) compute 1-min data (NOTE: SUM of histogram, but MEAN of N)
% aggregate.m
%   flag=1, e.g. [mean std N]
%   flag=2, for t-vector e.g. [mean start_of_interval end_of_interval]
%   flag=3, e.g. nansum for errorflag or particle histogram

n = 600; % averaging interval; 600 or 10Hz / 60 for 1 Hz
t_old = t; % keep old time stamp for plotting
t = aggregate(t,n,2); %   flag=2, for t-vector e.g. [mean start_of_interval end_of_interval]
% initialize arrays
N_new = nan(length(t),16);
N_std = nan(length(t),16);
histogram_new = nan(length(t),16);
flags_new.flow = nan(length(t),1);
flags_new.heater = nan(length(t),1);
flags_new.sync = nan(length(t),1);
flags_new.badflow = nan(length(t),1);
status_parameter_new.PumpT = nan(length(t),1);
status_parameter_new.SupplyV = nan(length(t),1);
status_parameter_new.LaserRef = nan(length(t),1);
status_parameter_new.rejects = nan(length(t),1);
status_parameter_new.threshold = nan(length(t),1);
status_parameter_new.ThisFlow = nan(length(t),1);
status_parameter_new.FlowPWM = nan(length(t),1);
status_parameter_new.PumpCurrent = nan(length(t),1);
status_parameter_new.SensorT = nan(length(t),1);
status_parameter_new.HousingT = nan(length(t),1);
flow_new = nan(length(t),16);


[r c] = size(N);
for i = 1:c
    dummy = aggregate(N(:,i),n,1); %   flag=1, e.g. [mean std N]
    N_new(:,i) = dummy(:,1);
    N_std(:,i) = dummy(:,2);
    histogram_new(:,i) = aggregate(histogram(:,i),n,3); %   flag=3, e.g. nansum for errorflag or particle histogram
%     flags_new.flow = aggregate(flags.flow,n,3); 
%     flags_new.heater = aggregate(flags.heater,n,3);
%     flags_new.sync = aggregate(flags.sync,n,3);
%     flags_new.badflow = aggregate(flags.badflow,n,3);
%     status_parameter_new.PumpT = aggregate(status_parameter.PumpT,n,1); %   flag=1, e.g. [mean std N]
%     status_parameter_new.SupplyV = aggregate(status_parameter.SupplyV,n,1);
%     status_parameter_new.LaserRef = aggregate(status_parameter.LaserRef,n,1);
%     status_parameter_new.rejects = aggregate(status_parameter.rejects,n,1);
%     status_parameter_new.threshold = aggregate(status_parameter.threshold,n,1);
%     status_parameter_new.ThisFlow = aggregate(status_parameter.ThisFlow,n,1);
%     status_parameter_new.FlowPWM = aggregate(status_parameter.FlowPWM,n,1);
%     status_parameter_new.PumpCurrent = aggregate(status_parameter.PumpCurrent,n,1);
%     status_parameter_new.SensorT = aggregate(status_parameter.SensorT,n,1);
%     status_parameter_new.HousingT = aggregate(status_parameter.HousingT,n,1);
    flow_new = aggregate(flow,n,1);
end

% check
figure
plot(t_old,nansum(N')','k.');
hold on, grid on;
plot(t(:,1),nansum(N_new')','r-');
datetick('x','keeplimits');
ylabel('N (particle m^{-3})','FontSize',14);
xlabel('UTC','FontSize',14);
legend('1s data','1min data');

% clean up
N = N_new;
histogram = histogram_new;
flags = flags_new;
status_parameter = status_parameter_new;
flow = flow_new;
clear *_new t_old r c i ans dummy h1 h2 wdir_rel id_badflow Hz lim real_flow_rm;




