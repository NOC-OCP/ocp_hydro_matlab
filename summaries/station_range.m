function [s1,s2] = station_range(nstn)
% edited by gdm on jc032 to take a/c of stations.dat giving station times in
% seconds now
% read station file and calculate time in seconds

stnpath = which('station_range')';
stnpath = strrep(stnpath','station_range.m','stations.dat');
eval(['load ',stnpath]);

% station.dat has columns:  station start_sec end_sec

stns = stations(:,1);
sec1 = stations(:,2);
sec2 = stations(:,3);

istn = fix(find(stns == nstn));
s1 = fix(sec1(istn));
s2 = fix(sec2(istn));

clear stations;
