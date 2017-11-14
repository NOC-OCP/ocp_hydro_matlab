%scripts to run when ladcp, navigation, and bottle data have been processed or information entered into station_depths/station_depths_cruise.txt, nav/pos/pos_cruise_01.nc, and ctd/ASCII_FILES/bot_cruise_01.csv

scriptname = 'smallscript';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

% populate_station_depths %copies from text file to .mat file

if ~exist('klist'); oopt = 'klist'; get_cropt; end
	
disp('Will process stations in klist: ')
disp(klist)
okc = input('OK to continue (y/n)?','s');
if okc == 'n' | okc == 'N'
	return
end

for kloop = klist
    stn = kloop;
    stn_string = sprintf('%03d',stn);
    
    stn = kloop; mbot_01
    stn = kloop; mbot_02

    stn = kloop; mdep_01

    stn = kloop; mdcs_04
    stn = kloop; mdcs_05

end
