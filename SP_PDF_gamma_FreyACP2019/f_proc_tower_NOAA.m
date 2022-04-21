function f_proc_tower_NOAA(days)
%f_proc_tower_NOAA - Read (plot) daily 10s-resolution netcdf-files and save to *.mat
%   f_proc_tower_NOAA(day) - pass day to process to function
%
%   MF Todtnauberg, 8.03.2022

%% Parameters
% path from HERE to input/ouput
pth_in = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/metcity_data_test/';
pth_out = '/Users/ananth/Desktop/bas_scripts/DATA_SETS/metcity_data_test/output/';
% Flags
flag.proc = 1;         % 1= read net-cdf data / 0= load *.mat file
flag.plot = 0;         % 1= plot data in range / 0= do not plot

%% Read net-cdf files
% find *.nc files in directory (e.g. mosaosuhsasM1.b1.20191011.000000.nc)
str_search = sprintf('%smosmet.metcity.level2v3.1min.*.nc',pth_in);
dr = dir(str_search);
% build output filename (e.g.tower_NOAA_10s.mat)
fname_op = sprintf('%stower_NOAA_1min.mat',pth_out);

if flag.proc

    for i = 1:size(dr,1)
        fname = [pth_in dr(i).name];
        if(exist(fname,'file') == 0)
            sprintf('ERROR: unable to find %s',fname)
            return
        else
            sprintf('%s',fname)
        end
        tower_NOAA_i = f_read_tower_NOAA(pth_in,dr(i).name); % call read function
        if i==1
           % initialize structure
           tower_NOAA = tower_NOAA_i;
        else
            % append new data to structures using dynamic fieldnames
            f = fieldnames(tower_NOAA);
            for k=1:numel(f)
                tower_NOAA.(f{k}) = [tower_NOAA.(f{k});tower_NOAA_i.(f{k})];
            end
        end
    end
     
    % write to output
    save(fname_op,'tower_NOAA','fname_op');
end

%% plots
if flag.plot
    load(fname_op);
    n = find(tower_NOAA.t>=days(1) & tower_NOAA.t<=days(end)); % plot/compute data only in range
    
    % Plot figures: pos [left bottom width height]
    bdwidth = 1;
    topbdwidth = 0;
    set(0,'Units','pixels')
    scnsize = get(0,'ScreenSize');
    pos1  = [bdwidth,...
     2/3*scnsize(4) + bdwidth,...
     scnsize(3)/3 - 2*bdwidth,...
     scnsize(4)/3 - (topbdwidth + bdwidth)];
    pos2 = [pos1(1) + scnsize(3)/3,...
     pos1(2),...
     pos1(3),...
     pos1(4)];
    pos3 = [pos1(1) + scnsize(3)*2/3,...
     pos1(2),...
     pos1(3),...
     pos1(4)];
    pos4 = [pos1(1),...
     1/6*scnsize(4),...
     pos1(3),...
     pos1(4)];
    pos5 = [pos1(1)+ scnsize(3)/3,...
     pos4(2),...
     pos1(3),...
     pos1(4)];
    pos6 = [pos1(1)+ scnsize(3)*2/3,...
     pos4(2),...
     pos1(3),...
     pos1(4)];

    % FIG1 - mean dN_dlogDp [cm^{-3} nm^{-1}]
    figure('Position',pos1);
    loglog(tower_NOAA.diameter_optical(1,:),nanmean(tower_NOAA.dN_dlogDp(n,:)),'ob-');
    hold on; grid on;
    set(gca,'XLim',[60 1000],'FontSize',14,'FontName','Times');
    xlabel('mean diameter (nm)');
    ylabel('dN/dlogDp (cm^{-3} nm^{-1})')
    title(['Mean Spectrum ' datestr(days(1),'dd/mm/yyyy') '-' datestr(days(end),'dd/mm/yyyy')],'FontName','Times','FontSize',14);

    % FIG2 - total N [cm^-3]
    figure('Position',pos2); 
    plot(tower_NOAA.t(n),tower_NOAA.total_N_conc(n),'.');
    hold on; grid on;
    datetick('x','keeplimits');
    set(gca,'FontSize',14,'FontName','Times');
    xlabel('UTC')
    ylabel('N, (cm^{-3})')
    title(['Total N ' datestr(days(1),'dd/mm/yyyy') '-' datestr(days(end),'dd/mm/yyyy')],'FontName','Times','FontSize',14);
 
    % FIG3 - total SA [cm^2 cm^-3]
    figure('Position',pos3); 
    plot(tower_NOAA.t(n),tower_NOAA.total_SA_conc(n),'.');
    hold on; grid on;
    datetick('x','keeplimits');
    set(gca,'FontSize',14,'FontName','Times');
    xlabel('UTC')
    ylabel('SA, (cm^2 cm^{-3})')
    title(['Total SA ' datestr(days(1),'dd/mm/yyyy') '-' datestr(days(end),'dd/mm/yyyy')],'FontName','Times','FontSize',14);
    
    % FIG4 - total V [cm^3 cm^-3]
    figure('Position',pos4); 
    plot(tower_NOAA.t(n),tower_NOAA.total_V_conc(n),'.');
    hold on; grid on;
    datetick('x','keeplimits');
    set(gca,'FontSize',14,'FontName','Times');
    xlabel('UTC')
    ylabel('V, (cm^3 cm^{-3})')
    title(['Total V ' datestr(days(1),'dd/mm/yyyy') '-' datestr(days(end),'dd/mm/yyyy')],'FontName','Times','FontSize',14);
 
    % FIG5 - sample flow, sheath flow, purge flow
    figure('Position',pos5); 
    plot(tower_NOAA.t(n),tower_NOAA.sample_flow_rate(n),'r.');
    hold on; grid on;
    plot(tower_NOAA.t(n),tower_NOAA.sheath_flow_rate(n),'b.');
    plot(tower_NOAA.t(n),tower_NOAA.purge_flow_rate(n),'k.');
    legend('spl','sheath','purge');
    datetick('x','keeplimits');
    set(gca,'FontSize',14,'FontName','Times');
    xlabel('UTC')
    ylabel('flow, (cm^3 s^{-1})')
    title(['Flow Rates ' datestr(days(1),'dd/mm/yyyy') '-' datestr(days(end),'dd/mm/yyyy')],'FontName','Times','FontSize',14);
    
    % FIG6 - LaserRef
    figure('Position',pos6);
    plot(tower_NOAA.t(n),tower_NOAA.laser_reference_voltage(n),'r.');
    hold on; grid on;
    datetick('x','keeplimits');
    set(gca,'FontSize',14,'FontName','Times');
    xlabel('UTC')
    ylabel('LaserRef, (mV)')
    title(['Laser Reference Voltage ' datestr(days(1),'dd/mm/yyyy') '-' datestr(days(end),'dd/mm/yyyy')],'FontName','Times','FontSize',14);
  
end