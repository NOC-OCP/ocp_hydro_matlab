%  m_setup: to be run before attempting any mexec processing of
%  cruise data; sets up environment (global variables and paths)
%
%  at sea, you can configure once at start of cruise, most likely editing
%  just first block of code, or at most down to line containing "End of
%  items to be edited on each site/cruise" 
%
%  you can also pass selected fields (those in the first block of code
%    below) to MEXEC_G by setting them in structure MEXEC_G_override.
%    fields to override: 
%      MSCRIPT_CRUISE_STRING (e.g. 'jc238')
%      MDEFAULT_DATA_TIME_ORIGIN (e.g. [2022 1 1 0 0 0] -- but note that
%        changing this mid-processing, or between processing and reading
%        data, causes problems)  
%      SITE_suf (e.g. 'atsea' or 'atnoc' to make SITE 'jc238_atsea' etc.)
%      mexec_source_root (e.g. '~/programs/ocp/ocp_hydro_matlab/')
%      other_programs_root (e.g. '~/programs/others/')
%      mexec_data_root (e.g. '~/cruises/jc238/mcruise/data/' but see below)
%      quiet (0 to make all programs verbose, 1 to make only
%        mexec_processing_scripts verbose but file_tools/mexec quiet, 2 to
%        make all quiet)
%
%  to use to add paths necessary for reading mexec files, but without
%    setting up data processing and housekeeping directories, set
%    mexec_data_root to 'readonly': 
%      MEXEC_G.override.mexec_data_root = 'readonly';
%

clear MEXEC_G
global MEXEC_G

%what are we processing and where? 
MEXEC_G.MSCRIPT_CRUISE_STRING='jc238'; 
%default data time origin is now set in opt_cruise
MEXEC_G.SITE_suf = 'atnoc'; % common suffixes '_atsea', '_athome', '', etc.
MEXEC_G.other_programs_root = '~/programs/others/'; 
MEXEC_G.mexec_data_root = ''; %if empty, will search for cruise directory near current directory and near home directory
force_ext_software_versions = 0; %set to 1 to use hard-coded version numbers for e.g. LADCP software, gsw, gamma_n (otherwise finds highest version number available)
MEXEC_G.quiet = 1; %if 0, both file_tools/mexec programs and mexec_processing_scripts will be verbose; if 1, only the latter; if 2, neither

%replace with any parameters passed as inputs
if exist('MEXEC_G_force','var') && isstruct(MEXEC_G_force)
    fn = fieldnames(MEXEC_G_force);
    fn0 = fieldnames(MEXEC_G);
    for fno = 1:length(fn)
        if ~ismember(fn{fno},fn0)
            warning('setting unset %s in MEXEC_G; may be overwritten below',fn{fno})
        end
        MEXEC_G.(fn{fno}) = MEXEC_G_force.(fn{fno});
    end
else
    disp('MEXEC_G_force not set; using defaults')
end
clear MEXEC_G_force

%%%%% with luck, you don't need to edit anything after this for standard installations %%%%%
%%%%% (or it can be edited in opt_{cruise}.m instead) %%%%%

MEXEC_G.SITE = [MEXEC_G.MSCRIPT_CRUISE_STRING '_' MEXEC_G.SITE_suf]; 
MEXEC_G = rmfield(MEXEC_G, 'SITE_suf');

disp(['m_setup for ' MEXEC_G.MSCRIPT_CRUISE_STRING ' mexec (ocp_hydro_matlab)'])

%add ocp_hydro_tools to path
MEXEC_G.mexec_source_root = fileparts(which('m_setup'));
cdir = pwd; pdir = MEXEC_G.mexec_source_root;
cd(pdir)
[s,c] = system('git log -1 | head -1');
if s==0 && length(c)>=15 && ~contains(c, 'fatal:') && strcmp(c(1:6),'commit')
    mexecs_version = [' last_commit_' c(8:15)];
else
    mexecs_version = '';
end
MEXEC_G.mexec_version = mexecs_version;
cd(cdir)
clear mexecs_version s c cdir pdir
if isempty(which('get_cropt')) || isempty(which('m_common'))
    disp(['adding ocp_hydro_matlab source' mexecs_version ' to path'])
    % add paths at and below source
    addpath(genpath(MEXEC_G.mexec_source_root))
    rmpath(genpath(fullfile(MEXEC_G.mexec_source_root,'.git')))
