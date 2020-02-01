%  m_setup: script to be run before attempting any mexec processing
%
% sets up environment for mexec processing
%
% configure once at start of cruise
%   down to line containing "End of items to be edited on each site/cruise"
%
% INPUT:
%   none
%
% OUTPUT:
%   none
%
% EXAMPLES:
%   m_setup
%

MEXEC.mexec_version = 'v3';
MEXEC.MSCRIPT_CRUISE_STRING='dy113';
MEXEC.MDEFAULT_DATA_TIME_ORIGIN = [2020 1 1 0 0 0];
MEXEC.quiet = 1; %if untrue, mexec_v3/source programs are verbose
MEXEC.ssd = 1; %if true, print short documentation line to screen at beginning of scripts
MEXEC.uway_writeempty = 1; %if true, scs_to_mstar and techsas_to_mstar will write file even if no data in range
MEXEC.SITE = [MEXEC.MSCRIPT_CRUISE_STRING '_atsea']; % common suffixes '_atsea', '_atnoc', '_athome', '', etc. 

%%%%% with luck, you don't need to edit anything after this for standard installations %%%%%

disp(['m_setup for ' MEXEC.MSCRIPT_CRUISE_STRING ' mexec']) %%%***add something to display git branch too/instead?

%look for mexec base directory
d = pwd; ii = strfind(d, MEXEC.MSCRIPT_CRUISE_STRING); if length(ii)>0; d = d(1:ii-1); else; d = []; end
mpath = {['/local/users/pstar/' MEXEC.MSCRIPT_CRUISE_STRING '/mcruise'];
         [d MEXEC.MSCRIPT_CRUISE_STRING];
	 ['/local/users/pstar/cruise']};
fp = 0; n=1;
while fp==0 & n<length(mpath)
    if exist(mpath{n})==7
        MEXEC.mstar_root = mpath{n};
	fp = 1;
    end
    n=n+1; 
end
if fp==0 %none found; query
   disp('enter full path of cruise directory')
   disp('e.g. /local/users/pstar/cruise')
   MEXEC.mstar_root = input('  ', 's');
   disp('you may want to modify m_setup.m to hard-code this directory for future calls')
end
clear mpath d fp n
disp(['working in ' MEXEC.mstar_root])

if 0
% add path for Moorings work
mpath = {[MEXEC.mstar_root(1:end-8) '/rpdmoc/rapid/data/exec/'];
         [MEXEC.mstar_root(1:end-8) '/rapid/data/exec/'];
         ['/noc/users/pstar/rpdmoc/rapid/data/exec/'];
	 [MEXEC.mstar_root '/rpdmoc/rapid/data/exec/'];
	 [MEXEC.mstar_root '/rapid/data/exec/']};
fp = 0; n=1;
while fp==0 & n<length(mpath)
    if exist([mpath{n} MEXEC.MSCRIPT_CRUISE_STRING])==7
        addpath(genpath([mpath{n} MEXEC.MSCRIPT_CRUISE_STRING]));
	add_rapid_paths %%%***rapid: this was commented out in athome but not in atsea, is that general? maybe rapid paths don't need to be part of mexec setup?  
	disp('rapid moorings exec added to path');
	fp = 1;
    end
    n=n+1; 
end
clear mpath fp n
end

% Set root path for NetCDF stuff on this system: must contain subdirectories mexnc and snctools
MEXEC.netcdf_root = [MEXEC.mstar_root '/sw/general_sw/netcdf']; 

