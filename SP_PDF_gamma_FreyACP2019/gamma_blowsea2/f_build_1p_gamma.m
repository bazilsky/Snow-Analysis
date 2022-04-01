%% function to build a gausian curve at x given sig and mu
% see http://en.wikipedia.org/wiki/Gamma_distribution

% this version  (1p_gamma) has fixed shape = 2;

function fn = f_build_1p_gamma(x,p)

k = 2;
theta = p(1);

wk1 = x.^(k-1);
wk2 = exp(-x/theta);
wk3 = theta.^k;
wk4 = gamma(k);

fn = wk1.*wk2 ./(wk3.*wk4);
