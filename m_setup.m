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
cdir = pwd; pdir = mfilename('fullpath'); pdir = pdir(1:end-7);
try
    cd(pdir)
    [s,c] = unix(['git log -1 | head -1']);
    c = c(1:15);
    MEXEC.mexec_version = [MEXEC.mexec_version '_last' c(1:6) '_' c(8:15)];
    cd(cdir)
catch
    warning('git commit unknown');
end
MEXEC.MSCRIPT_CRUISE_STRING='dy000';
MEXEC.MDEFAULT_DATA_TIME_ORIGIN = [2021 1 1 0 0 0];
MEXEC.quiet = 1; %if untrue, mexec_v3/source programs are verbose
MEXEC.ssd = 1; %if true, print short documentation line to screen at beginning of scripts
MEXEC.uway_writeempty = 1; %if true, scs_to_mstar and techsas_to_mstar will write file even if no data in range
MEXEC.SITE = [MEXEC.MSCRIPT_CRUISE_STRING '_athome']; % common suffixes '_atsea', '_atnoc', '_athome', '', etc. 
MEXEC.ix_ladcp = 0; %set to 1 if processing LADCP data with LDEO IX

%%%%% with luck, you don't need to edit anything after this for standard installations %%%%%

disp(['m_setup for ' MEXEC.MSCRIPT_CRUISE_STRING ' mexec']) %%%***add something to display git branch too/instead?

%look for mexec base directory
d = pwd; ii = strfind(d, MEXEC.MSCRIPT_CRUISE_STRING); if length(ii)>0; d = d(1:ii-1); else; d = []; end
mpath = {['/local/users/pstar/' MEXEC.MSCRIPT_CRUISE_STRING '/mcruise'];
         ['/noc/mpoc/rpdmoc/' MEXEC.MSCRIPT_CRUISE_STRING '/mcruise'];
         [d MEXEC.MSCRIPT_CRUISE_STRING '/mcruise'];
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
disp(['MEXEC root: ' MEXEC.mstar_root])

% Set path for mexec source
MEXEC.mexec_source_root = [MEXEC.mstar_root '/sw/mexec'];
if length(which('m_common'))==0 % this is in msubs
   disp('adding mexec source to path')
   addpath(MEXEC.mexec_source_root) 
   % add paths below source
   addpath([MEXEC.mexec_source_root '/pstar/subs'])
   addpath([MEXEC.mexec_source_root '/pstar/progs'])
   addpath([MEXEC.mexec_source_root '/source/mexec_snctools'])
   addpath([MEXEC.mexec_source_root '/source/mextras'])
   addpath([MEXEC.mexec_source_root '/source/mscs'])
   addpath([MEXEC.mexec_source_root '/source/mstats'])
   addpath([MEXEC.mexec_source_root '/source/msubs'])
   addpath([MEXEC.mexec_source_root '/source/mtechsas'])
   addpath([MEXEC.mexec_source_root '/source/unfinished'])
   addpath([MEXEC.mexec_source_root '/source/mrvdas']) % addition on jc211; 28 jan 2021; use rvdas as main data acquisition
   addpath([MEXEC.mexec_source_root '/source/mnew']) % addition on jc211; mfsave

   % paths to other useful libraries %%%***could make this search for whatever version is there? 
   if MEXEC.ix_ladcp
       mpath = [MEXEC.mstar_root '/sw/general_sw/LDEO_IX_13'];
       if exist(mpath)==7; addpath(mpath); addpath([mpath '/geomag']); end
   end
   mpath = [MEXEC.mstar_root '/sw/general_sw/m_map_v1_4'];
   if exist(mpath)==7; addpath(mpath); end
   %mpath = [MEXEC.mstar_root '/sw/general_sw/gamma_n_v3_05_10'];
   %if exist(mpath)==7; addpath(mpath); else; warning('could not add gamma_n to path'); end % only used in mcfc_03
   mpath = [MEXEC.mstar_root '/sw/general_sw/seawater_ver3_2'];
   if exist(mpath)==7; addpath(mpath); end
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
MEXEC_G.ix_ladcp = MEXEC.ix_ladcp;
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
        if datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN)>=datenum(2021,6,1)
            MEXEC_G.Mshipdatasystem = 'rvdas';
            MEXEC_G.default_navstream = 'pospmv';
            MEXEC_G.default_hedstream = 'attpmv';
        else
            MEXEC_G.Mshipdatasystem = 'techsas';
            MEXEC_G.default_navstream = 'posmvpos';
            MEXEC_G.default_hedstream = 'attposmv';
        end
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS Discovery';
    case 'jc'
        if MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)>=2021
            MEXEC_G.Mshipdatasystem = 'rvdas';
            MEXEC_G.default_navstream = 'pospmv';
            MEXEC_G.default_hedstream = 'attpmv';
        else
            MEXEC_G.Mshipdatasystem = 'techsas';
            MEXEC_G.default_navstream = 'posmvpos';
            MEXEC_G.default_hedstream = 'attposmv'; %or gyropmv
        end
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
   disp('adding mexec_processing_scripts subdirectories to path')
   addpath([MEXEC.mexec_processing_scripts '/bottle_samples'])
   addpath([MEXEC.mexec_processing_scripts '/cruise_options/'])
   addpath([MEXEC.mexec_processing_scripts '/gridsec'])
   addpath([MEXEC.mexec_processing_scripts '/ladcp_scripts'])
   addpath([MEXEC.mexec_processing_scripts '/plots'])
   addpath([MEXEC.mexec_processing_scripts '/summaries/'])
   addpath([MEXEC.mexec_processing_scripts '/utilities/'])
   addpath([MEXEC.mexec_processing_scripts '/uway/'])
   addpath([MEXEC.mexec_processing_scripts '/varlists/'])
