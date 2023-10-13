% combine_clasp
%
% combine processed daily 1s-data CLASP files
%
% MF Polarstern, 30/06/2013
% update: 24/07/2013
% MF Cambridge, 9/11/2013
% MF Cambridge, 7/02/2014

clear; close all;                       
% path from HERE to data 
pth = '../data/temp/';
% select files
% str_search = sprintf('%s*crow*',pth);
str_search = sprintf('%s*lower*',pth);
% str_search = sprintf('%s*upper*',pth);
dr = dir(str_search);

% initalize arrays
histogram = [];
N = [];
t = [];
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

% in addition for 1min data
flags.badflow = [];
N_std = [];
flow = [];

for i = 1:size(dr,1)
        fname = [pth dr(i).name];
        if(exist(fname,'file') == 0)
            sprintf('ERROR: unable to find %s',fname)
            return
        else
            sprintf('%s',fname)
        end
    C = load(fname);
    histogram = [histogram; C.histogram];
    N = [N;C.N];
    t = [t;C.t];
    status_parameter.PumpT = [status_parameter.PumpT; C.status_parameter.PumpT];
    status_parameter.SupplyV = [status_parameter.SupplyV; C.status_parameter.SupplyV];
    status_parameter.LaserRef = [status_parameter.LaserRef; C.status_parameter.LaserRef];
    status_parameter.rejects = [status_parameter.rejects; C.status_parameter.rejects];
    status_parameter.threshold = [status_parameter.threshold; C.status_parameter.threshold];
    status_parameter.ThisFlow = [status_parameter.ThisFlow; C.status_parameter.ThisFlow];
    status_parameter.FlowPWM = [status_parameter.FlowPWM; C.status_parameter.FlowPWM];
    status_parameter.PumpCurrent = [status_parameter.PumpCurrent; C.status_parameter.PumpCurrent];
    status_parameter.SensorT = [status_parameter.SensorT; C.status_parameter.SensorT];
    status_parameter.HousingT = [status_parameter.HousingT; C.status_parameter.HousingT];
    statusaddr = [statusaddr; C.statusaddr];
    flags.flow = [flags.flow;C.flags.flow];
    flags.heater = [flags.heater;C.flags.heater];
    flags.sync = [flags.sync;C.flags.sync];
    
    % in addition for 1min data
    flags.badflow = [flags.badflow;C.flags.badflow];
    N_std = [N_std;C.N_std];
    flow = [flow;C.flow];
    
end

% % remove double lines
X = [t flags.flow flags.heater flags.sync];
X = rm_double(X,1);
flags.flow = X(:,2);
flags.heater = X(:,3);
flags.sync = X(:,4);
% X = [t statusaddr];
% X = rm_double(X,1);
% statusaddr = X(:,2:end);
X = [t histogram N];
X = rm_double(X,1);
t = X(:,1);
histogram = X(:,2:17);
N = X(:,18:end);
% clean up
clear C X col dir_struct i index j n rows sorted_names files pth fname str_search dr;


% % %% 1s-Data only: map all variables to common 1s time grid for averaging: 
% % % Open weekly 1-s files and run scripts below
% % % correct Number of elements (divide by 60) & median gives even minutes; run individually on 10-day 1s-files & save

% [YY MM DD hh mm ss] = datevec(t(1));
% start = datenum([YY MM DD hh mm-10 31]); % e.g. 23:59:31
% [YY MM DD hh mm ss] = datevec(t(end));
% stop = datenum([YY MM DD hh mm+10 30]); % e.g. 00:00:30
% tnew = (start:1./86400:stop)';
% % tnew = (start:1./864000:stop)'; % for 10Hz data
% 
% N = f_newgrid([t N],tnew,2,1); N(:,1) = [];
% histogram = f_newgrid([t histogram],tnew,2,1); histogram(:,1) = [];
% flags.flow = f_newgrid([t flags.flow],tnew,2,1); flags.flow(:,1) = [];
% flags.heater = f_newgrid([t flags.heater],tnew,2,1); flags.heater(:,1) = [];
% flags.sync = f_newgrid([t flags.sync],tnew,2,1); flags.sync(:,1) = [];
% status_parameter.PumpT = f_newgrid(status_parameter.PumpT,tnew,2,1); status_parameter.PumpT(:,1) = [];
% status_parameter.SupplyV = f_newgrid(status_parameter.SupplyV,tnew,2,1); status_parameter.SupplyV(:,1) = [];
% status_parameter.LaserRef = f_newgrid(status_parameter.LaserRef,tnew,2,1); status_parameter.LaserRef(:,1) = [];
% status_parameter.rejects = f_newgrid(status_parameter.rejects,tnew,2,1); status_parameter.rejects(:,1) = [];
% status_parameter.threshold = f_newgrid(status_parameter.threshold ,tnew,2,1); status_parameter.threshold (:,1) = [];
% status_parameter.ThisFlow = f_newgrid(status_parameter.ThisFlow ,tnew,2,1); status_parameter.ThisFlow (:,1) = [];
% status_parameter.FlowPWM = f_newgrid(status_parameter.FlowPWM ,tnew,2,1); status_parameter.FlowPWM (:,1) = [];
% status_parameter.PumpCurrent = f_newgrid(status_parameter.PumpCurrent ,tnew,2,1); status_parameter.PumpCurrent (:,1) = [];
% status_parameter.SensorT = f_newgrid(status_parameter.SensorT ,tnew,2,1); status_parameter.SensorT (:,1) = [];
% status_parameter.HousingT = f_newgrid(status_parameter.HousingT ,tnew,2,1); status_parameter.HousingT (:,1) = [];
% t = tnew;
% clear tnew start stop n rows col DD MM YY mm hh ss;