% Set path for mexec source
MEXEC.mexec_source_root = [MEXEC.mstar_root '/sw/mexec'];
if length(which('m_common'))==0 % this is in msubs
   disp('adding mexec source to path')
   addpath(MEXEC.mexec_source_root) 
   % add paths below source
   addpath([MEXEC.mexec_source_root '/pstar/subs'])
   addpath([MEXEC.mexec_source_root '/pstar/progs'])
   addpath([MEXEC.mexec_source_root '/source/mextras'])
   addpath([MEXEC.mexec_source_root '/source/mscs'])
   addpath([MEXEC.mexec_source_root '/source/mstats'])
   addpath([MEXEC.mexec_source_root '/source/msubs'])
   addpath([MEXEC.mexec_source_root '/source/mtechsas'])
   addpath([MEXEC.mexec_source_root '/source/unfinished'])

   % paths to other useful libraries %%%***could make this search for whatever version is there? 
   mpath = [MEXEC.mstar_root '/sw/general_sw/LDEO_IX_12'];
   if exist(mpath)==7; addpath(mpath); addpath([mpath '/geomag']); end
   mpath = [MEXEC.mstar_root '/sw/general_sw/m_map_v1_4'];
   if exist(mpath)==7; addpath(mpath); end
   mpath = [MEXEC.mstar_root '/sw/general_sw/gamma_n_v3_05_10'];
   if exist(mpath)==7; addpath(mpath); else; warning('could not add gamma_n to path'); end %%%***maybe this one is not required though
   mpath = [MEXEC.mstar_root '/sw/general_sw/seawater_ver3_2'];
   if exist(mpath)==7; addpath(mpath); end %%%***is this one required now?
   mpath = [MEXEC.mstar_root '/sw/general_sw/gsw_matlab_v3_03'];
   if exist(mpath)==7; addpath(mpath); addpath([mpath '/library']); addpath([mpath '/thermodynamics_from_t']); else; warning('could not add gsw to path'); end
end

% Set path for directory with housekeeping files (in subdirectories version and history)
MEXEC.housekeeping_root = [MEXEC.mstar_root '/data/mexec_housekeeping'];  

% declare MEXEC_G and MEXEC_A as global variables
m_common

% now that MEXEC_G has been declared global, copy over fields from MEXEC
MEXEC_G.mexec_version = MEXEC.mexec_version;
MEXEC_G.MSCRIPT_CRUISE_STRING = MEXEC.MSCRIPT_CRUISE_STRING; % this variable set earlier in code
MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = MEXEC.MDEFAULT_DATA_TIME_ORIGIN; % set global value from local value
MEXEC_G.SITE = MEXEC.SITE;
MEXEC_G.quiet = MEXEC.quiet;
MEXEC_G.ssd = MEXEC.ssd;
MEXEC_G.uway_writeempty = MEXEC.uway_writeempty;

MEXEC_G.PLATFORM_NUMBER = ['Cruise ' MEXEC_G.MSCRIPT_CRUISE_STRING(3:end)];
MEXEC.version_file_name = ['mstar_versionfile_' MEXEC_G.SITE '.mat'];  % This setting should not normally be changed

