function [CLASP] = f_CLASP_apply_cal_MOSAiC(CLASP,calibr)
%f_CLASP_apply_cal_MOSAiC - create warning flags and flow correction
% this file takes the raw data in histogram and
% looks through the status report to check for any numbers which seem out 
% of place and indicates it with a warning sign. 
% It then corrects for the flow rate. 
%
% INPUT
%  CLASP   - CLASP data structure
%  calibr  - structure with calibration info
%
% OUTPUT 
%  CLASP      - updated CLASP data structure, with fields
%   .counts   - [Nx16] raw particle counts in each channel
%   .status   - CLASP instrument status info structure with fields
%       .LaserRef     - laser reference voltage (mV)
%       .rejects      - number of counts rejected as outside channels
%       .threshold    - noise threshold 
%       .ThisFlow     - measured flow (A2D counts, 0:1023)
%       .FlowPWM      - pulse width modulation of pump power (0:1023)
%       .PumpCurrent  - pump current (mA)
%       .SensorT      - scatter cell temperature (degC)
%       .HousingT     - housing temperature (degC)
%       .PumpT        - pump temperature (degC)
%       .SupplyV      - instrument supply voltage (V)
%   .flags    - CLASP instrument status flags structure with fields
%       .flow         - flow within bounds (?)
%       .heater       - heater on? (1 = true, = = false)
%       .sync         - sync signal not used here
%       .laser        - laser reference OK? (1 = true, 0 = false)
%       .flow2        - flow within acceptable range? (1 = true, 0 = false)
%   .timebits - date and time [YYYY MM DD hh mm ss.ss]
%   .mday     - date and time as matlab serial day
%   .dt       - measured mean sample interval (s)
%   .dt_nominal - the corresponding nominal sample interval (to .01 s)
%   .conc     - concentration (counts/cm3) in each channel corrected for
%               measured flow rate
%   .meanR    - mean radius of each channel (um)
%   .dR       - width of each channel (um)
%
% NB. status info cycle through 10 messages, so each value appears only 
% once every 10 samples. Instrument flags appear at every sample, but 
% additional laser & flow2 flags only every 10th (derived from status info)
%
% IMB 5/3/2019
% MMF 29/3/2021 - updates for MOSAiC data format

% load the calibration file
% load(calfile);

% check the laser reference voltage hasn't dropped off, good = 1

% MOSAiC - catch error of LaserRef missing
% if isfield(CLASP.status,'LaserRef')==0
%     CLASP.status.LaserRef = ones(length(CLASP.status.SupplyV),1)*100;
% end
    
laser = CLASP.status.LaserRef;
for i = 1:length(laser)
  if laser(i,:) > calibr.laser_ref + 500
    %disp('laser increased out of bounds');
    flag.laser(i,:) = 0;
  elseif laser(i,:) < calibr.laser_ref - 300
    %disp('laser decrease out of bounds');
    flag.laser(i,:) = 0;
  else
    flag.laser(i,:) = 1;
  end
end
    
% check the pump is still working OK, good = 1
real_flow = CLASP.status.ThisFlow;
for i = 1:length(real_flow)
    if real_flow(i,:) > calibr.setflow + 200
        %disp('flow increased out of bounds');
        flag.flow2(i,:) = 0;
    elseif real_flow(i,:) < calibr.setflow - 200
        %disp('flow decreased out of bounds');
        flag.flow2(i,:) = 0;
    else
        flag.flow2(i,:) = 1;
    end
end

% TSI flow is from TSI flow meter, realflow is the flow that CLASP records
% internally. 
P = polyfit(calibr.realflow,calibr.TSIflow,2);
flow = polyval(P,real_flow); % in litres/min
flow_corrected = ((flow/60)*1000)*CLASP.dt; % sample volume in ml

CLASP.conc = CLASP.counts*NaN;
% interpolate flow correction on to full timeseries (only recorded every 10th sample)
ff = interp1([1:length(flow)]*10,flow_corrected,[1:length(CLASP.counts(:,1))],'nearest','extrap'); 

for n = 1:length(ff)
    CLASP.conc(n,:) = CLASP.counts(n,:)./ff(n); % concentration (cm^-3)
end
CLASP.flags.laser = flag.laser;
CLASP.flags.flow2 = flag.flow2;
CLASP.meanR = calibr.meanR;
CLASP.dR = calibr.dr;

