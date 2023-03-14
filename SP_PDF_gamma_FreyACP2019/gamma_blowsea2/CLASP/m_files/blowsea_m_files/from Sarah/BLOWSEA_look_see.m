function BLOWSEA_look_see

% this function gives a very quick look see to the CLASP data from blowsea
% project. The data is corrected for any overflows, and converted to
% concentrations per cc per second. Two plots are then created; one to look at the
% mean spectra for the data file and the second to look at the total number 
% concentration of aerosol time series. 

% settings
Hz = 1; 

% load calibration file
[FileName,PathName] = uigetfile('*.mat','Select calibration file');
filename=fullfile(PathName, FileName);
load(filename);

%% read in CLASP data file

[FileName,PathName] = uigetfile('*.txt','Select input file');
filename=fullfile(PathName, FileName);
[histogram,status_parameter,statusaddr,flags] = CLASP_read_capture_small(filename,16);


%% flow correction to get histogram in units cc/sec
P = polyfit(calibr.realflow,calibr.TSIflow,3);
real_flow = mean(status_parameter.ThisFlow);
flow = polyval(P,real_flow);
flow_correction = ((flow/60)*1000)/Hz;
N = histogram./flow_correction; 

%% plots

% plot mean spectra for data file
% check units
for i = 1:16
    dNdR(i,:) = N(i,:)./calibr.dr;
end

figure(1)
loglog(calibr.meanR,mean(dNdR),'b-');
xlabel('mean radius (\mum)');
ylabel('dN/dR (cm^{-3} s^{-1} \mum^{-1})')

% plot time series of total N
% put in good units, and direction of sum. 
figure(2)
plot(sum(N'),'.')
xlabel('seconds since start of file')
ylabel('total N in the CLASP size range (cm^{-3} s^{-1})') 





