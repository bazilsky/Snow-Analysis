function f_CLASP_write_MOSAiC()
%f_CLASP_write_MOSAiC - write CLASP data to ascii
%
% MF Trumpington, 2.04.2021
%**************************************************************************

clear; close('all'); clc;         

% paths from HERE to data
pth_in = '~/OneDrive - NERC/Documents/PROJECTS/SSAASI-CLIM/EXPERIMENTS/3_MetCity/CLASP/data/';
pth_out = './';
fname = sprintf('%sclasp_all_1min.mat',pth_in);
if(exist(fname,'file') == 0)
    sprintf('ERROR: unable to find %s',fname)
    return
else
    load(fname);
end

t1 = datenum('5-Feb-2020'); t2 = datenum('8-Feb-2020'); % winter 5-7 Feb 2020
% t1 = datenum('13-Jul-2020'); t2 = datenum('16-Jul-2020'); % summer 13-15 Jul 2020
n0 = find(CLASP.t(:,1)>=t1 & CLASP.t(:,1)<=t2);

% format time vector - decimal day 5.0-8.0
[yyyy mm dd] = datevec(t1);
datum = datenum([yyyy 1 31]); 
t = CLASP.t(n0)-datum;
t = [NaN;t]; % add one more line

% write param to file [decimal_day Bin1-Bin16]
Dp = CLASP.meanR(1,:)*2;
param = [Dp; CLASP.conc(n0,1:16)];
header = sprintf('%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t',...
    'UTC','N_tot','N1','N2','N3','N4','N5','N6','N7','N8','N9','N10','N11','N12','N13','N14','N15','N16');
fname_op = sprintf('%sCLASP_winter.txt',pth_out);

f_write(t,param,header,fname_op);

%**************************************************************************************************
function f_write(t,param,header,fname_op);
%f_write - Write formated output to file
%
%**************************************************************************************************
fpo = fopen(fname_op,'wt'); % open the output file
    if(fpo <= 0)
        sprintf('ERROR: Problem opening %s for writing',fname_op)
        return
    end
fprintf(fpo,'%s\n\n',header); % header
% write line by line
for i = 1:size(param,1)
fprintf(fpo,'%10.5f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t%10.3f\t\n',...
    t(i),param(i,1),param(i,2),param(i,3),param(i,4),param(i,5),param(i,6),param(i,7),param(i,8),param(i,9),param(i,10),param(i,11),...
    param(i,12),param(i,13),param(i,14),param(i,15),param(i,16));
end
fclose(fpo); % close the output file