function CLASP = f_CLASP_read_MOSAiC(pth,filename)
%f_CLASP_read_MOSAiC - import ASCII data from 2019/20 MOSAiC 
%  CLASP = CLASP_read_MOSAiC(filename)
%
%  INPUT
%  filename - file to import (string)
%
%  OUTPUT
%     CLASP         - CLASP data structure with fields:
%       .counts       - [Nx16] raw particle counts in each channel
%       .status       - CLASP instrument status info structure with fields
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
%       .t_status     - time stamp on first 1/10 of a second
%       .flags        - CLASP instrument status flags structure with fields
%       .flow         - flow within bounds (?)
%       .heater       - heater on? (1 = true, = = false)
%       .sync         - sync signal not used here
%       .t            - matlab serial time
%       .t_vec        - date and time [YYYY MM DD hh mm ss.sss]
%       .dt           - measured mean sample interval (s)
%       .dt_nominal   - the corresponding nominal sample interval (to .01 s)
%
% NB. status info cycle through 10 messages, so each value appears only 
% once every 10 samples. Instrument flags appear at every sample.
% channel boundaries, size & flow calibrations are given in the 
% calibration.mat file created at last calibration. They are applied by 
% calling CLASP_apply_cal_MOSAiC.m
% 
% IMB 5/3/2019
% MMF 16/3/2021 - adjust to MetCity (U Colorado) set up

fid= fopen([pth filename]);
% ASCII output format: timestamp status saddr overflow counts[1:16]
C=textscan(fid,'%s %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n','HeaderLines',1);
fclose(fid);

t_raw = char(C{1}); % original time stamp - 7 digits (mm.ss.mss)
statusbyte = C{2}; 
parameter = C{3}; 
overflow = C{4}; 

if length(C{20})<length(C{19})
    C{20}=[C{20};NaN];
end

counts = [C{5},C{6},C{7},C{8},C{9},C{10},C{11},C{12},C{13},C{14},C{15},C{16},C{17},C{18},C{19},C{20}];


%% parse the statusbyte bits
% bits 1..4 = parameter number
% bit 5  true if Flow is in range
% bit 6  true if heater is on
% bit 7  is sync signal from external source
% NB dec2bin returns binary representation with bit indices reversed (so 
%    visually correct when matrix displayed)

temp = dec2bin(statusbyte,8);      % get 8-bit binary representation of 
statusaddr = bin2dec(temp(:,5:8)); % statusbyte and extract status address

flags.flow = logical(bitget(statusbyte,5));
flags.heater = logical(bitget(statusbyte,6));
flags.sync = logical(bitget(statusbyte,7)); % NB if no sync signal applied
                                            % input floats and may switch
                                            % at random
                                           
%% check overflow flags and correct histogram. 
% Overflow is for channels 1 to 8 only.

for n=1:8
  ii = logical(bitget(overflow,n));
  if sum(ii) > 0
    counts(ii,n) = counts(ii,n) + 256;
  end
end
%% arrange parameter in a structure with titles to define each variable
% N.B get full parameter status every 10 samples. 

ss = floor(length(parameter)/10)*10;
parameter = reshape(parameter(1:ss),[10,length(parameter(1:ss))/10])';
statusaddr = reshape(statusaddr(1:ss),[10,length(statusaddr(1:ss))/10])';

titles{1} = 'rejects';
titles{2} = 'threshold';
titles{3} = 'ThisFlow';
titles{4} = 'FlowPWM';
titles{5} = 'PumpCurrent';
titles{6} = 'SensorT';
titles{7} = 'HousingT';
titles{8} = 'PumpT';
titles{9} = 'SupplyV';
titles{10} = 'LaserRef';

for i = 1:10
    id = statusaddr(1,i);
    status.(titles{id+1}) = parameter(:,i);
end
status.SupplyV = status.SupplyV/100; % convert from .01V (int) to V (decimal)

%% Compute time stamps
mm = str2num(t_raw(:,1:2));
ss = str2num(t_raw(:,3:4));
mss = str2num(t_raw(:,5:7));
% filename mscYYYJJJhh_raw.txt(e.g. msc02003500_raw.txt)
YY = str2num(filename(5:6))+2000;
JDAY = str2num(filename(7:9));
hh = str2num(filename(10:11));
t0 = datenum([YY 0 0 hh 0 0]) + JDAY; % day and hour in matlab numerical format
t0 = datevec(t0);
dummy = repmat(t0,length(t_raw),1);
t = datenum([dummy(:,1:4) mm ss+mss./1e3]); % matlab serial time for counts / flags
t_vec = datevec(t); % time vector for counts / flags [YY MM DD hh mm ss.sss]
% matlab serial time for status 
% N.B. cycles through 10 params per second / report all on the first sub-second time stamp
ss = floor(length(t)/10)*10;
t_status = reshape(t(1:ss),[10,length(t(1:ss))/10])';
t_status = t_status(:,1);
status.t_status = t_status;

%% Write output to structure
CLASP.counts = counts;
CLASP.status = status;
CLASP.flags = flags;
CLASP.filename = filename;
CLASP.t = t;
CLASP.t_vec = t_vec;
CLASP.dt = mean(diff(CLASP.t*86400)); % measured mean sample interval (s)
CLASP.dt_nominal = round(CLASP.dt*100)/100; % the corresponding nominal sample interval (to .01 s)
% CLASP.dt = 0.1;
% CLASP.dt_nominal = 0.1;

