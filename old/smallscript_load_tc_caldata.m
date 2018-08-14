%add calibration data (sbe35 temperature and bottle salinity) to files, and make appended sample file
scriptname = 'caldata_all_part1';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
    
if ~exist('klist'); scriptname = 'smallscript'; oopt = 'klist'; get_cropt; end
scriptname = 'caldata_all_part1';
oopt = '';

disp('Will process stations in klist: ')
disp(klist)
pause(3)

root_sbe35 = mgetdir('M_SBE35');
if exist(root_sbe35, 'dir'); sbe35 = 1; else; sbe35 = 0; end

if ~exist('docsv'); docsv = 0; end

msal_standardise_avg

for kloop = klist
   stn = kloop;
   stn_string = sprintf('%03d',stn);

   %temperature
   if sbe35
      stn = kloop; msbe35_01
      stn = kloop; msbe35_02
   end
   
   %salinity
   stn = kloop; msal_01
   stn = kloop; msal_02
      
   stn = kloop; msam_02b
   stn = kloop; msam_updateall %if only a few stations have been updated

   if docsv
       %csv files
       mctd_makelists(kloop, 'nutsodv');
       mctd_makelists(kloop, 'allpsal');
   end

end

%now run ctd_evaluate_sensors (if calibrating temperature, will probably have to run at least twice, implementing temp cal in ctd_evaluate_sensors cruise-specific options before picking sal cal), modify cruise-specific options for temp_apply_cal and cond_apply_cal with calibrations to be applied (and possibly msal_01 or msal_01y for flags), run smallscript_tccal

if docsv
   revnisk = 0; mout_sam_csv
   revnisk = 1; mout_sam_csv

   %sync csv files to public drive, by way of mac mini since there's no write
   %permission from eriu
   unix(['rsync -av /local/users/pstar/cruise/data/collected_files/samlists/ 10.cook.local:/Volumes/Public/JC159/water_sample_data_logs/samlists/']);
end
