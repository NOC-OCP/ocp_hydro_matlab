%scripts to run when ladcp, navigation, and bottle data have been processed 
%or information entered into station_depths/station_depths_cruise.txt, 
%nav/pos/pos_cruise_01.nc, and ctd/ASCII_FILES/bot_cruise_01.csv

%update .mat file in station_depths/
populate_station_depths;
	
if ~exist('klist','var')
    if ~exist('stn','var') %prompt
        minit
    end
    klist = stn;
else
disp('Will process stations in klist: ')
disp(klist)
end
klist = klist(:)';

for kloop = klist
    stn = kloop; minit

%    %rerun niskin steps if flags have been changed in opt_cruise
%    d = mload([mgetdir('M_CTD') 'bot_' mcruise '_' stn_string],'bottle_qc_flag');
    stn = kloop; mbot_01
    stn = kloop; mbot_02

    %gets depth from .mat file in station_depths/, puts them in .nc files
    stn = kloop; mdep_01
    
    %stn = kloop; msam_02b;

    scriptname = 'batchactions'; oopt = 'ctd'; get_cropt

end

scriptname = 'batchactions'; oopt = 'sam'; get_cropt
scriptname = 'batchactions'; oopt = 'sync'; get_cropt
clear klist*