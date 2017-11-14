%apply calibrations and rerun scripts to incorporate them
    
scriptname = 'smallscript';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

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
    
    stn = kloop; senscal = 1; mctd_oxycal;
    stn = kloop; senscal = 2; mctd_oxycal;

    stn = kloop; mctd_03;
    stn = kloop; mctd_04;
    
    stn = kloop; mfir_03;
    stn = kloop; mfir_04;

    %rerun moxy to incorporate any flags changed based on ctd_evaluate_oxygen
    stn = kloop; moxy_01
    stn = kloop; moxy_02
    stn = kloop; msam_oxykg

    stn = kloop; msam_02;
    if kloop==1
       eval(['!/bin/cp sam_' cruise '_001.nc sam_' cruise '_all.nc'])
    else
       stn = kloop; msam_apend
    end
%    stn = kloop; msam_updateall;
    
end
