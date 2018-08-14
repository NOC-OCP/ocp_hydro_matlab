%add oxygen etc. bottle calibration data to files, and update appended sampled file
%this should be run following application of the salinity and temperature calibrations (see caldata_all_part1 and smallscript_tccal)
scriptname = 'caldata_all_part2';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

scriptname = 'smallscript'; if ~exist('klist'); oopt = 'klist'; get_cropt; end;
scriptname = 'smallscript_load_oxy_caldata'; oopt = '';

disp('Will process stations in klist: ')
disp(klist)
pause(3)

if ~exist('docsv'); docsv = 0; end

for kloop = klist
    stn = kloop;
    stn_string = sprintf('%03d',stn);

    %oxygen
    stn = kloop; moxy_01
    stn = kloop; moxy_02
    stn = kloop; msam_oxykg

    stn = kloop; msam_02b
    stn = kloop; msam_updateall

    if docsv
       %csv files
       mctd_makelists(kloop, 'nutsodv');
       mctd_makelists(kloop, 'allpsal');
    end

end

%now run ctd_evaluate_oxygen, modify oxy_apply_cal, run smallscript_ocal

if docsv
   revnisk = 0; mout_sam_csv
   revnisk = 1; mout_sam_csv

   %sync csv files to public drive, by way of mac mini since there's no write
   %permission from eriu
   unix(['rsync -av /local/users/pstar/cruise/data/collected_files/samlists/ 10.cook.local:/Volumes/Public/JC159/water_sample_data_logs/samlists/']);
end
