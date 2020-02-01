% mdcs_04: merge positions onto ctd start bottom end times
%
% Use: mdcs_04        and then respond with station number, or for station 16
%      stn = 16; mdcs_04;

minit; scriptname = mfilename;
mdocshow(scriptname, ['adds positions from concatenated best ship navigation file bst_' mcruise '_01.nc to dcs_' mcruise '_' stn_string '.nc (if not found in bst file, draws from ctd raw file)']);

% resolve root directories for various file types
root_gps = mgetdir('M_POS');
root_ctd = mgetdir('M_CTD');

dcsfilein = [root_ctd '/dcs_' mcruise '_' stn_string]; 
dcsfileot = [root_ctd '/dcs_' mcruise '_' stn_string '_pos']; 
infile1 = [root_gps '/bst_' mcruise '_01']; 
infile2 = [root_ctd '/ctd_' mcruise '_' stn_string '_raw']; 
wkfile1 = ['wk1_' scriptname '_' datestr(now,30)];
wkfile2 = ['wk2_' scriptname '_' datestr(now,30)];

% bak on jr281 april 2013
% trap case where this station number doesnt exist
if(exist(m_add_nc(infile1),'file') ~= 2); 
    msg = ['File ' m_add_nc(infile1) ' not found'];
    fprintf(2,'%s\n',msg);
    return; 
end

latname = 'lat';
if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
    lonname = 'lon';
else % techsas
    lonname = 'long';
end

if ~exist(m_add_nc(dcsfileot)) %first time through, add all three sets of positions to dcs_pos
   unix(['/bin/cp ' m_add_nc(dcsfilein) ' ' m_add_nc(wkfile1)]);
   isdpos = 0; dvar = 'start'; mdcs_getpos
   unix(['/bin/mv ' m_add_nc(wkfile2) ' ' m_add_nc(wkfile1)]);
   isdpos = 0; dvar = 'bot'; mdcs_getpos
   unix(['/bin/mv ' m_add_nc(wkfile2) ' ' m_add_nc(wkfile1)]);
   isdpos = 0; dvar = 'end'; mdcs_getpos
   unix(['/bin/mv ' m_add_nc(wkfile2) ' ' m_add_nc(dcsfileot)]);
   unix(['/bin/rm ' m_add_nc(wkfile1)]);
end
%now run mcalib branch to modify dcs_pos variables
isdpos = 1; dvar = 'start'; mdcs_getpos
isdpos = 1; dvar = 'bot'; mdcs_getpos
isdpos = 1; dvar = 'end'; mdcs_getpos

% need code for continuous updating nav file for merging
% better this than to use posinfo which needs to be linked to data files
% do something like updatesm but stores output in mstar files,
% so easier to control updates

% eg on jruj
% #
% source .cshrc > /dev/null
% source .login > /dev/null
% cd $P_CTD
% pwd
% dfinfo -l gps_nmea

% also, construct datapup commands to run remotely on cook3.


