clc
clear all 

filename = '/Users/ananth/Downloads/cpc3025_uncorrected_10s.tab'

data = readtable(filename,'Delimiter','\t','FileType','Text');

ship_lat = data.Latitude;
ship_lon = data.Longitude;
ship_time = data.Date_Time;