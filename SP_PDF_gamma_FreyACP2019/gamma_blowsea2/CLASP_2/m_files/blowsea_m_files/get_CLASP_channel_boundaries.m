function [channels,D] = get_CLASP_channel_boundaries(CH,DIAM,D)
%
% INPUT
%   CH   = all A2D channels in range 
%   DIAM = all diameters (from cal curves applied to CH)
%   D    = desired diameter channel boundaries ('lowerD')

% for n = 1:length(D)
%   lowerD(n) = interp1(CH,DIAM,D(n),'nearest');
% end

k = dsearchn(DIAM',D');
channels = CH(k);
D = DIAM(k);

