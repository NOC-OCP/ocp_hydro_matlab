%script to clobber ctd_cruise_nnn*.nc files and ctd_cruise_nnn history and
%reset ctd_cruise_nnn version to 0, 
%then restart processing from scratch (from the cnv files)
%
%use for instance when it turns out to be necessary to process from the 
%noctm version
%
%this assumes you've already gotten through ctd_all_part1 and mdcs_03g, 
%and hence generated the dcs file, so it will go through mctd_01, mctd_02a,
%mctd_02b, mctd_03, and mout_1hzasc
%
%if you think the bottom was not correctly identified before (due to
%pressure spikes) then you should rerun mdcs_02
%
%otherwise just go on to ctd_all_part2

ssd0 = MEXEC_G.ssd; MEXEC_G.ssd = 1;

if ~exist('klist', 'var')
    klist = input('list of stations to restart from scratch?');
end

root_ctd = mgetdir('M_CTD');
root_hv = fullfile(MEXEC_G.MEXEC_DATA_ROOT, 'mexec_housekeeping');

for no = 1:length(klist)

    stn = klist(no); 
    scriptname = 'castpars'; oopt = 'minit'; get_cropt
    dataname = ['ctd_' mcruise '_' stn_string];
    
    disp(['removing files for station ' stn_string '; ok?']); pause
    delete(fullfile(root_ctd, [dataname '*.nc']));
    
    disp(['removing history file ' dataname '; ok?']); pause
    delete(fullfile(root_hv, 'history', dataname));
    
    disp(['resetting version for ctd_' mcruise '_' stn_string ' to 0; ok?']); pause
    load(fullfile(root_hv, 'version', ['mstar_versionfile_' mcruise '.mat']), 'datanames', 'versions')
    ii = find(strcmp(datanames, dataname));
    if length(ii)>0
        versions(ii) = 0;
        save(fullfile(root_hv, 'version', ['mstar_versionfile_' mcruise '.mat']), 'datanames', 'versions')
    end
        
    disp(['removing mplxyed files for ' stn_string '; ok?']); pause
    delete(fullfile(root_ctd, ['/mplxyed_*_' dataname]));
    
    stnlocal = klist(no);
    stn = stnlocal; mctd_01; %read in sbe .cnv data to mstar
    stn = stnlocal; mctd_02a; %rename variables following templates/ctd_renamelist.csv
    stn = stnlocal; mctd_02b
    stn = stnlocal; mctd_03;
    mout_1hzasc(stnlocal);

end

disp('now carry on from mdcs_02 or ctd_all_part2')
clear klist

MEXEC_G.ssd = ssd0;
