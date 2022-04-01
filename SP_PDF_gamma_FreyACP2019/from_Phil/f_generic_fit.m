% function [p_ret, ep_ret] = f_generic_fit(d,p,h,varargin)
% d = structure of knowns: data
% p = vector of parameters to fit
% h = function handle which returns difference between data and estimate
% hess = flag which, if ~= 0, triggers calculation of errors in p estimate 


function [p_ret, ep_ret, exitflag, matrix] = f_generic_fit(d,p,h,hess)

p_ret = NaN;
ep_ret = NaN;

%'enter fminsearch'
% p_ret = fminsearch(h,p,[],d);
[p_ret,fval,exitflag,matrix] = fminsearch(h,p,[],d);
% 'exit fminsearch'

if hess
    %'enter f_hessian_ND in f_generic_fit'
    H = f_hessian_ND(h,p_ret,d);
    matrix = sum(sum(isnan(H))); % >0 if badly conditioned
    %'exit f_hessian_ND in f_generic_fit'
    SSE = h(p_ret,d);
    
    len_data = numel(d.x);        
    esHH = eye(size(H))/H;
        
    %SE = sqrt(diag(SSE/(size(d,1)-3) * (eye(size(H))/H)))
    SE = sqrt(diag((SSE/(len_data-3)) * esHH));
    ep_ret = 1.96*SE;
end

