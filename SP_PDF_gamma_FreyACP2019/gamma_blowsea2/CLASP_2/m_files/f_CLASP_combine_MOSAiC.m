function f_CLASP_combine_MOSAiC(days)
%f_CLASP_combine_MOSAiC - combine daily CLASP mat files
%   f_CLASP_combine_MOSAiC(day) - combine CLASP mat files
%     days in MATLAB nunmerical format
%
%   MF Trumpington, 1.04.2021

%% Parameters
% path from HERE to input/ouput
pth_in = '../data/daily_1min/';
pth_out = '../data/combined/';

%% initialize structures
status = struct('SupplyV',[],'LaserRef',[],'rejects',[],'threshold',[],...
    'ThisFlow',[],'FlowPWM',[],'PumpCurrent',[],'SensorT',[],'HousingT',[],...
    'PumpT',[],'t_status',[]);
flags = struct('flow',[],'heater',[],'sync',[],'laser',[],'flow2',[]);
CLASP_new = struct('counts',[],'status',status,'flags',flags,'filename',[],...
    'filename2',[],'t',[],'t_vec',[],'dt',[],'dt_nominal',[],'conc',[],'meanR',[],'dR',[],'calibr',[]);

%% Load files and add to structure (e.g. clasp20200101_10Hz.mat)
str_search = sprintf('%sclasp*',pth_in);
dr = dir(str_search);
for i = 1:size(dr,1)
    fname = [pth_in dr(i).name];
    if(exist(fname,'file') == 0)
        sprintf('ERROR: unable to find %s',fname)
        return
    else
        sprintf('%s',fname)
    end
    load(fname);

    % append data to new structure using dynamic fieldnames
    f = fieldnames(CLASP);
    for k=1:numel(f)
        CLASP_new.(f{k}) = [CLASP_new.(f{k});CLASP.(f{k})];
    end
    CLASP_new.filename2 = [CLASP_new.filename2; fname];
end

% concatenate arrays in fields 'status' and 'flags' for plotting
f = fieldnames(CLASP_new.status); % 11 fields in status
for k=1:numel(f)
     dummy = [];
     for l=1:length({CLASP_new.status.(f{k})})
         dummy = [dummy;CLASP_new.status(l).(f{k})];
     end
     status.(f{k}) = dummy;
end
CLASP_new.status = status;

f = fieldnames(CLASP_new.flags); % 5 fields in flags
for k=1:numel(f)
     dummy = [];
     for l=1:length({CLASP_new.flags.(f{k})})
         dummy = [dummy;CLASP_new.flags(l).(f{k})];
     end
     flags.(f{k}) = dummy;
end
CLASP_new.flags = flags;

%% write to output
CLASP = CLASP_new;
% build output filename
fname_op = sprintf('%sclasp_all_1min.mat',pth_out);
save(fname_op,'CLASP','fname_op');


%% OLD SCRIPT
% loop through pre-defined list of files; breaks if a file is missing

% for i=1:size(days,1)
%     [yyyy, mm, dd] = datevec(days(i));
%     fname = sprintf('%sclasp%0.4d%0.2d%0.2d_1min.mat',pth_in,yyyy,mm,dd);
%     if(exist(fname,'file') == 0)
%         sprintf('ERROR: unable to find %s',fname)
%         return
%     else
%         load(fname);
%         sprintf('%s',fname)
%     end
%     
%     % append data to new structure using dynamic fieldnames
%     f = fieldnames(CLASP);
%     for k=1:numel(f)
%         CLASP_new.(f{k}) = [CLASP_new.(f{k});CLASP.(f{k})];
%     end
%     CLASP_new.filename2 = [CLASP_new.filename2; fname];
% end
