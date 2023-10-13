function [statusaddr,status_parameter,histogram,flags,overflow] = read_clasp_BLOWSEA(filename,offbyte)
% read_clasp_BLOWSEA - read binary data files from clasp mk5 on Blowsea project
%
% parses data into status, parameters, overflow and histogram variables. 
% Checks status  and flags any abnormalities. The overflow bits for channels 
% 1 to 8 of the histogram are checked and if wrapping occured the histogram
% is corrected. 
%
%INPUTS
%  filename - string.
%  offbyte  - byte offset to apply when reading file - corrects for null bytes
%             that sometimes appear at start of file at powerup in autostart mode
%OUTPUT: 
%  statusaddr    - address of status parameter (0:9)
%  status_parameter     - value of pararameter named in the structure field
%  histogram     - 16 channel particle count histogram
%  flags         - structure with flag fields:
%                  flow   - true (=1) if flow is in range
%                  heater - true if heater is on (not applicable to ASIST)
%                  sync   - sync signal (not applicable to ASIST)
%  overflow      - overflow byte value; (histogram is corrected for
%                  overflow, provided here for reference).
%
%  March 2010 : S Norris. 
%  2010/04/02 : IMB
%  Jan 2013 : S.Norris 

if nargin < 2
  offbyte = 0;
end

%% total number of bytes is 20 (16 channel histogram) for ASIST  
fd = fopen(filename);
disp(['reading file: ', filename]);

% get status
fseek(fd,offbyte,'bof');
skipbytes = 19;
statusbyte = fread(fd,[1,inf],'uchar',skipbytes)';

% get parameter
fseek(fd,1+offbyte,'bof'); % return pointer to start of file
skipbytes = 18;
% N.B. MACHINEFORMAT is little-endian 
parameter = fread(fd,[1,inf],'int16',skipbytes,'l')';


% get overflow
fseek(fd,3+offbyte,'bof'); 
skipbytes = 19;
overflow = fread(fd,[1,inf],'uchar',skipbytes)';

% get histogram
fseek(fd,4+offbyte,'bof'); 
skipbytes = 4;
histogram = fread(fd,[16,inf],'16*uchar',skipbytes)';

fclose(fd);


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

for n=1:8
  ii = logical(bitget(overflow,n));
  if sum(ii) > 0
    histogram(ii,n) = histogram(ii,n) + 256;
  end
end

%% arranage parameter in a structure with titles to define each variable
% N.B get full parameter status every 1 second. 
% added Jan2013

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
    eval(['status_parameter.',titles{id+1},'=parameter(:,i);']);
end


