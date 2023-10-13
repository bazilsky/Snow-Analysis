function f_CLASP_proc_MOSAiC(day)
%f_CLASP_proc_MOSAiC - Read, preprocess & plot CLASP 10Hz data
%   f_CLASP_proc_MOSAiC(day) - pass day to process to function
%
%   N = h * SR * Q-1
%
%   N, particle number density (particle cm-3)
%   h, particle count histogram (-)
%   SR, sample rate (s-1)
%   Q, pump flow rate at STP (cm3 s-1)
%
%   NOTE: Matlab Variable histogram = h * SR (particle s-1 or particle min-1)
%
%
%   MF Polarstern, 22.03.2020
%   MF Trumpington, 28.03.2021

%% Parameters
% Day to process
% day = datenum('10-May-2020');
[yyyy mm dd] = datevec(day);
JDAY = day-datenum([yyyy 0 0 0 0 0]); % takes care of leap years

% path from HERE to input/ouput
%pth_in = '../data/CLASP02m/';
pth_in = '../data/temp/';
% pth_in = '/Volumes/Backup Plus/DATA BACKUP/CLASP02m/';
pth_out = '../data/daily_10Hz/';
% Load CLASP calibration file (UnitP - MetCity Tower) 
load('./CLASP-cals/calibration_CLASP_P_Apr2019.mat');   % calibration file for Unit P (deployed on MetCity tower at 2m)
% Flags
flag.proc = 1;         % 1= read raw data / 0= load calibrated data
flag.plot = 1;         % 1= plot daily files / 0= do not plot

%% Read CLASP data files
% find all files on JDAY in directory (e.g. JDAY=35 ../data/CLASP02m/msc020035*_raw.txt)
YYY = num2str(yyyy);
YYY = YYY(2:4);
DDD = num2str(JDAY);
switch length(DDD)
    case 1
        DDD = ['00' DDD];
    case 2
        DDD = ['0' DDD];
end
str_search = sprintf('%smsc%s%s*',pth_in,YYY,DDD);
dr = dir(str_search);
% build output filename (e.g.clasp20200204_10Hz.mat)
fname_op = sprintf('%sclasp%0.4d%0.2d%0.2d_10Hz.mat',pth_out,yyyy,mm,dd);

if flag.proc
    % initialize structures
    status = struct('SupplyV',[],'LaserRef',[],'rejects',[],'threshold',[],...
        'ThisFlow',[],'FlowPWM',[],'PumpCurrent',[],'SensorT',[],'HousingT',[],...
        'PumpT',[],'t_status',[]);
    flags1 = struct('flow',[],'heater',[],'sync',[]);
    flags2 = struct('flow',[],'heater',[],'sync',[],'laser',[],'flow2',[]);
    CLASPraw = struct('counts',[],'status',status,'flags',flags1,'filename',[],'t',[],...
        't_vec',[],'dt',[],'dt_nominal',[]);
    CLASPcalibrated = struct('counts',[],'status',status,'flags',flags2,'filename',[],...
        't',[],'t_vec',[],'dt',[],'dt_nominal',[],'conc',[],'meanR',[],'dR',[]);
    % read raw data & calibrate
    for i = 1:size(dr,1)
        fname = [pth_in dr(i).name];
        if(exist(fname,'file') == 0)
            sprintf('ERROR: unable to find %s',fname)
            return
        else
            sprintf('%s',fname)
        end
        CLASPraw_i = f_CLASP_read_MOSAiC(pth_in,dr(i).name); % call read function
        CLASPcalibrated_i = f_CLASP_apply_cal_MOSAiC(CLASPraw_i,calibr); % call calib function
        % append new data to structures using dynamic fieldnames
        f = fieldnames(CLASPraw);
        for k=1:numel(f)
            CLASPraw.(f{k}) = [CLASPraw.(f{k});CLASPraw_i.(f{k})];
        end
        f = fieldnames(CLASPcalibrated);
        for k=1:numel(f)
            CLASPcalibrated.(f{k}) = [CLASPcalibrated.(f{k});CLASPcalibrated_i.(f{k})];
        end
    end
     % concatenate CLASPcalibrated arrays in fields 'status' and 'flags' for plotting
    status_new = struct('SupplyV',[],'LaserRef',[],'rejects',[],'threshold',[],...
    'ThisFlow',[],'FlowPWM',[],'PumpCurrent',[],'SensorT',[],'HousingT',[],...
    'PumpT',[],'t_status',[]);
    f = fieldnames(CLASPcalibrated.status); % 11 fields in status
    for k=1:numel(f)
         dummy = [];
         for l=1:length({CLASPcalibrated.status.(f{k})})
             dummy = [dummy;CLASPcalibrated.status(l).(f{k})];
         end
         status_new.(f{k}) = dummy;
    end
    CLASPcalibrated.status = status_new;

    flags_new = struct('flow',[],'heater',[],'sync',[],'laser',[],'flow2',[]);
    f = fieldnames(CLASPcalibrated.flags); % 5 fields in flags
    for k=1:numel(f)
         dummy = [];
         for l=1:length({CLASPcalibrated.flags.(f{k})})
             dummy = [dummy;CLASPcalibrated.flags(l).(f{k})];
         end
         flags_new.(f{k}) = dummy;
    end
    CLASPcalibrated.flags = flags_new;
    
    % add calfile used to structure
    CLASPcalibrated.calibr = calibr;

    % write to output
    CLASP = CLASPcalibrated;
    save(fname_op,'CLASP','fname_op');
