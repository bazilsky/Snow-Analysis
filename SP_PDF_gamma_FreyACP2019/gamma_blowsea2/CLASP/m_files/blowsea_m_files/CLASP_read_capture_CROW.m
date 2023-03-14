function [CLASP,t,status_parameter,statusaddr,flags,overflow] = CLASP_read_capture_CROW(filename,day,channels,bits);

% this function reads in a text file created during the testing of CLASP
% units in the lab. -small boards (MK5) data output!

%INPUTS: filename - as a string
%      : channel - the number of aerosol concentration channels: usually 16.
%       : either 8 or 16 as a number to identify a 16 or 8 data collection.

% created Feb 2013: S. Norris.
% updated Jun 2013: M. Frey (Polarstern)
% updated Feb 2014 (M. Frey, Cambridge): read out time stamp of each status
% parameter

fid = 0;
fid= fopen(filename);
C=textscan(fid,'%s %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n'); % 32 col
fid=fclose('all');

time_stamp = C{1};
statusbyte = C{2};
parameter = C{3};
overflow = C{4};
CLASP = cell2mat(C(5:channels+4));

%% format time
dummy = char(time_stamp);
hh = str2num(dummy(:,1:2));
mm = str2num(dummy(:,4:5));
ss = str2num(dummy(:,7:8));
t = day + hh/24 + mm/1440 + ss/86400;

%% parse the statusbyte bits
% bits 1..4 = parameter number
% bit 5  true if Flow is in range
% bit 6  true if heater is on
% bit 7  is sync signal from external source
% NB dec2bin returns binary representation with bit indices reveresed (so 
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

if bits == 8
    for n=1:8
      ii = logical(bitget(overflow,n));
      if sum(ii) > 0
        CLASP(ii,n) = CLASP(ii,n) + 256;
      end
    end
elseif bits == 16
   overflow = overflow - 128;
   for n=1:8
      ii = logical(bitget(overflow,n));
      if sum(ii) > 0
        CLASP(ii,n) = CLASP(ii,n) + 256;
      end
   end
end
    
%% arrange parameter in a structure with titles to define each variable
% N.B get full parameter status every 1 second. 
% added Jan2013

ss = floor(length(parameter)/10)*10;
parameter = reshape(parameter(1:ss),[10,length(parameter(1:ss))/10])';
statusaddr = reshape(statusaddr(1:ss),[10,length(statusaddr(1:ss))/10])';
t_par = reshape(t(1:ss),[10,length(t(1:ss))/10])';

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
    eval(['status_parameter.',titles{id+1},'=[t_par(:,i) parameter(:,i)];']);
end


