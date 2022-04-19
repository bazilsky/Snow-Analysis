function data_struct = f_read_tower_NOAA(pth,filename)
%f_read_tower_NOAA - import daily net-cdf data  
%  tower_NOAA = f_read_tower_NOAA(filename)
%
%  INPUT
%  filename - file to import (string)
%
%  OUTPUT
%     tower_NOAA           - tower_NOAA data structure with 36 fields
%     
%  MF Todtnauberg, 8.03.2022

ncid = netcdf.open([pth filename]);
% info_struct = ncinfo(filename); % list with variable names
% ncdisp(filename);

variables_to_load = {'base_time','time_offset','time','lat_tower','lon_tower','sr50_dist','temp_2m','temp_6m','temp_10m',...
    'rhi_2m','rhi_6m','rhi_10m','wspd_vec_mean_2m','wspd_vec_mean_6m','wspd_vec_mean_10m'};

% loop over the variables
for j=1:numel(variables_to_load)
    % extract the jth variable (type = string)
    var = variables_to_load{j};

    % use dynamic field name to add this to the structure
    data_struct.(var) = ncread(filename,var);

    % convert from single to double, if that matters to you (it does to me)
    if isa(data_struct.(var),'single')
        data_struct.(var) = double(data_struct.(var));
    end
end

netcdf.close(ncid)

%% Compute matlab time stamp t 
base = datenum('1-Jan-1970 00:00:00');
day = double(base + data_struct.base_time./86400);
t = day + data_struct.time./86400;
data_struct.t = t;