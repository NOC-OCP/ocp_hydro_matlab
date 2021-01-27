%scripts to run when ladcp, navigation, and bottle data have been processed 
%or information entered into station_depths/station_depths_cruise.txt, 
%nav/pos/pos_cruise_01.nc, and ctd/ASCII_FILES/bot_cruise_01.csv

%update .mat file in station_depths/
populate_station_depths;
	
if length(klist)>1
    disp('Will process stations in klist: ')
disp(klist)
okc = input('OK to continue (y/n)?','s');
if okc == 'n' | okc == 'N'
	return
end
end

for kloop = klist
    stn = kloop; minit

%    %rerun niskin steps if flags have been changed in opt_cruise
%    d = mload([mgetdir('M_CTD') 'bot_' mcruise '_' stn_string],'bottle_qc_flag');
    stn = kloop; mbot_01
    stn = kloop; mbot_02

    %gets depth from .mat file in station_depths/, puts them in .nc files
    stn = kloop; mdep_01
    
    %puts start/bottom/end cast positions in .nc files
    stn = kloop; mdcs_04
    stn = kloop; mdcs_05
    
    stn = kloop; msam_02b;
    stn = kloop; msam_updateall;

end

%mout_cchdo_sam with argument to make in reverse niskin order, see jc191 version

%copy files to public drive -- make this a cruise option***
%unix(['cp /local/users/pstar/cruise/data/samlists/* /local/users/pstar/cruise/data/legwork/scientific_work_areas/ctd/csvfiles/']);
%unix(['cp /local/users/pstar/cruise/data/collected_files/ctdlists/* /local/users/pstar/cruise/data/legwork/scientific_work_areas/ctd/csvfiles/']);
