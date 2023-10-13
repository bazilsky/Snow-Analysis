function write_clasp()
%
% Write CLASP data to ascii
%
% MF Polarstern, 24/07/2013
%**************************************************************************

clear;                 % clear variables and
close('all');          % ...close figures
pth = '../data_CROW/';      % path from HERE to data
fname = sprintf('%sCLASP_crow_1min.mat',pth);
load(fname);
% time interval & wind filter
t1 = datenum('11-Jul-2013');
t2 = datenum('24-Jul-2013');
n0 = find(t(:,1)>=t1 & t(:,1)<=t2);
% wind sector
n1 = find(wdir_rel>=135 & wdir_rel<=225);
% wind speed
n2 = find((wdir_rel<=135 | wdir_rel>=225) & wspd > 13);

% format time vector: dd/mm/yyyy HH:MM
start = datevec(t(n0,2));
start = f_format(start,1);  
stop = datevec(t(n0,3));
stop = f_format(stop,1);

% write to file [UTC_start UTC_stop N_total pollution-flag]
param = (sum(N(n0,:)'))'; % total n/(min cm^3)
fname_op = sprintf('%sCLASP_crow_1min.txt',pth);
flag = zeros(size(t,1),1);
flag(n1) = 1; % raise flag if 135 < wdir_rel < 225 
f_write(start,stop,param,flag,fname_op);



function f_write(start,stop,param,flag,fname_op)
% f_write()
%
%**************************************************************************************************

% Write formated output to file
fpo = fopen(fname_op,'wt'); % open the output file
    if(fpo <= 0)
        sprintf('ERROR: Problem opening %s for writing',fname_op)
        return
    end
    
fprintf(fpo,'%16s\t%16s\t%10s\t%10s\n\n','UTC_start','UTC_stop','N_(min-1 cm-3 microm-1)','Flag'); % header
% write line by line
[r c] = size(param);
for i = 1:r
fprintf(fpo,'%16s\t%16s\t%16.1f\t%16d\n',start(i,:),stop(i,:),param(i,1),flag(i));
end

fclose(fpo); % close the output file

function out = f_format(t,id)
%
% id=1: dd/mm/yyyy HH:MM:SS (RAW data)
% id=2: dd/mm/yyyy HH:MM (1-min means)


d1 = repmat('/',length(t),1);
d2 = repmat(' ',length(t),1);
d3 = repmat(':',length(t),1);

yyyy = num2str(t(:,1));
mm = num2str(t(:,2)); mm = f_paddzeros(mm);
dd = num2str(t(:,3)); dd = f_paddzeros(dd);
HH = num2str(t(:,4)); HH = f_paddzeros(HH);
MM = num2str(t(:,5)); MM = f_paddzeros(MM);
SS = num2str(t(:,6)); SS = f_paddzeros(SS);

if id==1
    % format time vector: dd/mm/yyyy HH:MM:SS
    out = [dd d1 mm d1 yyyy d2 HH d3 MM d3 SS];
elseif id==2
    % format time vector: dd/mm/yyyy HH:MM
    out = [dd d1 mm d1 yyyy d2 HH d3 MM];
end


function c = f_paddzeros(c)
%
% replace spaces with zeros
n = find(c==' ');
c(n) = '0';