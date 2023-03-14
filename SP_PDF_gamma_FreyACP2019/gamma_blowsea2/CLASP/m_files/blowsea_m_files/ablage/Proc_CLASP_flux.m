% Proc_CLASP_flux
% Calculate SSA flux from upper and lower CLASP data (10 min and 30 min resolution)
%
% - normalize to RH=80%
% - bulk correction for moisture flux
%
%
% Input:
% 1 Hz particle number density (particle m-3) in ../all_1s (from Proc_CLASP_step2.m)
% 1 Hz u,v,w,T in ~/Documents/research/Antarctica/BLOWSEA/DATA/SONIC/data/raw_1Hz/
%
%
% MF Melbourne Airport, 8-Mar-2014
%
%*************************************************************************************
clear; close('all');
% day to process (comment out for batch run with run_proc.m)
yy = 2013;
mm = 7;
dd = 14;
t1 = datenum(yy,mm,dd,0,0,0);
clasp = 'upper';

% 1) Load CLASP & sonic data on this day & define ouput path
pth1 = '~/Documents/research/Antarctica/BLOWSEA/DATA/CLASP/data/all_1s/';
fi1 = sprintf('%sCLASP_%s1s_%0.2d%0.2d%0.2d.mat',pth1,clasp,yy-2000,mm,dd); % path to clasp data on this day
pth2 = '~/Documents/research/Antarctica/BLOWSEA/DATA/SONIC/data/raw_1Hz/';
fi2 = sprintf('%ssonic_%0.2d%0.2d%0.2d.mat',pth2,yy-2000,mm,dd); % path to sonic data on this day
load(fi1);
SONIC = load(fi2);

pth3 = '~/Documents/research/Antarctica/BLOWSEA/DATA/CLASP/data/flux_30min/';
fname_op = sprintf('%sCLASP_%s_flux30min_%0.2d%0.2d%0.2d',pth3,clasp,yy-2000,mm,dd);

% 2) Match sonic data to CLASP data
X = [SONIC.t SONIC.u SONIC.v SONIC.w SONIC.T];
Y = f_newgrid(X,t,2,1);
% adjust length
gp = size(N,1)-size(Y,1);
dummy = nan(gp,5);
Y = [Y;dummy];
u = Y(:,2);
v = Y(:,3);
w = Y(:,4);
T = Y(:,5);
clear SONIC X Y;

%% 3) Calculate flux
% set up blockwise averaging
Hz = 1;  % Sampling frequency of sonic in Hz
block_len_sec = 30.*60;    % Averaging period in seconds
% block_edges_bot = 30;     % Lower limit of first block: 1-min means (0:01 0:02 ...)
% block_edges_bot = 300;     % Lower limit of first block: 10-min means (0:10 0:20 ...)
block_edges_bot = 0;     % Lower limit of first block: 30-min means (0:15 0:45 ...)

block_edges_sec = block_edges_bot:block_len_sec:86400;  % adjust edges of blocks to get correct time vector
block_edges_day = t1 + block_edges_sec / 86400;  % edges in matlab time

% preallocate output arrays
uw = NaN;
vw = NaN;
wT = NaN;
wN  = nan(1,16);
ust = NaN;
tst = NaN;
um = NaN;
Tm = NaN;

% T crosswind correction
T = f_T_crosswind_correction(T,u,v,w,'metek'); % Kaimal Correction

% calculate means and variances of blocks according to block_edges_day
for i= 1:size(block_edges_day,2)-1
    idx = find((t > block_edges_day(i)) & (t <= block_edges_day(i+1)));
    uwk = u(idx);vwk = v(idx);wwk = w(idx);
    Twk = T(idx);
    Nwk = N(idx,:); % particle density
    twk = t(idx);   % matlab time
    
    % Coordinate rotation
    [uwk,vwk,wwk,theta,phi] = f_rotate_to_run(uwk,vwk,wwk);
    
    % Calculate means & cross products
    um(i,1) = nanmean(uwk); % mean horizontal wind speed after rotation (equivalent to Um below)
    % Um(i) = nanmean(sqrt(u.^2+v.^2)); % mean horizontal wind speed
    Tm(i,1) = nanmean(Twk);             % mean sonic temperature
    % Calculate fluxes
    [uw_wk, vw_wk, wT_wk, wN_wk] = f_calc_fluxes_clasp(uwk,vwk,wwk,Twk,Nwk); % use twice rotated u,v,w for flux
    uw(i,1) = uw_wk;
    vw(i,1) = vw_wk;
    wT(i,1) = wT_wk;
    wN(i,:) = wN_wk;
    dummy = (uw_wk.^2) + (vw_wk.^2);
    ust(i,1) = sqrt(sqrt(dummy));
    tst(i,1) = -wT(i,1)/ust(i,1);
    % time stamp of current block
    dnm(i,1) = mean(twk);
 
%     % errorflag stats
%     if isempty(erra)==0
%         id_err = find((erra(:,1) > block_edges_day(i)) & (erra(:,1) < block_edges_day(i+1)));
%         err = length(idx)/(length(idx) + length(id_err));
%     else
%         err = 1;
%     end
end

% plot check
figure
subplot(1,2,1)
plot(dnm,wN);
grid on;
datetick('x','keeplimits');
subplot(1,2,2)
plot(dnm,ust);
grid on;
datetick('x','keeplimits');

t = dnm;
save(fname_op,'t','uw','vw','wT','wN','ust','tst','um','Tm');



