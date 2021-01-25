minit

%if necessary/specified, make blank sample file for this station
oopt = 'remakesam'; scriptname = mfilename; get_cropt
if remakesam | ~exist([mgetdir('M_SAM') '/sam_' mcruise '_' sprintf('%03d',stnlocal)], 'file')
    stn = stnlocal; msam_01 %jc211: combined msam_01b (to copy template) and msam_01 (to make new sample file)
end


stn = stnlocal; mctd_01; %read in sbe .cnv data to mstar
stn = stnlocal; mctd_02a; %rename variables following templates/ctd_renamelist.csv

%ylf added jc159: check for out-of-range pressures that will cause trouble
%in mctd_03
root_ctd = mgetdir('M_CTD');
[d, h] = mload([root_ctd '/ctd_' mcruise '_' stn_string '_raw'], '/');
if min(d.press)<=-1.495
    disp(['negative pressures in ctd_' mcruise '_' stn_string '_raw'])
    disp(['check ctd_' mcruise '_' stn_string '_raw; if there are large'])
    disp(['spikes, edit opt_' mcruise ' mctd_01 case and reprocess this station'])
    disp(['if not too large, check/edit revars in mctd_rawedit case in opt_cruise so that'])
    disp([' values<-1.495 will be removed; run mctd_rawedit here and dbcont to continue'])
    disp(['(note this will only apply automatic edits; you will still need to'])
    disp(['run mctd_rawedit again after ctd_all_part2 to go through the GUI editor)'])
    keyboard
end
stn = stnlocal; mctd_02b; %apply corrections (e.g. oxygen hysteresis)

scriptname = mfilename; oopt = 'cal_stations1'; get_cropt % jc191 use cropt to select which stations get cals applied in first-pass processing
if ismember(stnlocal,cal_stations1.temp)
    stn = stnlocal; senscal = 1; mctd_tempcal % temp1 sensor
    stn = stnlocal; senscal = 2; mctd_tempcal % temp2 sensor
end
if ismember(stnlocal,cal_stations1.cond)
    stn = stnlocal; senscal = 1; mctd_condcal % cond1 sensor
    stn = stnlocal; senscal = 2; mctd_condcal % cond2 sensor
end
if ismember(stnlocal,cal_stations1.oxy)
    stn = stnlocal; senscal = 1; mctd_oxycal % oxygen1 sensor
    stn = stnlocal; senscal = 2; mctd_oxycal % oxygen2 sensor
end
if ismember(stnlocal,cal_stations1.trans)
    stn = stnlocal; mctd_transmisscal % transmittance
end
if ismember(stnlocal,cal_stations1.fluor)
    stn = stnlocal; mctd_fluorcal % fluor
end

stn = stnlocal; mctd_03; %average to 1 hz, compute salinity

stn = stnlocal; msam_putpos; % jr302 populate lat and lon vars in sam file

stn = stnlocal; mdcs_01; % on jr306 make all these files at start of cruise
stn = stnlocal; mdcs_02;

if MEXEC_G.ix_ladcp == 1
    mout_1hzasc(stnlocal) %output 1 hz data in ascii format (required for LDEO IX LADCP processing)
end

