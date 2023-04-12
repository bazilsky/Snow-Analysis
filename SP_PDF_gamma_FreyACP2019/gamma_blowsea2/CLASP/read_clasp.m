
clear all
clc

pth_in = '/Users/ananth/Desktop/clasp_data/';
%data = load('clasp_all_1min.mat');

% Load CLASP data
fname = sprintf('%sclasp_all_1min.mat',pth_in);
if(exist(fname,'file') == 0)
    sprintf('ERROR: unable to find %s',fname)
    return
else
    CLASP = load(fname); 
end

y = CLASP.CLASP.conc;

%n0 = find(CLASP.CLASP.t(:,1)>=t1 & CLASP.CLASP.t(:,1)<=t2);
plot(CLASP.CLASP.t,nansum(CLASP.CLASP.conc(:,1:16),2),'b-');


%{
x = data.CLASP;
y= x.t; % output the time array

% process if the data in arrays are correct or not, y1, y2 and y3
y1_1 = datestr(y(:,1), 'mm/dd/YYYY');
y1 = datetime(y1_1);

y1_2 = datestr(y(:,2), 'mm/dd/YYYY');
y2 = datetime(y1_2);

y1_3 = datestr(y(:,3), 'mm/dd/YYYY');
y3 = datetime(y1_3);

diff1 = y1 - y2;
diff2 = y2 - y3;
diff3 = y1 - y3;

conc_arr = x.conc;


% save data into csv file
writematrix(conc_arr, 'clasp_conc.csv')
writematrix(y1,'clasp_time.csv')
%}

%writematrix(CLASP.CLASP.conc(:,1:16),'clasp_conc_2.csv')
writematrix(CLASP.CLASP.calibr(1).lowerR, 'clasp_calibr_2.csv')
writematrix(CLASP.CLASP.meanR,'clasp_meanR_2.csv')

