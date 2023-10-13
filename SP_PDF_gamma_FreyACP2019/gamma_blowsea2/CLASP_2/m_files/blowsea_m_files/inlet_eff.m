function [Ebend,Ediff,St,Ro] = inlet_eff(L,Ta,Q,Td,r,R,Brad)

% this is a function that works out the particle transport efficiency
% through the inlet tube. It splits the calculation into working out the
% diffusive losses through the lenght of the tube and then the losses of
% particles through the different bends in the inlet. 

% The function only holds if the curvature ratio is in the order of 4 or above. 
% The curvature ratio is calculated by the bend radius/tube radius. 
% "The effect of the curvature ratio Ro has been shown to be insignificant
% for 5 < Ro < 30." Pui et al 1987
% The efficiency of the transport can be increased if the stoke number is kept 
% small i.e. less than 0.1. 

%It is based on the work done by Pui, Romay-Novas and Lui (1987) and shown 
% in Aerosol Measurements: P. Baron, K willeke, p99-101. 


%INPUTS: L = length of inlet tube in meters
%        Ta = temperature of air in deg C
%        Q = flow rate through the inlet tube in cc/sec i.e 50cc/sec 
%        Td = tube diameter in cm;
%        r = particle radius in micormeters
%        R = curve of bend in radians, if more than 1 bend then this an array. 
%                      1deg = pi/180 thus 90 deg = 1.57 rads. (function
%                      deg2rad)
%        Brad = bend radius = 1 to 20cm. 

% created by Dr Sarah J Norris Oct 2007

% 1) calculate diffusive losses

% calcuate diffusivity
[Na] = dynamic_viscosity(Ta);
[Cc] = cunningham_slip_vel(r);
[D] = diffusivity2(Ta,Na,r,Cc);

M = (pi*D*L)/Q; % mach number

if M > 0.02
    Ediff = (0.819*10^(-3.657*M)) + (0.0975*10^(-22.305*M)) + (0.0325*10^(-56.961*M))...
        + (0.0154*10^(-107.62*M)); 
else
    Ediff = 1- ( (2.564*M^(2/3)) + (1.2*M) + (0.1767*M^(4/3))); 
end

% 2) calculate bend losses
Pp = 1.77;   %Particle Density (g cc-1)	
U = 176.8388257;   % Average Velocity (cm s-1) for this set up; 

[Cc] = cunningham_slip_vel(r);
dp = (r*2)*1*10^-4; % particle diameter in millimeters
vis=viscair(Ta); % in m/s
vis = vis/0.1; % to get it in cm same as all other units

% stokes number
St = (Cc*(dp^2)*Pp*U)/(18*vis*Td); 

% valid to ignor curvature ratio if between 5 and 30.
Ro = Brad./(Td./2);

% calculate for each bend size
Ebend = 1-(St*R);

 