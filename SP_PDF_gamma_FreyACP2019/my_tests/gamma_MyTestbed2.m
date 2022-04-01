%% My test bed for generic gamma distribution fitting
% This version tests the 2-parameter gamma fit using Matlab functions
%
% MF 17/03/2019 Cambridge


%% start tidy
close all
clear all
clc
%% (A) use a test shape: 
shape = 2;          % typical of BSn (according to Dover)
scale = 70;
dx = 7; x = 0.1:dx:500;
% x = gaminv((0.005:0.01:0.995),shape,scale);
pdf = gampdf(x,shape,scale); % returns the 2-parameter gamma distribution
if (1)  % add some noise
    pdf = pdf + 0.0005*randn(size(pdf));        
end
n = find(pdf<0);
pdf(n) = pdf(n).*(-1);

figure(1)   % show it as a bar plot
clf
bar(x,pdf)

%% Fit the best 2P gamma distribution to the noisy data
% a) use MATLAB functions (not working correctly)
% [p,ci] = gamfit(pdf,0.05); % returns wrong parameters
% str = sprintf('Shape %5.2f (%0.2f-%0.2f), scale %5.2f (%0.2f-%0.2f)', p(1),ci(1,1),ci(2,1),p(2),ci(1,2),ci(2,2));
% title(str,'fontsize',16);

% b) use Phil's scripts
h = @f_2p_gamma_diff;    % name of function for search  
data.x = x;              % structure for the data
data.y = pdf;
p_init = [2.5 60];      % 1st guess for search [shape scale];

%% send the information to f_generic_fit
% this returns the least square fitted P (p_ret) and the 1-sigma uncertainty in P (ep_ret)
[p_ret, ep_ret] = f_generic_fit(data,p_init,h,1);

str = sprintf('Shape %5.2f \\pm %0.2f, scale %5.2f \\pm %0.2f', p_ret(1), ep_ret(1),p_ret(2), ep_ret(2));
title(str,'fontsize',16);

%% Plot best fit
x_fine = min(x):0.001:max(x);       % nice smooth line
pdf_ret = gampdf(x_fine,p_ret(1),p_ret(2));   % calc the curve
% pdf_ret = gampdf(x_fine,p(1),p(2));   % calc the curve
hold on 
h = plot(x_fine,pdf_ret,'r-','linewidth',2);        

xlabel('Scale','fontsize',14);
ylabel('PDF','fontsize',14);
