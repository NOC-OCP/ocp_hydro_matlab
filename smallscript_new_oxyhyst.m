%apply calibrations and rerun scripts to incorporate them
    
scriptname = 'smallscript';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

if ~exist('klist'); oopt = 'klist_new_oxyhyst'; get_cropt; end

disp('Will process stations in klist: ')
disp(klist)
okc = input('OK to continue (y/n)?','s');
if okc == 'n' | okc == 'N'
	return
end

if ~exist('docsv'); docsv = 0; end

for kloop = klist
    stnlocal = kloop;
    stn_string = sprintf('%03d',stnlocal);
    tic
    
%     stn = stnlocal; mctd_01; %read in sbe .cnv data to mstar
%     stn = stnlocal; mctd_02a; %rename variables following templates/ctd_renamelist.csv
    
    %ylf added jc159: check for out-of-range pressures that will cause trouble
    %in mctd_03
    root_ctd = mgetdir('M_CTD');
    [d, h] = mload([root_ctd '/ctd_' mcruise '_' stn_string '_raw'], '/');
    if min(d.press)<=-10
        disp(['negative pressures in ctd_' mcruise '_' stn_string '_raw'])
        disp(['check ctd_' mcruise '_' stn_string '_raw; if there are large'])
        disp(['spikes, edit opt_' mcruise ' mctd_01 case and reprocess this station'])
        disp(['if not too large, edit mctd_rawedit case so that out-of-range'])
        disp(['values will be removed; run mctd_rawedit here and return to continue'])
        disp(['(note this will only apply automatic edits; you will still need to'])
        disp(['run mctd_rawedit again after ctd_all_part2 to go through the GUI editor)'])
        keyboard
    end
    stn = stnlocal; mctd_02b; %apply corrections (e.g. oxygen hysteresis)
    
%     stn = kloop; senscal = 1; mctd_tempcal % temp1 sensor
%     stn = kloop; senscal = 2; mctd_tempcal % temp2 sensor
%     
%     stn = kloop; senscal = 1; mctd_condcal % cond1 sensor
%     stn = kloop; senscal = 2; mctd_condcal % cond2 sensor
% 
%     stn = kloop; senscal = 1; mctd_oxycal % oxygen1 sensor
%     stn = kloop; senscal = 2; mctd_oxycal % oxygen2 sensor

%     stn = kloop; mctd_transmisscal % transmittance
%     stn = kloop; mctd_fluorcal % fluor

    
    stn = stnlocal; mctd_03; %average to 1 hz, compute salinity
    
    stn = stnlocal; msam_putpos; % jr302 populate lat and lon vars in sam file
        
    mout_1hzasc(stnlocal) %output 1 hz data in ascii format (required for LDEO IX LADCP processing)
    
    stn = stnlocal; mctd_04;
    
    %     stn = stnlocal; mfir_01;
%         stn = stnlocal; mfir_02;
    stn = stnlocal; mfir_03;  % ctd data into fir file
    stn = stnlocal; mfir_04; % fir file into sam file
    %
    %     stn = stnlocal; mwin_01;
    %     stn = stnlocal; mwin_03;
    %     stn = stnlocal; mwin_04;
    
    %     stn = stnlocal; mbot_00; % bak on jr302: insert default niskin bottle numbers and firing flags
    %     stn = stnlocal; mbot_01; % mbot_00 only writes to csv file; mbot_01 writes to bot*.nc file
    %     stn = stnlocal; mbot_02; % mbot_02 writes to sam file
    
    stn = stnlocal; msam_updateall;
    
    toc
end


