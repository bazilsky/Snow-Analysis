%% test bed for genereic gamma distribution fitting
% This version tests the 1-parameter gamma fit (shape fixed at 2, scale is fitted). 
% test data are built from 2D parameter (shape and scale) !
%
% Phil Anderson, 27th Aug 2012
% modified 14th Feb 2014


%% start tidy

close all
clear all
clc

%% set up test shape: 

% expected for BSn
shape = 2;
scale = 2;

% harsh test!
% shape = 9;
% scale = 0.5;

dx = 0.25;
x = 0:dx:20;

p = [shape scale];      % the starting parameter (no shape is given)
pdf = f_build_2p_gamma(x,p);    % returns the 2-parameter gamma distribution 

if (1)  % add some noise
    pdf = pdf + 0.02*randn(size(pdf));        
end


figure(1)   % show it as a bar plot
clf
bar(x,pdf)



%% Fit the best 1P gamma distribution to the noisy data

h = @f_1p_gamma_diff;       % name of function for search  
data.x = x;                         % structure for the data
data.y = pdf;
p_init = [2.1];                 % 1st guess for search [scale];

%% send the information to f_generic_fit
% this returns the least square fitted P (p_ret) and the 1-sigma uncertainty in P (ep_ret)

[p_ret, ep_ret] = f_generic_fit(data,p_init,h,1);

str = sprintf('scale %5.2f \\pm %0.2f', p_ret(1), ep_ret(1));
title(str,'fontsize',16);

%% Plot best fit

x_fine = min(x):0.001:max(x);       % nice smooth line
pdf_ret = f_build_1p_gamma(x_fine,p_ret);   % calc the curve
hold on 
h = plot(x_fine,pdf_ret,'r-','linewidth',2);        

xlabel('Scale','fontsize',14);
ylabel('PDF','fontsize',14);
