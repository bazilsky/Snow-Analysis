%READ_MODELSPEC   read pTomcat spectra into MATLAB
%   Model_spectrum_dd_month_yyy.dat
%   Total_number_density_2hrly_mm_yyyy.dat
%
%  MF, Cambridge, 24.03.2023

pth = '../model_output_06032023/';      % path from HERE to data
% put all filenames into character array (= padded array of strings, equal number of col)
dir_struct = dir(pth);
dir_struct = dir_struct(3:end);
sorted_names = char({dir_struct.name}');    
% 
[rows col] = size(sorted_names);
index = [];
for i = 1:rows
    dummy = findstr('Model_spectrum',sorted_names(i,:));
    if prod(size(dummy)) ~= 0
        index = [index;i];
    end
end

files = sorted_names(index,:);
files = cellstr(files);
files = strvcat(files);

[r c] = size(files);
for i = 1:r
    fname = files(i,:);
    day_str = ['D' fname(16:17) fname(19:21) fname(23:26)]; % dynamic structure field name (= string scalar) cannot start with integer
    %% Write to structure
    SPECTRUM.(day_str) = f_read_spectrum(pth,fname);
end

function out = f_read_spectrum(pth,fname)
% Read ASCII output format: diameter(um), Sea_ice_SSA(dN/dlog(D) in particle m^-3), Open_ocean_SSA(dN/dlog(D) in particle m^-3)
fid= fopen([pth fname]);
C=textscan(fid,'%n %n %n','HeaderLines',1);
fclose(fid);
out = cell2mat(C);
end

