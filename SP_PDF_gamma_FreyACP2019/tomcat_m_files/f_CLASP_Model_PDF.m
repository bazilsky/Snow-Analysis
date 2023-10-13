function f_CLASP_Model_PDF(PDF_SSAmodel)
%f_CLASP_Model_PDF - plot CLASP and pTomCat model output mean daily PDFs
%     
%     CLASP (2.0m) sea ice (SI) open ocean (OO) 
%
%   MF Cambridge, 06.04.2023

% clear;
close('all');

%% Parameters
% path from HERE to input
pth_CLASP = '../../CLASP/data/';
pth_model = '../../p-TOMCAT SSA outputs/model_output_29032023/';

% Load data
fname = sprintf('%sclasp_all_1min.mat',pth_CLASP);
load(fname);
fname = sprintf('%smodel_output_29032023.mat',pth_model);
load(fname);

% extract days for comparison to observations from fieldnames
f = fieldnames(PDF_SSAmodel);
days = [];
for k=1:numel(f)
     dummy = datenum([f{k}(2:3) '-' f{k}(4:6) '-' f{k}(7:10)]); % write MATLAB date string from structure fieldname and convert to MATLAB format
     days = [days;dummy];
end

% compute average (=-1sigma) PDF of CLASP observations for each day
calibr =CLASP.calibr(1);
lowerD = 2.*calibr.lowerR;
logD = log10(lowerD);
dlogD = diff(logD);
PDF = [];
t_intervals = [days days+1];
[r c] = size(t_intervals);
for i=1:r
    n =find(CLASP.t(:,1)>=t_intervals(i,1) & CLASP.t(:,1)<t_intervals(i,2));
    dummy = CLASP.conc(n,1:16); % [UTC mean(1-16)]
    av = nanmean(dummy./dlogD); % compute average dN/dlogDp
    sd = nanstd(dummy./dlogD); % compute standard deviation of dN/dlogDp
    m = sum(isfinite(dummy)); % No dN/dlogDp
    sdm = sd./sqrt(m); % compute standard error of the mean for dN/dlogDp
    PDF = [PDF; av sdm];
    % plot
    figure;
    set(gca,'XScale','log','YScale','log');
    hold on; grid on;
    e1 = errorbar(CLASP.meanR.*2,PDF(i,1:16),PDF(i,17:end));
    title(['Mean PDF on ' datestr(t_intervals(i,1),'dd/mm/yy')]);
    test =1;
end


%***********************************************************************************************
set(h,'FontSize',16,'FontName','Times');
set(0,'defaultaxeslinewidth',2); set(0,'defaultlinelinewidth',1);
linkaxes(h,'x');

