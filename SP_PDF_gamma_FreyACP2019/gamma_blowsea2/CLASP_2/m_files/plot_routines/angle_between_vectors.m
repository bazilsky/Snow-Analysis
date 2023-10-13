clear all
clc


% Simulated data: Replace these with your actual data
x = rand(1, 2000);
y = rand(1, 2000);
z = rand(1, 2000);
a = rand(1, 2000);
b = rand(1, 2000);
c = rand(1, 2000);

% Calculate dot products for each pair of vectors
dot_products = x .* a + y .* b + z .* c;

% Calculate magnitudes for each pair of vectors
magnitudes_A = sqrt(x.^2 + y.^2 + z.^2);
magnitudes_B = sqrt(a.^2 + b.^2 + c.^2);

% Calculate the cosines of the angles
cos_theta = dot_products ./ (magnitudes_A .* magnitudes_B);

% Handle numerical errors that might push cos_theta slightly out of the [-1, 1] range
cos_theta = min(max(cos_theta, -1), 1);

% Calculate the angles in radians
theta_rad = acos(cos_theta);

% Convert the angles to degrees
theta_deg = rad2deg(theta_rad);

% theta_deg is now a 1x2000 array containing the angles in deg
