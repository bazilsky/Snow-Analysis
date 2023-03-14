% combine_clasp_flux
%

clear;                           % clear variables and
% close all;                       % ...close figures

% gather processed files: sonic_yymmdd.dat 
pth = '../data/flux_30min/';
cd(pth);

dir_struct = dir(pwd);
dir_struct = dir_struct(3:end);
sorted_names = char({dir_struct.name}'); %put all filenames into character array (= array of strings, equal number of col)
% (1) get all upper* files
j=1;
index = [];
[rows col] = size(sorted_names);
for i = 1:rows
    n = strfind (sorted_names(i,:),'lower');
    if prod(size(n)) ~= 0
        index(j) = i;
        j = j+1;
    end
end
files = sorted_names(index,:);
files = cellstr(files); %convert from char array to cell array of strings (can have different number of col)


% (2) run script on chosen files
[rows col] = size(files);
t = [];
wN = [];
for i = 1:rows
    dummy = load(files{i});
    t = [t;dummy.t];
    wN = [wN;dummy.wN];
end