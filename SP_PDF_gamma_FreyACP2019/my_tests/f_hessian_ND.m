%% function H = f_hessian(hFn,o)

% calculates the Jacobian of the gradient of the ND function at the point p
% hFn os is a handle to the function
% varargin holds additional data required by varargin (e.g. x and y (z) if
% parameter coeffs are being Hesse'd

% version ND allows 1,2, or more parameters


function H = f_hessian_ND(hFn,p,varargin)

%% build empty arrays and cell vectors

np = numel(p);  % this is the ORDER of the fit
pv = cell(1,np);
M = cell(1,np);   % 1 x n cell

dp_vec = -2:2;              % specifies the number of points around the centre to calc grads: MUST be 5 or more elements
%dp_vec = -1:1;              % TEST DIAGNOSTIC
ndp = numel(dp_vec);

%% build the 5-point perturbation around each of the given parameters, p
dp = cell(np,1);

for i = 1:np
    dp{i} = 0.01;
    if(p(i))    % if not zero...
        dp{i} = p(i) * 0.05;  % 5 percent delta
    end
    pv{i} = p(i) + dp{i}*dp_vec;  % two vectors of [p-2dp p-dp p p+dp p+2dp];
end

[M{:}] = ndgrid(pv{:});        % n 5x5 meshes, 

%p_sets = zeros(ndp^np,np); 

p_sets = cell(ndp^np,1);

% ndp = numer of points around each P to calc the perturbation: (3 for tests, 5 normally)
% np is the number of parameters
% then there are 3, 9, 27,... functions to calculate for 1,2,3,... parameters (test)
% then there are 5, 25, 125,... functions to calculate for 1,2,3,... parameters with 5 dp's

p_sets_accum = zeros(ndp^np,np);
for i = 1:np  % loop through the np parameters and load into a chain of p's with perturbation
    wk = M{i};
    %wk(:)
    p_sets_accum(:,i) = wk(:);     
end

%p_sets_accum
%% convert m x np 2D array to a chain of m cells each with np vector inside

%whos
for i = 1:numel(p_sets)
    p_sets{i} = p_sets_accum(i,:);
end
%p_sets
%p_sets{1}
%p_sets{end}

%% calculate the results of the chain of function calls
if isempty(varargin)    % no additional data
    fn = hFn(p_sets);
else
    data = varargin{1};     % additional (fixed) data
    fn = hFn(p_sets,data);
end

% put back into the 5x5 shape (or 5x5x5, or ...
rs_mat = ndp*ones(1,np);
if(np > 1)
    fn = reshape(fn,rs_mat);
end

%CORRECT reshape

%% build the ordering vector [2,1,.....] except for single parameter
ord = 1;
if np == 2              % need to swap the order of the dimensions
    ord = [2 1];
end
if np >= 3              
    ord = [2 1 3:np];
end

% calc grads but with the delta p's re-order
grad_fn = cell(1,np);
[grad_fn{:}] = gradient(fn,dp{ord});    % gradient of the scalar field given by del

grad_fn = grad_fn(ord);

% WARNING: GRADIENT is designed for MESHGRID, and returns across columns in dfdx, down columns in dfdy; AAAGH!

% Notes: if fn is 2D, gradient returns df/dx and df/dy, each is 2D
% if fn is 3D, gradient returns df/dx, df/dy and df/dz, and each is 3D
% and so on

%% calc index of centre of ND grid

core_idx = 1;  
for i = 0:np-1
    core_idx = core_idx + 2*(ndp.^i);
end

%% loop to build the actual hessian
% calc the jacobian of the gradient (the Hessian)

hess_grads = cell(1,np);
H = zeros(np);
for i = 1:np      % loop through the gradients, 
    for j = 1:np  % loop through the del_p's
        [hess_grads{:}] = gradient(grad_fn{i},dp{j});                             
        %hess_grads1 = hess_grads{ord};
        
        hess_grads = hess_grads(ord);
        
        %hess_grads = permute(hess_grads,ord);        
        wk = hess_grads{j};
        wk_c = wk(core_idx);     % clip to eliminate edge errors
        H(i,j) = mean(wk_c(:));
    end
end


