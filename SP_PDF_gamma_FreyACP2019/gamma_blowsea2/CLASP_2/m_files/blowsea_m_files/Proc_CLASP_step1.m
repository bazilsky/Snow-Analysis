% Proc_CLASP_step1

% Read, preprocess & plot daily CLASP output at 1s resolution
% saved in ./all_1s_raw
% (Based on S. Norris function)
% 
% N = h * SR * Q-1
% 
% N, particle number density (particle cm-3)
% h, particle count histogram (-)
% SR, sample rate (s-1)
% Q, pump flow rate at STP (cm3 s-1)
% 
% NOTE: Matlab Variable histogram = h * SR (particle s-1 or particle min-1)
%
%
% MF Polarstern, 29.06.2013
% MF Cambridge, 9/11/2013
% UPDATE: MF Cambridge, 6/02/2014
%   - readout also time stamps for all status parameters
%   - scale x-values before 3rd degree polynomial fit (no difference)
% UPDATE: MF Lance 26/02/2015
% MF Dec-2015
%
%
% S.Norris: this function gives a very quick look see to the CLASP data from blowsea
% project. The data is corrected for any overflows, and converted to
% concentrations per cc per second. Two plots are then created; one to look at the
% mean spectra for the data file and the second to look at the total number 
% concentration of aerosol time series.

