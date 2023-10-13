%READ_MODELNUM   read pTomcat number densities into MATLAB
%   Model_spectrum_dd_month_yyy.dat
%   Total_number_density_2hrly_mm_yyyy.dat
%
%  MF, Cambridge, 24.03.2023

% pth = '../model_output_06032023/';      % path from HERE to data
pth = '../model_output_29032023/';      % path from HERE to data
% put all filenames into character array (= padded array of strings, equal number of col)
dir_struct = dir(pth);
dir_struct = dir_struct(3:end);
sorted_names = char({dir_struct.name}');    
% 
[rows col] = size(sorted_names);
index = [];
for i = 1:rows
    dummy = findstr('number_density',sorted_names(i,:));
    if prod(size(dummy)) ~= 0
        index = [index;i];
    end
end

files = sorted_names(index,:);
files = cellstr(files);
files = strvcat(files);

[r c] = size(files);
N = [];
for i = 1:r
    fname = files(i,:);
    %% Write to structure
    N = [N;f_read_spectrum(pth,fname)];
end

N(:,1) = [];
N = sortrows(N,1);
t0 = datenum('1-Jan-1970 00:00:00');
N(:,1) = t0+N(:,1);

N_SSAmodel = N;
clear c col dir_struct dummy fname i* N pth r* sorted_names t0;


%% functions
function out = f_read_spectrum(pth,fname)
% Read ASCII output format: N,Model_time(days since 1970-01-01 00:00:00), SI_SSA(particle/cm^3), OO_SSA(particle/cm^3)
fid= fopen([pth fname]);
C=textscan(fid,'%n %n %n %n','HeaderLines',1);
fclose(fid);
out = cell2mat(C);
end