end

% set more defaults
MEXEC_G.PLATFORM_TYPE= 'ship';
MEXEC_G.MSTAR_TIME_ORIGIN = [1950 1 1 0 0 0];  % This setting should not normally be changed
MEXEC_G.COMMENT_DELIMITER_STRING = ' \n ';     % This setting should not normally be changed
% including some specific to the cruise
scriptname = mfilename; oopt = 'time_origin'; get_cropt %MDEFAULT_DATA_TIME_ORIGIN
scriptname = mfilename; oopt = 'setup_datatypes'; get_cropt %use_ix_ladcp and skipunderway set here (and used below)

% find and add (append) paths to other useful libraries
[~, dat] = version(); MEXEC_G.MMatlab_version_date = datenum(dat);
if ~isempty(MEXEC_G.other_programs_root)
    switch use_ix_ladcp
        case 'yes'
            MEXEC_G.ix_ladcp = 1;
            pathpath = 1;
        case 'query'
            disp('LDEO_IX and m_moorproc_toolbox/rodbload contain functions with the same names')
            pathpath = input('are you processing LADCP data (1),\n mooring/caldip data (2),\n or neither (0)?\n');
            if pathpath==1
                MEXEC_G.ix_ladcp = 1; %output 1-Hz CTD data for use by LDEO IX LADCP processing
            else
                MEXEC_G.ix_ladcp = 0;
            end
        otherwise %e.g. 'no'
            pathpath = 0;
            MEXEC_G.ix_ladcp = 0;
    end
    MEXEC_G = sw_addpath(MEXEC_G.other_programs_root,MEXEC_G,force_ext_software_versions);
else
    MEXEC_G.ix_ladcp = 0;
end

if strcmp(MEXEC_G.mexec_data_root, 'readonly')
    warning('MEXEC_G.mexec_data_root set to ''readonly''; you will be able to use mload(q)')
    return
end

% location processing and writing mexec files
if isempty(MEXEC_G.mexec_data_root)
    setup_dataroot_find
end
fprintf(1,'working in %s\n',MEXEC_G.mexec_data_root)

% Set path for directory with housekeeping files (in subdirectories version and history)
MEXEC_G.housekeeping_root = fullfile(MEXEC_G.mexec_data_root, 'mexec_housekeeping');
MEXEC_G.version_file_name = ['mstar_versionfile_' MEXEC_G.SITE '.mat'];  % This setting should not normally be changed

% set data directories within MEXEC_G.mexec_data_root
MEXEC_G.MDIRLIST = {
    'M_CTD' 'ctd'
    'M_CTD_CNV' fullfile('ctd','ASCII_FILES')
    'M_CTD_BOT' fullfile('ctd','ASCII_FILES')
    'M_CTD_WIN' fullfile('ctd','WINCH')
    'M_CTD_DEP' 'station_depths'
    'M_BOT_SAL' fullfile('ctd','BOTTLE_SAL')
    'M_BOT_OXY' fullfile('ctd','BOTTLE_OXY')
    'M_BOT_NUT' fullfile('ctd','BOTTLE_NUT')
    'M_BOT_PIG' fullfile('ctd','BOTTLE_PIG')
    'M_BOT_CO2' fullfile('ctd','BOTTLE_CO2')
    'M_BOT_CFC' fullfile('ctd','BOTTLE_CFC')
    'M_BOT_CH4' fullfile('ctd','BOTTLE_CH4')
    'M_BOT_CHL' fullfile('ctd','BOTTLE_SHORE')
    'M_BOT_ISO' fullfile('ctd','BOTTLE_SHORE')
    'M_SAM' 'ctd'
    'M_SBE35' fullfile('ctd','ASCII_FILES','SBE35')
    'M_SUM' 'collected_files'
    'M_VMADCP' 'vmadcp'
    };
if MEXEC_G.ix_ladcp
    MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST;
        {'M_LADCP' 'ladcp'
        'M_IX' fullfile('ladcp','ix')}];
end