%% Parameters
clear;                 
close('all');          
% load correct calibration file of CLASP unit used
pth0 = '../documents/configfiles_Jan15/';   % path from HERE to directory w/ config files
% fname = sprintf('%sUnitK.mat',pth0); % calibration file for Unit K (23.2.2015 15:00 - 4.3.15 22:00 on Lance Crow's Nest)
% fname = sprintf('%sUnitE.mat',pth0); % calibration file for Unit E (4.3.15 22:10 - 21.3.2015 15:00 on Lance Crow's Nest)
% fname = sprintf('%sUnitM.mat',pth0); % calibration file for Unit M (21.3.15 15:00 on Lance Crow's Nest)
% fname = sprintf('%sUnitM.mat',pth0); % calibration file for Unit M (2.3.15 - 21.3.15 15:00 at SEA ICE 1.74m)
fname = sprintf('%sUnitP.mat',pth0); % calibration file for Unit P (2.3.15 - 21.3.15 15:00 at SEA ICE 7m)
load(fname);
% path to from HERE to data
% pth = '../data/CROW/raw/';
% pth = '~/Documents/research/Arctic/N-ICE_2015/DATA/CLASP/data/raw_data/SEA_ICE/CLASP_Lower/';
pth = '~/Documents/research/Arctic/N-ICE_2015/DATA/CLASP/data/raw_data/SEA_ICE/CLASP_Upper/';
% Day to process
yyyy = 2015;
mm = 3;
dd = 17;
% Sampling frequency
Hz = 1;
% Flags
flag.proc = 1;         % set to 0 to skip reading of raw data; assumes all variables are there
flag.plot = 1;         % set to 1 to plot daily files

%% Read CLASP data files
% build input filenames (e.g. ../data/yyyymmdd/crow_20130627_1800.txt)
day = datenum(yyyy,mm,dd,0,0,0);
pth1 = sprintf('%s%0.2d%0.2d%0.2d/',pth,yyyy,mm,dd); % path from HERE to raw data
% str_search = sprintf('%scrow*',pth1);
% str_search = sprintf('%sLower*',pth1);
str_search = sprintf('%sUpper*',pth1);
dr = dir(str_search);
% build output filename
% pth2 = '../data/CROW/daily_1s/';
pth2 = '~/Documents/research/Arctic/N-ICE_2015/DATA/CLASP/data/raw_data/SEA_ICE/daily_1s/';
% fname_op = sprintf('%sCLASP_crow_%0.2d%0.2d%0.2d.mat',pth2,yyyy,mm,dd);
% fname_op = sprintf('%sCLASP_Ice_Lower_%0.2d%0.2d%0.2d.mat',pth2,yyyy,mm,dd);
fname_op = sprintf('%sCLASP_Ice_Upper_%0.2d%0.2d%0.2d.mat',pth2,yyyy,mm,dd);

if flag.proc
    % initialize arrays
    histogram = [];
    t= [];
    status_parameter.PumpT = [];
    status_parameter.SupplyV = [];
    status_parameter.LaserRef = [];
    status_parameter.rejects = [];
    status_parameter.threshold = [];
    status_parameter.ThisFlow = [];
    status_parameter.FlowPWM = [];
    status_parameter.PumpCurrent = [];
    status_parameter.SensorT = [];
    status_parameter.HousingT = [];
    statusaddr = [];
    flags.flow = [];
    flags.heater = [];
    flags.sync = [];
    N = [];

    for i = 1:size(dr,1)
        fname = [pth1 dr(i).name];
        if(exist(fname,'file') == 0)
            sprintf('ERROR: unable to find %s',fname)
            return
        else
            sprintf('%s',fname)
        end
%         [histogram_i,t_i,status_parameter_i,statusaddr_i,flags_i] = CLASP_read_capture_CROW(fname,day,16,16); % updated to read BlowSea format
%         [histogram_i,t_i,status_parameter_i,statusaddr_i,flags_i] = CLASP_read_capture_ICE(fname,day,16,8); % LOWER
        [histogram_i,t_i,status_parameter_i,statusaddr_i,flags_i] = CLASP_read_capture_ICE(fname,day,16,16); % UPPER

        % hourly flow correction to get histogram in units cc/sec
%         P = polyfit(calibr.realflow,calibr.TSIflow,3);
        [P,S,MU] = polyfit(calibr.realflow,calibr.TSIflow,3); % scaling & centering of x-values: same P, but suppresses alert message
        if isfield(status_parameter_i, 'ThisFlow')
            real_flow = mean(status_parameter_i.ThisFlow(:,2));
        else
            real_flow = calibr.setflow;
        end
%         flow = polyval(P,real_flow);
        flow = polyval(P,real_flow,[],MU); % flow rate at STP (L min-1)
        flow_correction = ((flow/60)*1000)/Hz; % flow rate at STP (cm3 s-1) / sample rate (s-1) or Q/SR
        N_i = histogram_i./flow_correction; % N = h * SR * Q-1
         

        %% collect data
        histogram = [histogram; histogram_i];
        t = [t;t_i];
        status_parameter.PumpT = [status_parameter.PumpT; status_parameter_i.PumpT];
        status_parameter.SupplyV = [status_parameter.SupplyV; status_parameter_i.SupplyV];
        status_parameter.LaserRef = [status_parameter.LaserRef; status_parameter_i.LaserRef];
        status_parameter.rejects = [status_parameter.rejects; status_parameter_i.rejects];
        if isfield(status_parameter_i,'threshold')
            status_parameter.threshold = [status_parameter.threshold; status_parameter_i.threshold];
        end
        if isfield(status_parameter_i,'ThisFlow');
            status_parameter.ThisFlow = [status_parameter.ThisFlow; status_parameter_i.ThisFlow];
        end
        status_parameter.FlowPWM = [status_parameter.FlowPWM; status_parameter_i.FlowPWM];
        status_parameter.PumpCurrent = [status_parameter.PumpCurrent; status_parameter_i.PumpCurrent];
        status_parameter.SensorT = [status_parameter.SensorT; status_parameter_i.SensorT];
        status_parameter.HousingT = [status_parameter.HousingT; status_parameter_i.HousingT];
        statusaddr = [statusaddr; statusaddr_i];
        flags.flow = [flags.flow;flags_i.flow];
        flags.heater = [flags.heater;flags_i.heater];
        flags.sync = [flags.sync;flags_i.sync];
        N = [N;N_i];

    end
    % write to output
    clear Hz *_i P day dd flow* fname i mm real_flow yyyy S MU str_search pth*;
    save(fname_op);
end

%% plots
if flag.plot
    load(fname_op);
    % N, particle number density (particle m-3)
    N = N.*1e6;
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

    figure('Position',pos1); % mean spectra for data file; check units
    for i = 1:16
        dNdR(i,:) = N(i,:)./calibr.dr; % divide by bin width in micrometer
    end

    meanD = calibr.meanR.*2;
    loglog(meanD,nanmean(dNdR),'ob-');
%     plot(meanD,log10(nanmean(dNdR)),'ob-');
    hold on; grid on;
    set(gca,'XLim',[1e-1 1e1],'FontSize',14,'FontName','Times');
    xlabel('mean diameter (\mum)');
    ylabel('dN/dR (m^{-3} \mum^{-1})')
    title(['Mean Spectrum at 29 m on ' datestr(t(1),'dd/mm/yyyy')], ...
        'FontName','Times','FontSize',14);

    figure('Position',pos2); % time series of total N; put in good units, and direction of sum. 
    plot(t,sum(N'),'.');
    hold on; grid on;
    datetick('x','keeplimits');
    set(gca,'FontSize',14,'FontName','Times');
    xlabel('UTC')
    ylabel('N, (m^{-3})') 
    title(['Total N at 29 m on ' datestr(t(1),'dd/mm/yyyy')], ...
        'FontName','Times','FontSize',14);

    figure('Position',pos3); % PumpT, SensorT, HousingT & SupplyV
    subplot(1,2,1)
    plot(status_parameter.PumpT(:,1),status_parameter.PumpT(:,2),'k-');
    hold on; grid on;
    plot(status_parameter.SensorT(:,1),status_parameter.SensorT(:,2),'b-');
    plot(status_parameter.HousingT(:,1),status_parameter.HousingT(:,2),'r-');
    datetick('x','keeplimits');
    title('Pump Temperature');

    subplot(1,2,2)
    plot(status_parameter.SupplyV(:,1),status_parameter.SupplyV(:,2));
    hold on; grid on;
    datetick('x','keeplimits');
    title('Supply Voltage');

    figure('Position',pos4); % LaserRef & Rejects
    subplot(1,2,1)
    plot(status_parameter.LaserRef(:,1),status_parameter.LaserRef(:,2));
    hold on; grid on;
    datetick('x','keeplimits');
    title('LaserRef');
    subplot(1,2,2)
    plot(status_parameter.rejects(:,1),status_parameter.rejects(:,2));
    hold on; grid on;
    datetick('x','keeplimits');
    title('Rejects');

    figure('Position',pos5); % threshold & ThisFlow
    subplot(1,2,1)
    plot(status_parameter.threshold(:,1),status_parameter.threshold(:,2));
    hold on; grid on;
    datetick('x','keeplimits');
    title('Threshold');
    subplot(1,2,2)
    plot(status_parameter.ThisFlow(:,1),status_parameter.ThisFlow(:,2));
    hold on; grid on;
    datetick('x','keeplimits');
    title('ThisFlow');

    figure('Position',pos6); % FlowPWM & PumpCurrent
    subplot(1,2,1)
    plot(status_parameter.FlowPWM(:,1),status_parameter.FlowPWM(:,2));
    title('FlowPWM');
    hold on; grid on;
    datetick('x','keeplimits');
    subplot(1,2,2)
    plot(status_parameter.PumpCurrent(:,1),status_parameter.PumpCurrent(:,2));
    hold on; grid on;
    datetick('x','keeplimits');
    title('PumpCurrent');
end

