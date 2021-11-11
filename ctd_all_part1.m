ssd0 = MEXEC_G.ssd; MEXEC_G.ssd = 1;

mctd_01; %read in sbe .cnv data to mstar
stn = stnlocal; mctd_02a; %rename variables following templates/ctd_renamelist.csv

%ylf added jc159: check for out-of-range pressures that will cause trouble
%in mctd_03. shouldn't be necessary to redo this before subsequent
%invocations of mctd_02b, because any necessary edits will have been
%added to opt_cruise already (and to mplxyed_* file when mctd_rawedits is run)***
root_ctd = mgetdir('M_CTD');
[d, h] = mloadq(fullfile(root_ctd, ['ctd_' mcruise '_' stn_string '_raw']), 'press', ' ');
if min(d.press)<=-10
    m = {['negative pressures <-10 in ctd_' mcruise '_' stn_string '_raw']
    'check d.press here; if there are large spikes also affecting temperature, dbquit'
    ['here, edit mctd_01 case in opt_' mcruise ', and reprocess this station;']
    'if not, you may want to edit revars in mctd_rawedit case to remove values<-1.495,'
    'run mctd_rawedit here then dbcont to continue (note this will only apply automatic'
    'edits; you will still need to run mctd_rawedit again after ctd_all_part2 to '
    'go through the GUI editor);'
    'alternately you can skip mctd_rawedit and just have NaN psal etc. (but not '
    'temp, cond, press) for these points'};
    warning(sprintf('%s\n',m{:}));
    keyboard
elseif min(d.press)<=-1.495
    m = {['negative pressures <-1.495 but >-10 in ctd_' mcruise '_' stn_string '_raw']
        'you may want to check d.press here, edit revars in mctd_rawedit case of'
        ['opt_' mcruise ' to remove values<-1.495, run mctd_rawedit here then dbcont']
        'to continue (note this will only apply automatic edits; you will still need'
        'to run mctd_rawedit again after ctd_all_part2 to go through the GUI editor);'
        'alternately you can skip mctd_rawedit and just have NaN psal etc. (but not '
        'temp, cond, press) for these points'};
    warning(sprintf('%s\n',m{:}));
    keyboard
end
%apply corrections (e.g. oxygen hysteresis) and calibrations, as specified in opt_cruise
stn = stnlocal; mctd_02b; 

stn = stnlocal; mctd_03; %average to 1 hz, compute salinity

stn = stnlocal; mdcs_01; % now does mdcs_01 and mdcs_02 in one step

if MEXEC_G.ix_ladcp == 1
    mout_1hzasc(stnlocal) %output 1 hz data in ascii format (required for LDEO IX LADCP processing)
end

MEXEC_G.ssd = ssd0;
