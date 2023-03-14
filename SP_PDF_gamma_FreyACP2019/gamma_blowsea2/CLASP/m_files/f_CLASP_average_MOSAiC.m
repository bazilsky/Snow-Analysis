function f_CLASP_average_MOSAiC(day)
%f_CLASP_average_MOSAiC - average CLASP 10Hz data
%   f_CLASP_average_MOSAiC(day) - average 10Hz data using f_aggregate.m
%   flag=1, e.g. [mean std N]
%   flag=2, for t-vector e.g. [mean start_of_interval end_of_interval]
%   flag=3, e.g. nansum for errorflag or particle histogram
%   flag=4, e.g. particle count histogram [sum N]
%
%   MF Trumpington, 31.03.2021

%% Parameters
% path from HERE to input/ouput
pth_in = '../data/daily_10Hz/';
pth_out = '../data/daily_1min/';
flag.plot = 0;         % 1= plot daily files / 0= do not plot

%% Load file (e.g. clasp20200101_10Hz.mat)
[yyyy mm dd] = datevec(day);
fname = sprintf('clasp%0.4d%0.2d%0.2d_10Hz.mat',yyyy,mm,dd);
if(exist([pth_in fname],'file') == 0)
    sprintf('ERROR: unable to find %s',[pth_in fname])
    return
else
    load([pth_in fname]);
    sprintf('%s',[pth_in fname])
end

% build output filename (e.g.clasp20200204_10Hz.mat)
fname_op = sprintf('%sclasp%0.4d%0.2d%0.2d_1min.mat',pth_out,yyyy,mm,dd);

%% initialize structures
status = struct('SupplyV',[],'LaserRef',[],'rejects',[],'threshold',[],...
    'ThisFlow',[],'FlowPWM',[],'PumpCurrent',[],'SensorT',[],'HousingT',[],...
    'PumpT',[],'t_status',[]);
flags = struct('flow',[],'heater',[],'sync',[],'laser',[],'flow2',[]);
CLASP_new = struct('counts',[],'status',status,'flags',flags,'filename',[],...
    't',[],'t_vec',[],'dt',[],'dt_nominal',[],'conc',[],'meanR',[],'dR',[],'calibr',[]);

%% Averaging (note: sum counts / average concentrations)
av_int = 60; % averaging interval [s];
No = floor(av_int/CLASP.dt(1)); % divide by measured mean sample intervall [s] to get No of elements
% find start time to center average on full minutes (00:01:00 for interval 00:00:31 to 00:01:30)
start = datenum([yyyy mm dd 00 00 31]);
n = find(CLASP.t>=start);
CLASP_new.counts = f_aggregate(CLASP.conc(n,:),No,4); % flag=4, e.g. particle count histogram [sum N]
CLASP_new.filename = CLASP.filename;
CLASP_new.t = f_aggregate(CLASP.t(n),No,2); % flag=2, for t-vector e.g. [mean start_of_interval end_of_interval]
CLASP_new.t_vec = [datevec(CLASP_new.t(:,1)) datevec(CLASP_new.t(:,2)) datevec(CLASP_new.t(:,3))];
CLASP_new.conc = f_aggregate(CLASP.conc(n,:),No,1); % flag=1, e.g. [mean std N]
CLASP_new.dt = CLASP.dt;
CLASP_new.dt_nominal = CLASP.dt_nominal;
CLASP_new.meanR = CLASP.meanR;
CLASP_new.dR = CLASP.dR;
CLASP_new.calibr = CLASP.calibr;
flags.flow = f_aggregate(CLASP.flags.flow(n,:),No,4); % flag=4, e.g. particle count histogram [sum N]
flags.heater = f_aggregate(CLASP.flags.heater(n,:),No,4);
flags.sync = f_aggregate(CLASP.flags.sync(n,:),No,4);

dt_status = round(nanmean(diff(CLASP.status.t_status*86400)),0);
No = floor(av_int/dt_status); % divide by measured mean sample intervall [s] to get No of elements
n = find(CLASP.status.t_status>=start);
status.SupplyV = f_aggregate(CLASP.status.SupplyV(n,:),No,1); % flag=1, e.g. [mean std N]
status.LaserRef = f_aggregate(CLASP.status.LaserRef(n,:),No,1); 
status.rejects = f_aggregate(CLASP.status.rejects(n,:),No,1); 
status.threshold = f_aggregate(CLASP.status.threshold(n,:),No,1); 
status.ThisFlow = f_aggregate(CLASP.status.ThisFlow(n,:),No,1); 
status.FlowPWM = f_aggregate(CLASP.status.FlowPWM(n,:),No,1); 
status.PumpCurrent = f_aggregate(CLASP.status.PumpCurrent(n,:),No,1);
status.SensorT = f_aggregate(CLASP.status.SensorT(n,:),No,1);
status.HousingT = f_aggregate(CLASP.status.HousingT(n,:),No,1);
status.PumpT = f_aggregate(CLASP.status.PumpT(n,:),No,1);
status.t_status = f_aggregate(CLASP.status.t_status(n,:),No,2); %  flag=2, for t-vector e.g. [mean start_of_interval end_of_interval]
flags.laser = f_aggregate(CLASP.flags.laser(n,:),No,4); % flag=4, e.g. particle count histogram [sum N]
flags.flow2 = f_aggregate(CLASP.flags.flow2(n,:),No,4);

CLASP_new.status = status;
CLASP_new.flags = flags;

%% check
if flag.plot
    figure
    plot(CLASP.t,nansum(CLASP.conc,2),'k.');
    hold on, grid on;
    plot(CLASP_new.t(:,1),nansum(CLASP_new.conc(:,1:16),2),'r-','LineWidth',2);
    datetick('x','keeplimits');
    ylabel('N (particle cm^{-3})','FontSize',14);
    xlabel('UTC','FontSize',14);
    legend('1s data','1min data');
    title(['Averaged Data on ' datestr(CLASP_new.t(1),'dd/mm/yyyy')], ...
            'FontName','Times','FontSize',14);
end

%% write to output
CLASP = CLASP_new;
save(fname_op,'CLASP','fname_op');
