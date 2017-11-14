%add calibration data (sbe35 temperature and bottle salinity) to files, and make appended sample file
scriptname = 'caldata_all_part1';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

% root_ctd = mgetdir('M_CTD');
% prefix1 = ['ctd_' cruise '_'];
    
if ~exist('klist'); scriptname = 'smallscript'; oopt = 'klist'; get_cropt; end
scriptname = 'caldata_all_part1';
oopt = '';

disp('Will process stations in klist: ')
disp(klist)
pause(3)

for kloop = klist
    stn = kloop;
    stn_string = sprintf('%03d',stn);

%    infile1 = [root_ctd '/' prefix1 stn_string '_raw'];
    
%    if exist(m_add_nc(infile1),'file') ~= 2
%        mess = ['File ' m_add_nc(infile1) ' not found'];
%        fprintf(MEXEC_A.Mfider,'%s\n',mess)
%        continue
%    end

    %temperature
    %stn = kloop; msbe35_01
    %stn = kloop; msbe35_02

    %salinity
    stn = kloop; msal_01
    stn = kloop; msal_02

    stn = kloop; msam_02

    if kloop==1
       eval(['!/bin/cp sam_' cruise '_001.nc sam_' cruise '_all.nc'])
    else
       stn = kloop; msam_apend
    end
%    stn = kloop; msam_updateall %if a few stations have been updated

end

%now run ctd_evaluate_sensors (if calibrating temperature, will probably have to run at least twice, implementing temp cal in ctd_evaluate_sensors cruise-specific options before picking sal cal), modify cruise-specific options for temp_apply_cal and cond_apply_cal with calibrations to be applied (and possibly msal_01 or msal_01y for flags), run smallscript_tccal