switch MEXEC_G.MSCRIPT_CRUISE_STRING(1:2)
    case {'di', 'dy'}
        MEXEC_G.Mship = 'discovery';
    case 'jc'
        MEXEC_G.Mship = 'cook';
    case 'jr'
        MEXEC_G.Mship = 'jcr';
    case 'kn'
        MEXEC_G.Mship = 'knorr';
    otherwise
        merr = ['Ship abbreviation ''' MEXEC_G.MSCRIPT_CRUISE_STRING(1:2) ''' not recognised'];
        fprintf(2,'%s\n',merr);
        return
end

switch MEXEC_G.MSCRIPT_CRUISE_STRING(1:2)
    case 'di'
        MEXEC_G.Mshipdatasystem = 'techsas';
        MEXEC_G.default_navstream = 'cnav'; %'gpsfugro';
        MEXEC_G.default_hedstream = 'gyro_s';
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS Discovery';
    case 'dy'
        MEXEC_G.Mshipdatasystem = 'techsas';
        MEXEC_G.default_navstream = 'posmvpos';
        MEXEC_G.default_hedstream = 'attposmv';
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS Discovery';
    case 'jc'
        MEXEC_G.Mshipdatasystem = 'techsas';
        MEXEC_G.default_navstream = 'posmvpos';
        MEXEC_G.default_hedstream = 'attposmv'; %or gyropmv
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS James Cook';
        MEXEC_G.Mrsh_machine = 'cook3'; % remote machine for rvs datapup command %%%***is this still used?
    case 'jr'
        MEXEC_G.default_navstream = 'seatex_gll'; %'seapos';
        MEXEC_G.default_hedstream = 'seatex_hdt'; %'seahead';
        MEXEC_G.Mshipdatasystem = 'scs'; % JCR
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS James Clark Ross';
        MEXEC_G.Mrsh_machine = 'jruj';  % remote machine for rvs datapup command
    case 'kn'
        MEXEC_G.default_navstream = 'nav/gps'; %guess
        MEXEC_G.default_hedstream = 'nav/gyro_s'; %guess
        MEXEC_G.PLATFORM_IDENTIFIER = 'RV Knorr';
    otherwise
        MEXEC_G.default_navstream = 'nav/gps'; %guess
        MEXEC_G.default_hedstream = 'nav/gyro_s'; %guess
        merr = ['Ship ''' MEXEC_G.Mship ''' not recognised'];
        fprintf(2,'%s\n',merr);
        return
end
MEXEC_G.PLATFORM_TYPE= 'ship';

MEXEC_G.MSTAR_TIME_ORIGIN = [1950 1 1 0 0 0];  % This setting should not normally be changed
MEXEC_G.COMMENT_DELIMITER_STRING = ' \n ';     % This setting should not normally be changed

MEXEC_G.MEXEC_DATA_ROOT = [MEXEC.mstar_root '/data']; 
MEXEC.mexec_processing_scripts = [MEXEC_G.MEXEC_DATA_ROOT '/mexec_processing_scripts']; 

if length(which('get_cropt'))==0 % this function is in mexec_processing_scripts/cruise_options
   disp('adding mexec subdirectories to path')
   addpath([MEXEC.mexec_processing_scripts '/cruise_options/'])
   addpath([MEXEC.mexec_processing_scripts '/other_calcs_plots/'])
   addpath([MEXEC.mexec_processing_scripts '/other_calcs_plots/ladcp'])
   addpath([MEXEC.mexec_processing_scripts '/other_calcs_plots/gridsec'])
   addpath([MEXEC.mexec_processing_scripts '/other_calcs_plots/planning'])
   addpath([MEXEC.mexec_processing_scripts '/summaries/'])
   addpath([MEXEC.mexec_processing_scripts '/utilities/'])
   addpath([MEXEC.mexec_processing_scripts '/uway/'])
end
%%%***also test for this being the m_setup in MEXEC.mexec_processing_scripts (and therefore for MEXEC.mexec_processing_scripts being in the path)?

%set data directories within MEXEC_G.MEXEC_DATA_ROOT
MEXEC_G.MDIRLIST = {
    'M_CTD' 'ctd'
    'M_CTD_CNV' 'ctd/ASCII_FILES'
    'M_CTD_BOT' 'ctd/ASCII_FILES'
    'M_CTD_WIN' 'ctd/WINCH'
    'M_CTD_DEP' 'station_depths'
    'M_BOT_SAL' 'ctd/BOTTLE_SAL'
    'M_BOT_OXY' 'ctd/BOTTLE_OXY'
    'M_BOT_NUT' 'ctd/BOTTLE_NUT'
    'M_BOT_CO2' 'ctd/BOTTLE_CO2'
    'M_BOT_CFC' 'ctd/BOTTLE_CFC'
    'M_BOT_CH4' 'ctd/BOTTLE_CH4'
    'M_BOT_CHL' 'ctd/BOTTLE_SHORE'
    'M_BOT_ISO' 'ctd/BOTTLE_SHORE'
    'M_SAM' 'ctd'
    'M_TEMPLATES' 'mexec_processing_scripts/templates'
    'M_VMADCP' 'vmadcp'
    'M_LADCP' 'ladcp'
    'M_IX' 'ladcp/ix'
    'M_SBE35' 'ctd/ASCII_FILES/SBE35'
    'M_SUM' 'collected_files'
  };

%underway system-dependent directories
switch MEXEC_G.Mshipdatasystem
   case 'techsas'
      MEXEC_G.uway_torg = datenum([1899 12 30 0 0 0]); % techsas time origin as a matlab datenum
      MEXEC_G.uway_root = [MEXEC_G.MEXEC_DATA_ROOT '/techsas/netcdf_files_links'];
      if strncmp(computer, 'MAC', 3); MEXEC_G.uway_root = [MEXEC_G.uway_root '_mac']; end
      MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; {'M_TECHSAS' 'techsas'}];
   case 'scs'
      MEXEC_G.uway_torg = 0; % mexec parsing of SCS files converts matlab datenum, so no offset required
      MEXEC_G.uway_root = [MEXEC_G.MEXEC_DATA_ROOT '/scs_raw']; % scs raw data on logger machine
      MEXEC_G.uway_sed = [MEXEC_G.MEXEC_DATA_ROOT '/scs_sed']; % scs raw data on logger machine
      MEXEC_G.uway_mat = [MEXEC_G.MEXEC_DATA_ROOT '/scs_mat']; % local directory for scs converted to matlab
      MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; 
     {'M_SCSRAW' 'scs_raw'}
     {'M_SCSMAT' 'scs_mat'}
     {'M_SCSSED' 'scs_sed'}
     ];
end

%underway data directories
if ~exist([MEXEC.mexec_processing_scripts '/uway/m_udirs.m'], 'file')
   m_setudir %create it
end
[udirs, udcruise] = m_udirs;
if ~strcmp(udcruise, MEXEC_G.MSCRIPT_CRUISE_STRING)
   m_setudir %there was one but it was an old version; recreate
   [udirs, udcruise] = m_udirs;
end
clear udcruise
if length(udirs)>0
   MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; udirs(:,2:3)];
   a = mgetdir(MEXEC_G.default_navstream); l = length(MEXEC_G.MEXEC_DATA_ROOT);
   MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; {'M_POS' a(l+2:end)}];
else
   unix(['/bin/rm ' MEXEC.mexec_processing_scripts '/uway/m_udirs.m']);
   disp('no underway directories yet, rerun m_setudir when they are available/linked')
end
MEXEC_G.Muse_version_lockfile = 'yes'; % takes value 'yes' or 'no'



%%%%%%%%%%%%%%%%%%%%%%%%%%% --------------------------- %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%   End of items to be edited on each site/cruise   %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% --------------------------- %%%%%%%%%%%%%%%%%%%%%%%%%%%

[MEXEC.status MEXEC.uuser] = unix('whoami');
if MEXEC.status ~= 0; MEXEC.uuser = 'user_not_identified'; end
[MEXEC.status MEXEC.uname] = unix('uname -n');
if MEXEC.status ~= 0; MEXEC.uname = 'unixname_not_identified'; end
MEXEC.nl = strfind(MEXEC.uuser,sprintf('\n')); %strip newlines out of unix response
if ~isempty(MEXEC.nl); MEXEC.uuser(MEXEC.nl) = []; end
MEXEC.nl = strfind(MEXEC.uname,sprintf('\n')); %strip newlines out of unix response
if ~isempty(MEXEC.nl); MEXEC.uname(MEXEC.nl) = []; end
MEXEC_G.MUSER = [MEXEC.uuser ' on ' MEXEC.uname];

%%%***hopefully all this can be simplified (not sure we really need 3 versions?) or even made irrelevant by fully implementing matlab's netcdf capabilities?
% determine matlab version and whether there is native netcdf support (>=2008b)
[mver,mvdate] = version; mvdate = datevec(mvdate); mvdate = mvdate(1);
MEXEC.matnet = 0;
if mvdate>2008 | (mvdate==2008 & strcmp(mver(end-1),'b'))
   MEXEC.matnet = 1;
end
if MEXEC.matnet == 0
    MEXEC.path_mexnc = [MEXEC.netcdf_root '/mexcdf_oldest/mexnc'];
    MEXEC.path_snctools = [MEXEC.netcdf_root '/mexcdf_oldest/snctools'];
else
    % extra setup for matlab native netcdf support
    setpref('MEXNC','USE_TMW',true);
    setpref('SNCTOOLS','USE_TMW',true);
    if mvdate==2011 %this is a temporary fix: this version seems to work on 2011a on fola, although maybe it should be used for more than just 2011
        MEXEC.path_mexnc = [MEXEC.netcdf_root '/mexcdf_old/mexnc']; % matlab 2009-2013? %%%***for drake, might need to move mexecdf_r2011a_jcr directory to mexcdf_old
        MEXEC.path_snctools = [MEXEC.netcdf_root '/mexcdf_old/snctools']; %matlab 2009-2013?
    else
        MEXEC.path_mexnc = [MEXEC.netcdf_root '/mexcdf_new/mexnc']; % matlab 2009-2013?
        MEXEC.path_snctools = [MEXEC.netcdf_root '/mexcdf_new/snctools']; %matlab 2009-2013?
    end        
    disp('matlab native netcdf; use_tmw')
end

if length(which('nc_global'))==0 | length(which('nc_varget'))==0
   disp('adding mexnc and snctools to path')
   addpath(MEXEC.path_mexnc)
   addpath(MEXEC.path_snctools)
end

MEXEC.housekeeping_version = [MEXEC.housekeeping_root '/version'];
MEXEC_G.Mhousekeeping_version = MEXEC.housekeeping_version;
MEXEC.housekeeping_history = [MEXEC.housekeeping_root '/history'];

% Make version file and lock file if version file doesn't already exist.
% Should only happen once per cruise or data installation
MEXEC_G.VERSION_FILE = [MEXEC.housekeeping_version '/' MEXEC.version_file_name];
MEXEC.versfile = MEXEC_G.VERSION_FILE;
MEXEC.simplelockfile = [MEXEC.versfile(1:end-4) '_lock'];
if exist(MEXEC_G.VERSION_FILE,'file') ~= 2
    disp('Version file does not seem to exist; will create version file and version lock file')
    datanames = {};
    versions = [];
    save(MEXEC_G.VERSION_FILE,'datanames','versions');
    [us,ur] = unix(['touch ' MEXEC.simplelockfile]);
    if us == 0 & exist(MEXEC.simplelockfile,'file') == 2 % seems to be a successful create of lock file
        m = 'Version lock file touched successfully';
        fprintf(MEXEC_A.Mfidterm,'%s\n',m)
    end
end

% Check existence and availability of version lock file, if it is set to be used
if strcmp(MEXEC_G.Muse_version_lockfile,'yes')

    % might have to wait a bit to find it
    nsecwait = 0;
    while exist(MEXEC.simplelockfile,'file') ~= 2 & nsecwait<40
       fprintf(MEXEC_A.Mfider, '%s\n', 'waiting for version lock file');
       pause(2); nsecwait = nsecwait + 2;
    end

    % waited long enough; is it there now?
    if exist(MEXEC.simplelockfile,'file') 
       if nsecwait > 2
          fprintf(MEXEC_A.Mfider, '%s\n', ['lock file found OK after waiting ' num2str(nsecwait) ' s'], 'it must have been in use; continuing with m_setup');
       end
       % it is; don't need to do anything else

    else % no it is not; suggest how to fix this
       m = {'There is a problem finding the version lock file in m_setup.m:'
            'The lock file is required by the setting of variable MEXEC_G.Muse_version_lockfile'
            ['m_setup.m has waited 40 seconds for ' MEXEC.simplelockfile]
            'to become available but it still does not exist.'
            'If you don''t wish to use the version lock file,'
            '  set MEXEC_G.Muse_version_lockfile to ''no'' in m_setup.'
            'If you intend to use the version lockfile, investigate why the'
            '  standard lock file name above does not exist'
            ' '
            'If all that has happened is that m_setup has been upgraded to use a version'
            '  lock file where it has not been used previously, and if you are sure that'
            '  the version lock file is not in use by another user or program, then create a file with'
            '  the standard name given above using the unix ''touch'' command, and'
            '  re-run m_setup.'
            'It would be a good idea to check in '
            ['  ' MEXEC.housekeeping_version]
            '  where you expect to find the version file'
            ['  ' MEXEC.versfile]
            '  but no lock files'
            ' '
            'To exit this error mode, type ''return'' in response to the ''keyboard'' K>>'
            '  prompt, and m_setup will exit normally.'
            ' '
            'Sort out m_setup, and then run m_setup again before continuing with mexec processing'
            '**********'
       };
       fprintf(MEXEC_A.Mfider, '%s\n', m{:}); keyboard

   end
end

% Check existence of history directory and make if necessary
MEXEC_G.HISTORY_DIRECTORY = MEXEC.housekeeping_history;
if exist(MEXEC_G.HISTORY_DIRECTORY) ~= 7
    disp('history directory does not seem to exist will create it');
    cmd = ['!mkdir ' MEXEC_G.HISTORY_DIRECTORY];
    eval(cmd);
end

MEXEC = rmfield(MEXEC,{'nl'});
