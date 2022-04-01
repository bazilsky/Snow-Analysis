% testing of MATLAB gamma PDF tools

%% Example A)
close all
clear all
clc
% make/plot a gamma PDF w/ alpha=2 and beta=50
dx = 7; x = 0:dx:500 % similar to blowsea data
pdf = gampdf(x,2,50); % make 2p-gamma PDF
[p1,ci1] = gamfit(pdf) % not correct fit for gampdf (even if x just index)

% make/plot a random PDF w/ alpha=2 and beta=50
pdf_rnd = gamrnd(2,50,100,1);
pdf_rnd = sortrows(pdf_rnd);
[p2,ci2] = gamfit(pdf_rnd) % correct fit for gamrnd

% plot
figure(1)
subplot(1,2,1)
bar(x,pdf);
subplot(1,2,2)
bar(pdf_rnd)

%% Example B
x = 1:62; % bin index
% from a fit to Bsn data using bin index
p_ret = [2.14 5.10];

x_fine = (0:0.001:max(x))';       % nice smooth line
pdf_ret1 = f_build_2p_gamma(x_fine,p_ret);   % calc curve
pdf_ret2 = gampdf(x_fine,p_ret(1),p_ret(2)); % calc curve w/ matlab function

xi = gaminv((0:0.0001:0.9999),p_ret(1),p_ret(2)); % reconstruct x with shape and scale
pdf_ret3 = gampdf(xi,p_ret(1),p_ret(2)); % calc curve w/ matlab function matlab function

figure
plot(x_fine,pdf_ret1,'k-','LineWidth',2);
hold on; grid on;
plot(x_fine,pdf_ret2,'b-','LineWidth',2);
plot(xi,pdf_ret3,'ro','MarkerSize',10);
legend('f-build-2p-gamma','gampdf','gaminv','Location','NorthEast');
xlabel('scale','FontSize',16);
ylabel('PDF','FontSize',16);

% Fit 2P gamma distribution
h = @f_2p_gamma_diff;       % name of function for search  
data.x = x_fine;                 % structure for the data
data.y = pdf_ret2;
p_init = [2.1 0.6];         % 1st guess for search [shape scale];
% send the information to f_generic_fit
% this returns the least square fitted P (p_ret) and the 1-sigma uncertainty in P (ep_ret)
[p_ret2, ep_ret2] = f_generic_fit(data,p_init,h,1); % return same shape/scale

%% Example C - gamfit
x = 1:62; % bin index
p = [2.14,5.10];
data = gamrnd(p(1),p(2),62,1); % same No of bins!!!!
[p1,ci1] = gamfit(data) % returns 2.08 / 5.3!!!

% xi = gaminv((0:0.0001:0.9999),p(1),p(2)); % reconstruct x-values with shape and scale (not evenly spaced anymore, not same bin number)
% step = (max(xi)-min(xi))./61;
% xii = min(xi):step:max(xi);

pdf_ret = gampdf(x,p(1),p(2)); % calc PDF w/ matlab function
% [p2,ci2] = gamfit(pdf_ret2) % fit returns 0.3 / 0.05 ???
[p2,ci2] = gamfit(x,[],[],pdf_ret) % fit returns 0.3 / 0.05 ???




