%scripts to run when ladcp, navigation, and bottle data have been processed 
%or information entered into station_depths/station_depths_cruise.txt, 
%nav/pos/pos_cruise_01.nc, and ctd/ASCII_FILES/bot_cruise_01.csv

scriptname = 'smallscript';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

%update .mat file in station_depths/
populate_station_depths;

if ~exist('klist'); oopt = 'klist'; get_cropt; end
	
disp('Will process stations in klist: ')
disp(klist)
okc = input('OK to continue (y/n)?','s');
if okc == 'n' | okc == 'N'
	return
end

if ~exist('docsv'); docsv = 0; end

for kloop = klist
    stn = kloop;
    stn_string = sprintf('%03d',stn);
        
    %rerun these in case flags have been changed in opt_cruise
    stn = kloop; mbot_01
    stn = kloop; mbot_02

    %gets depth from .mat file in station_depths/, puts them in .nc files
    stn = kloop; mdep_01
    
    %puts start/bottom/end cast positions in .nc files
    stn = kloop; mdcs_04
    stn = kloop; mdcs_05
    
    stn = kloop; msam_02b;
    stn = kloop; msam_updateall;
        
    %csv files
    if docsv
       mout_makelists(kloop, 'nutsodv');
       mout_makelists(kloop, 'allpsal');
       stn = kloop; mout_cchdo_ctd
    end
    
end

mout_sam_csv %this makes a list in reverse niskin order
mout_cchdo_sam

%sync csv files to public drive, by way of mac mini since there's no write
%permission from eriu
unix(['rsync -auv --delete /local/users/pstar/cruise/data/collected_files/ 10.cook.local:/Volumes/Public/JC159/collected_files/']);