end

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
    'M_BOT_PIG' 'ctd/BOTTLE_PIG'
    'M_BOT_CO2' 'ctd/BOTTLE_CO2'
    'M_BOT_CFC' 'ctd/BOTTLE_CFC'
    'M_BOT_CH4' 'ctd/BOTTLE_CH4'
    'M_BOT_CHL' 'ctd/BOTTLE_SHORE'
    'M_BOT_ISO' 'ctd/BOTTLE_SHORE'
    'M_SAM' 'ctd'
    'M_TEMPLATES' 'mexec_processing_scripts/varlists'
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
    case 'rvdas'
        MEXEC_G.uway_torg = 0; % mrvdas parsing returns matlab dnum. No offset required.
        MEXEC_G.RVDAS_CSVROOT = [MEXEC_G.MEXEC_DATA_ROOT '/rvdas/rvdas_csv_tmp/'];
        MEXEC_G.RVDAS_MACHINE = ['rvdas.' MEXEC_G.Mship '.local'];
        MEXEC_G.RVDAS_USER = 'rvdas';
        MEXEC_G.RVDAS_DATABASE = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
end

%underway data directories
ud_is_current = 0; ud_runs = 0; sud_runs = 0; ufail = 0;
while ud_is_current == 0 & ud_runs == 0 & ufail == 0
    try
        [udirs, udcruise] = m_udirs;
        if strcmp(udcruise, MEXEC_G.MSCRIPT_CRUISE_STRING)
            ud_is_current = 1;
        else
            error()
        end
    catch
        try
            unix(['/bin/rm -f ' MEXEC.mexec_processing_scripts '/uway/m_udirs.m']);
            m_setudir
            sud_runs = 1;
            try
                [udirs, udcruise] = m_udirs;
                ud_runs = 1;
            catch
                ufail = 1;
            end
        catch
            ufail = 1;
        end
    end
end
if ufail
    if ~sud_runs
        warning('no underway directories yet, m_setudir failed, rerun when they are available/linked')
    elseif ~ud_runs
        warning('no underway directories yet, m_udirs failed, rerun m_setudir when they are available/linked')
    end
elseif length(udirs)>0
    MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; udirs(:,1:2)];
    a = mgetdir(MEXEC_G.default_navstream); l = length(MEXEC_G.MEXEC_DATA_ROOT);
    MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; {'M_POS' a(l+2:end)}];
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