end

%% plots
if flag.plot
    load(fname_op);
    
    % Plot figures: pos [left bottom width height]
    bdwidth = 1;
    topbdwidth = 0;
    set(0,'Units','pixels')
    scnsize = get(0,'ScreenSize');
    pos1  = [bdwidth,...
     2/3*scnsize(4) + bdwidth,...
     scnsize(3)/3 - 2*bdwidth,...
     scnsize(4)/3 - (topbdwidth + bdwidth)];
    pos2 = [pos1(1) + scnsize(3)/3,...
     pos1(2),...
     pos1(3),...
     pos1(4)];
    pos3 = [pos1(1) + scnsize(3)*2/3,...
     pos1(2),...
     pos1(3),...
     pos1(4)];
    pos4 = [pos1(1),...
     1/6*scnsize(4),...
     pos1(3),...
     pos1(4)];
    pos5 = [pos1(1)+ scnsize(3)/3,...
     pos4(2),...
     pos1(3),...
     pos1(4)];
    pos6 = [pos1(1)+ scnsize(3)*2/3,...
     pos4(2),...
     pos1(3),...
     pos1(4)];

    % FIG1 - mean daily N spectrum [cm^-3]
    figure('Position',pos1); 
    for i = 1:16
        dNdR(i,:) = CLASP.conc(i,:)./CLASP.dR(1,:); % divide by bin width in micrometer
    end
    meanD = CLASP.meanR(1,:).*2;
    loglog(meanD,nanmean(dNdR),'ob-');
%     plot(meanD,log10(nanmean(dNdR)),'ob-');
    hold on; grid on;
    set(gca,'XLim',[1e-1 1e1],'FontSize',14,'FontName','Times');
    xlabel('mean diameter (\mum)');
    ylabel('dN/dR (cm^{-3} \mum^{-1})')
    title(['Mean Spectrum at 2m on ' datestr(CLASP.t(1),'dd/mm/yyyy')], ...
        'FontName','Times','FontSize',14);

    % FIG2 - total N [cm^-3]
    figure('Position',pos2); 
    plot(CLASP.t,nansum(CLASP.conc,2),'.');
    hold on; grid on;
    datetick('x','keeplimits');
    set(gca,'FontSize',14,'FontName','Times');
    xlabel('UTC')
    ylabel('N, (cm^{-3})')
    title(['Total N at 2m on ' datestr(CLASP.t(1),'dd/mm/yyyy')], ...
        'FontName','Times','FontSize',14);

    % FIG3 - PumpT, SensorT, HousingT & SupplyV
    figure('Position',pos3); 
    subplot(1,2,1)
    plot(CLASP.status.t_status,CLASP.status.PumpT,'k-');
    hold on; grid on;
    plot(CLASP.status.t_status,CLASP.status.SensorT,'b-');
    plot(CLASP.status.t_status,CLASP.status.HousingT,'r-');
    legend('Pump','Sens','Hous');
    datetick('x','keeplimits');
    title('Temperature');
    subplot(1,2,2)
    plot(CLASP.status.t_status,CLASP.status.SupplyV);
    hold on; grid on;
    datetick('x','keeplimits');
    title('Supply Voltage');

    % FIG4 - LaserRef & Rejects
    figure('Position',pos4); 
    subplot(1,2,1)
    plot(CLASP.status.t_status,CLASP.status.LaserRef);
    hold on; grid on;
    datetick('x','keeplimits');
    title('LaserRef');
    subplot(1,2,2)
    plot(CLASP.status.t_status,CLASP.status.rejects);
    hold on; grid on;
    datetick('x','keeplimits');
    title('Rejects');
    
    % FIG5 - threshold & ThisFlow
    figure('Position',pos5); 
    subplot(1,2,1)
    plot(CLASP.status.t_status,CLASP.status.threshold);
    hold on; grid on;
    datetick('x','keeplimits');
    title('Threshold');
    subplot(1,2,2)
    plot(CLASP.status.t_status,CLASP.status.ThisFlow);
    hold on; grid on;
    datetick('x','keeplimits');
    title('ThisFlow');
    
    % FIG6 - FlowPWM & PumpCurrent
    figure('Position',pos6); 
    subplot(1,2,1)
    plot(CLASP.status.t_status,CLASP.status.FlowPWM);
    title('FlowPWM');
    hold on; grid on;
    datetick('x','keeplimits');
    subplot(1,2,2)
    plot(CLASP.status.t_status,CLASP.status.PumpCurrent);
    hold on; grid on;
    datetick('x','keeplimits');
    title('PumpCurrent');
end

% clear; clc;