function mctd_compare_sensors()
%
% compare data from different C or O sensors, in terms of pressure and T-S space , from multiple casts
% can be used as another check in addition to mctd_checkplots; to check the
% results of applying calibrations; or to estimate an adjustment to apply
% to data from one sensor to make it line up better with the others (e.g.
% if calibration data are not available for all sensors)

for kloop = klist
    infile = fullfile(mgetdir('M_CTD'),sprintf('ctd_%s_%03d_2db',mcruise,kloop));
    [d,h] = mload(infile,'press temp1 temp2 cond1 cond2 oxygen1 oxygen2');
end