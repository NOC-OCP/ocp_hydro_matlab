%apply calibrations and rerun scripts to incorporate them
    
scriptname = 'smallscript';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

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

    senscal = 1; stn = kloop; mctd_oxycal;
    h24 = m_read_header(['ctd/ctd_' mcruise '_' stn_string '_24hz']);
    if sum(strcmp('oxygen2', h24.fldnam))
        senscal = 2; stn = kloop; mctd_oxycal; 
    end
    
    stn = kloop; mctd_03;
    stn = kloop; mctd_04;
    
    stn = kloop; mfir_03;
    stn = kloop; mfir_04;

    %%rerun moxy to incorporate any flags changed based on ctd_evaluate_oxygen
    %stn = kloop; moxy_01
    %stn = kloop; moxy_02
    %stn = kloop; msam_oxykg

    stn = kloop; msam_02b;
    stn = kloop; msam_updateall;
    
    stn = kloop; mout_cchdo_ctd
    if docsv
       %csv files
       mout_makelists(kloop, 'nutsodv');
       mout_makelists(kloop, 'allpsal');
    end

end

if docsv
    mout_sam_csv %this makes a list in reverse niskin order
end
mout_cchdo_sam

%sync csv files to public drive, by way of mac mini since there's no write
%permission from eriu
unix(['rsync -auv --delete /local/users/pstar/cruise/data/collected_files/ 10.cook.local:/Volumes/Public/JC159/collected_files/']);