% set things about the ship
MEXEC_G.PLATFORM_NUMBER = ['Cruise ' MEXEC_G.MSCRIPT_CRUISE_STRING];
switch MEXEC_G.MSCRIPT_CRUISE_STRING(1:2)
    case {'di' 'dy'}
        MEXEC_G.Mship = 'discovery';
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS Discovery';
    case 'jc'
        MEXEC_G.Mship = 'cook';
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS James Cook';
    case 'da'
        MEXEC_G.Mship = 'attenborough';
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS Sir David Attenborough';
    case 'jr'
        MEXEC_G.Mship = 'jcr';
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS James Clark Ross';
        MEXEC_G.Mrsh_machine = 'jruj';  % remote machine for rvs datapup command
    case 'kn'
        MEXEC_G.Mship = 'knorr';
        MEXEC_G.PLATFORM_IDENTIFIER = 'RV Knorr';
    case 'en'
        MEXEC_G.Mship = 'endeavor';
        MEXEC_G.PLATFORM_IDENTIFIER = 'RV Endeavor';
    otherwise
        merr = ['Ship ''' MEXEC_G.Mship ''' not recognised'];
        fprintf(2,'%s\n',merr);
        return
end

% add underway system information and directories
if skipunderway<2
    scriptname = 'ship'; oopt = 'default_nav'; get_cropt %set underway data system and best nav and heading streams
    switch MEXEC_G.Mshipdatasystem
        case 'techsas'
            MEXEC_G.uway_torg = datenum([1899 12 30 0 0 0]); % techsas time origin as a matlab datenum
            MEXEC_G.uway_root = fullfile(MEXEC_G.mexec_data_root, 'techsas', 'netcdf_files_links');
            if strncmp(computer, 'MAC', 3); MEXEC_G.uway_root = [MEXEC_G.uway_root '_mac']; end
            MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; {'M_TECHSAS' 'techsas'}];
        case 'scs'
            MEXEC_G.uway_torg = 0; % mexec parsing of SCS files converts matlab datenum, so no offset required
            MEXEC_G.uway_root = fullfile(MEXEC_G.mexec_data_root, 'scs_raw'); % scs raw data on logger machine
            MEXEC_G.uway_sed = fullfile(MEXEC_G.mexec_data_root, 'scs_sed'); % scs raw data on logger machine
            MEXEC_G.uway_mat = fullfile(MEXEC_G.mexec_data_root, 'scs_mat'); % local directory for scs converted to matlab
            MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST;
                {'M_SCSRAW' 'scs_raw'}
                {'M_SCSMAT' 'scs_mat'}
                {'M_SCSSED' 'scs_sed'}
                ];
        case 'rvdas'
            MEXEC_G.uway_torg = 0; % mrvdas parsing returns matlab dnum. No offset required.
            MEXEC_G.RVDAS.csvroot = fullfile(MEXEC_G.mexec_data_root, 'rvdas', 'rvdas_csv_tmp');
            MEXEC_G.RVDAS.user = 'rvdas';
            MEXEC_G.RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
            switch MEXEC_G.Mship
                case 'cook'
                    MEXEC_G.RVDAS.machine = 'rvdas.cook.local';
                    MEXEC_G.RVDAS.jsondir = ['/home/rvdas/ingester/sensorfiles/jcmeta/' MEXEC_G.MSCRIPT_CRUISE_STRING];
                case 'discovery'
                    MEXEC_G.RVDAS.machine = '192.168.62.12';
                    MEXEC_G.RVDAS.jsondir = ['/home/rvdas/ingester/sensorfiles/dymeta/' MEXEC_G.MSCRIPT_CRUISE_STRING];
                case 'attenborough'
                    MEXEC_G.RVDAS.machine = '';
                    MEXEC_G.RVDAS.jsondir = '';
            end
            if ismac
                MEXEC_G.RVDAS.psql_path = '/usr/local/bin/';
            else
                MEXEC_G.RVDAS.psql_path = ''; %'/usr/bin/' but on linux matlab finds it on path on its own
            end
    end
    MEXEC_G.uway_writeempty = 1; %if true, scs_to_mstar and techsas_to_mstar will write file even if no data in range
end

if skipunderway==0
    %create file connecting underway data directories and stream names
    %and create underway data directories (for processed data)
    ud_is_current = 0; ud_runs = 0; sud_runs = 0; ufail = 0;
    while ud_is_current == 0 && ud_runs == 0 && ufail == 0
        try
            [udirs, udcruise] = m_udirs;
            if strcmp(udcruise, MEXEC_G.MSCRIPT_CRUISE_STRING)
                ud_is_current = 1;
            else
                error('')
            end
        catch
            try
                ufile = fullfile(mps_pre, 'underway', 'm_udirs.m');
                if exist(ufile,'file'); delete(ufile); end
                m_setudir
                sud_runs = 1;
                try
                    [udirs, ~] = m_udirs;
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
    elseif ~isempty(udirs)
        MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; udirs(:,1:2)];
        a = mgetdir(MEXEC_G.default_navstream); l = length(MEXEC_G.mexec_data_root);
        MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; {'M_POS' a(l+2:end)}];
    end
    clear sud_runs ufail ud_* udirs udcruise mps_pre
end

MEXEC_G.Muse_version_lockfile = 'yes'; % takes value 'yes' or 'no'


%%%%%%%%%%%%%%%%%%%%%%%%%%% --------------------------- %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%   End of items to be edited on each site/cruise   %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% --------------------------- %%%%%%%%%%%%%%%%%%%%%%%%%%%

m_common

[MEXEC.status, MEXEC.uuser] = system('whoami');
if MEXEC.status ~= 0; MEXEC.uuser = 'user_not_identified'; end
[MEXEC.status, MEXEC.uname] = system('uname -n');
if MEXEC.status ~= 0; MEXEC.uname = 'unixname_not_identified'; end
if MEXEC_G.MMatlab_version_date>=datenum(2016,1,1)
    MEXEC.uuser = replace(MEXEC.uuser,newline,''); %strip newlines out of unix response
    MEXEC.uname = replace(MEXEC.uname,newline,''); %strip newlines out of unix response
else
    MEXEC.uuser = MEXEC.uuser(1:end-1);
    MEXEC.uname = MEXEC.uname(1:end-1);
end
MEXEC_G.MUSER = [MEXEC.uuser ' on ' MEXEC.uname];

% Check existence and availability of version lock file, if it is set to be used
if strcmp(MEXEC_G.Muse_version_lockfile,'yes')
    % Make version file and lock file if version file doesn't already exist.
    % Should only happen once per cruise or data installation
    MEXEC_G.Mhousekeeping_version = fullfile(MEXEC_G.housekeeping_root, 'version');
    if ~exist(MEXEC_G.Mhousekeeping_version,'dir')
        disp('making directory for tracking Mstar .nc data file versions')
        mkdir(MEXEC_G.Mhousekeeping_version);
    end
    MEXEC_G.VERSION_FILE = fullfile(MEXEC_G.Mhousekeeping_version, MEXEC_G.version_file_name);
    MEXEC.versfile = MEXEC_G.VERSION_FILE;
    MEXEC.simplelockfile = [MEXEC.versfile(1:end-4) '_lock'];
    if exist(MEXEC_G.VERSION_FILE,'file') ~= 2
        disp('Version file does not seem to exist; will create version file and version lock file')
        datanames = {};
        versions = [];
        save(MEXEC_G.VERSION_FILE,'datanames','versions');
        [us,~] = system(['touch ' MEXEC.simplelockfile]);
        if us == 0 && exist(MEXEC.simplelockfile,'file') == 2 % seems to be a successful create of lock file
            m = 'Version lock file touched successfully';
            fprintf(MEXEC_A.Mfidterm,'%s\n',m)
        end
    end
    clear us
    
    % might have to wait a bit to find it
    nsecwait = 0;
    while exist(MEXEC.simplelockfile,'file') ~= 2 && nsecwait<40
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
            ['  ' MEXEC_G.Mhousekeeping_version]
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
MEXEC_G.HISTORY_DIRECTORY = fullfile(MEXEC_G.housekeeping_root, 'history');
if exist(MEXEC_G.HISTORY_DIRECTORY,'dir') ~= 7
    disp('history directory does not seem to exist; will create it');
    mkdir(MEXEC_G.HISTORY_DIRECTORY);
end

clear MEXEC nsecwait
