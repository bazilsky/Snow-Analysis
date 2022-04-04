%% function to build a gausian curve at x given sig and mu
% see http://en.wikipedia.org/wiki/Gamma_distribution

function fn = f_build_3p_gamma(x,p)

k = p(1);
theta = p(2);
yscale = p(3);

wk1 = x.^(k-1);
wk2 = exp(-x/theta);
wk3 = theta.^k;
wk4 = gamma(k);

fn = yscale.* (wk1.*wk2 ./(wk3.*wk4));