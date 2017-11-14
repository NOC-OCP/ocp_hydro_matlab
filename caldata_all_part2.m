%add oxygen etc. bottle calibration data to files, and update appended sampled file
%this should be run following application of the salinity and temperature calibrations (see caldata_all_part1 and smallscript_tccal)
scriptname = 'caldata_all_part2';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

root_ctd = mgetdir('M_CTD');
    
scriptname = 'smallscript'; if ~exist('klist'); oopt = 'klist'; get_cropt; end;
scriptname = 'caldata_all_part2'; oopt = '';

for kloop = klist
    stn = kloop;
    stn_string = sprintf('%03d',stn);

    %oxygen
    stn = kloop; moxy_01
    stn = kloop; moxy_02
    stn = kloop; msam_oxykg

%    %nutrients
%    stn = kloop; mnut_01
%    stn = kloop; mnut_02

    stn = kloop; msam_02

    if kloop==1
       eval(['!/bin/cp sam_' cruise '_001.nc sam_' cruise '_all.nc'])
    else
       stn = kloop; msam_apend
    end
%    stn = kloop; msam_updateall %if only a few stations have been updated

end

%now run ctd_evaluate_oxygen, modify oxy_apply_cal, run smallscript_ocal
