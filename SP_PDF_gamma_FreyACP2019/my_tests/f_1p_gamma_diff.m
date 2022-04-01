% difference between gaussian function and data
function ret = f_1p_gamma_diff(p_group,data)

if ~iscell(p_group)
    % called within fminsearch which only works with vectors of parameters
    wk{1} = p_group;
    clear p_group
    p_group = wk;    
end

group_number = numel(p_group);     % number of parameter sets
p_order = numel(p_group{1});

%% additional data assign
x = data.x;
fn_known = data.y;
ret = zeros(group_number,1);

for i = 1:group_number     % f_hessian_ND will send a group of n parameter sets, P may be n x m
    p = p_group{i};        
    fn = f_build_1p_gamma(x,p);
    SSE = sum((fn_known - fn).^2);
    ret(i) = SSE;
end
ret = squeeze(ret);
