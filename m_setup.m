function m_setup(varargin)
%  m_setup: to be run before attempting any mexec processing of
%  cruise data; sets up environment (global variables and paths)
%
%  for a given cruise, you can configure the first block of code below
%  initially, as well as setting up the cruise options file
%  (opt_{cruise}.m, e.g. opt_jc238.m)
%  
%  for later processing you may then just first block of code, or at most down to line containing "End of
%  items to be edited on each site/cruise" 
%  
%
%  you can also pass selected fields (below) to MEXEC_G by passing a
%  structure as input: 
%    >> m_setup(MEXEC_G_user)
%    these may be useful if you want to reprocess an old cruise's data with
%    a newer branch's software.  
%      MSCRIPT_CRUISE_STRING (e.g. 'jc238')
%      MDEFAULT_DATA_TIME_ORIGIN (e.g. [2022 1 1 0 0 0]) -- but note this
%        is only necessary if reprocessing a cruise from before 2022
%      SITE_suf (e.g. 'atsea' or 'atnoc' to make SITE 'jc238_atsea' etc.)
%      other_programs_root (e.g. '~/programs/others/')
%      mexec_data_root (e.g. '~/cruises/jc238/mcruise/data/')
%      raw_underway (1) to set up underway data directories and test
%        database access -- set to 0 if not on ship unless a backup is
%        available*** -- not necessary if only reading in mexec-processed
%        underway data (e.g. plotting TSG data that has already been saved
%        in mstar files)
%      quiet (2) 0 to make both mexec_processing_scripts and
%        file_tools/mexec programs verbose, 1 to make only
%        mexec_processing_scripts verbose, 2 to minimise intermediate
%        output to screen 
%      ix_ladcp (no default) 1 to add LDEO IX LADCP processing scripts to
%        path; 0 to not add them -- this is to avoid interference between
%        scripts with the same names (e.g. 'julian.m') in different
%        toolboxes -- for example, ix_ladcp should be set to 0 for any 
%        Matlab session where you want to process moored data using rodb
%        tools (as for RAPID and OSNAP/m_moorproc_toolbox)
%
%  optional output path_choose specifies whether LADCP programs have been
%    added to the path or not
%
%  note: m_setup is not necessary if you only want to use mexec tools to
%    read/parse mexec-format files (e.g. use mload or mloadq, m_commontime
%    or timeunits_mstar_cf); if not reading in raw data/writing
%    mexec-processed files, simply add ocp_hydro_matlab and its
%    subdirectories to your path 
%

clear MEXEC_G
global MEXEC_G

%defaults: what are we processing and where? 
MEXEC_G.MSCRIPT_CRUISE_STRING='dy186';
MEXEC_G.ix_ladcp = 0; %set to 0 to not add ldeo_ix paths (for instance if processing mooring data)
MEXEC_G.SITE_suf = 'atnoc'; % common suffixes 'atsea', 'athome', '', etc.
MEXEC_G.perms = [664; 775]; % permissions for files and directories
MEXEC_G.mexec_data_root = '/noc/mpoc/rpdmoc/cruise_data/dy186/mcruise/data';%if empty, will search for cruise directory near current directory and near home directory
MEXEC_G.other_programs_root = '/noc/mpoc/eurogoship/programs/others/'; 
MEXEC_G.mexec_data_root = '/Users/yfiring/projects/rpdmoc/cruise_data/dy186/mcruise/data';%if empty, will search for cruise directory near current directory and near home directory
MEXEC_G.other_programs_root = '/Users/yfiring/programs/others/'; 
MEXEC_G.mexec_shell_scripts = '/data/pstar/programs/gitvcd/mexec_exec/';
MEXEC_G.quiet = 2; %if 0, both file_tools/mexec programs and mexec_processing_scripts will be verbose; if 1, only the latter; if 2, neither
MEXEC_G.raw_underway = 0; %if 0, skip the rvdas setup (use saved mrtables)
MEXEC_G.Muse_version_lockfile = 'yes'; % takes value 'yes' or 'no'
force_vers = 0; %set to 1 to use hard-coded version numbers for e.g. LADCP software, gsw, gamma_n (otherwise finds highest version number available)

%replace with user-supplied parameters for this session/run
if nargin>0 && isstruct(varargin{1})
    MEXEC_G_user = varargin{1};
    fn = fieldnames(MEXEC_G_user);
    fn0 = fieldnames(MEXEC_G);
    for fno = 1:length(fn)
        if ~ismember(fn{fno},fn0)
            warning('setting unset %s in MEXEC_G; may be overwritten below',fn{fno})
        end
        MEXEC_G.(fn{fno}) = MEXEC_G_user.(fn{fno});
    end
else
    disp('no input arguments to m_setup; using defaults')
end
clear MEXEC_G_user

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
    mexecs_version = [c(8:15) ' (last commit)'];
else
    mexecs_version = '';
end
MEXEC_G.mexec_version = mexecs_version;
cd(cdir)
clear mexecs_version s c cdir pdir
if isempty(which('get_cropt')) || isempty(which('m_common'))
    disp(['adding MEXEC_G.mexec_source_root to path, currently: ' MEXEC_G.mexec_version])
    % add paths at and below source
    addpath(genpath(MEXEC_G.mexec_source_root))
    rmpath(genpath(fullfile(MEXEC_G.mexec_source_root,'.git')))
end

% set more defaults
MEXEC_G.PLATFORM_TYPE= 'ship';
MEXEC_G.MSTAR_TIME_ORIGIN = [1950 1 1 0 0 0];  % This setting should not
% normally be changed % not used any more
MEXEC_G.COMMENT_DELIMITER_STRING = ' \n ';     % This setting should not normally be changed
% including some specific to the cruise
opt1 = 'setup'; opt2 = 'time_origin'; get_cropt %MDEFAULT_DATA_TIME_ORIGIN
if ~isfield(MEXEC_G,'MDEFAULT_DATA_TIME_ORIGIN')
    error('you must set MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN in opt_{cruise}.m under opt1=''setup''; opt2=''time_origin''')
end

% find and add (append) paths to other useful libraries
[~, dat] = version(); MEXEC_G.MMatlab_version_date = datenum(dat);
if ~isempty(MEXEC_G.other_programs_root)
    MEXEC_G.exsw_paths = sw_addpath(MEXEC_G.other_programs_root,'force_vers',force_vers,'addladcp',MEXEC_G.ix_ladcp);
end

% location processing and writing mexec files
if isempty(MEXEC_G.mexec_data_root)
    setup_dataroot_find
end
fprintf(1,'working in %s\n',MEXEC_G.mexec_data_root)

% Set path for directory with housekeeping files (in subdirectories version and history)
housekeeping_root = fullfile(MEXEC_G.mexec_data_root, 'mexec_housekeeping');

% set data directories within MEXEC_G.mexec_data_root
MEXEC_G.MDIRLIST = {
    'M_CTD' 'ctd'
    'M_CTD_CNV' fullfile('ctd','ASCII_FILES')
    'M_CTD_BOT' fullfile('ctd','ASCII_FILES')
    'M_CTD_WIN' fullfile('ctd','WINCH')
    'M_CTD_DEP' 'station_information'
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
opt1 = 'setup'; opt2 = 'mdirlist'; get_cropt

% set things about the ship
MEXEC_G.PLATFORM_NUMBER = ['Cruise ' upper(MEXEC_G.MSCRIPT_CRUISE_STRING)];
switch MEXEC_G.MSCRIPT_CRUISE_STRING(1:2)
    case {'di' 'dy'}
        MEXEC_G.Mship = 'discovery';
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS Discovery';
    case 'jc'
        MEXEC_G.Mship = 'cook';
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS James Cook';
    case 'sd'
        MEXEC_G.Mship = 'sda';
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
        merr = ['Ship ''' MEXEC_G.MSCRIPT_CRUISE_STRING(1:2) ''' not recognised, underway system will not be set up'];
        %fprintf(2,'%s\n',merr);
        %return
        warning(merr)
        MEXEC_G.Mship = '';
        MEXEC_G.PLATFORM_IDENTIFIER = '';
end

switch MEXEC_G.Mship
    case 'sda'
        MEXEC_G.Mshipdatasystem = 'rvdas';
    case {'cook','discovery'}
        if MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)>=2021
            MEXEC_G.Mshipdatasystem = 'rvdas';
        else
            MEXEC_G.Mshipdatasystem = 'techsas';
        end
    case {'di'}
            MEXEC_G.Mshipdatasystem = 'techsas';
    case {'jcr','knorr','endeavor'}
                    MEXEC_G.Mshipdatasystem = 'scs';
    otherwise
        warning('ship underway data system not set')
        MEXEC_G.Mshipdatasystem = '';
end

%underway directories
try
    switch MEXEC_G.Mshipdatasystem
        case 'rvdas'
            mrtv = mrdefine;
        case 'scs'
            mrtv = msdefine; %***
        case 'techsas'
            mrtv = mtdefine; %***
        end
        fprintf(1,'using cached %s table list / mstar lookup\n',MEXEC_G.Mshipdatasystem)
catch
    if MEXEC_G.raw_underway
        try
            fprintf(1,'regenerating mstar-table lookup by running mrdefine(''redo'')')
            switch MEXEC_G.Mshipdatasystem
                case 'rvdas'
                    mrtv = mrdefine('redo');
                case 'scs'
                    mrtv = msdefine('redo');
                case 'techsas'
                    mrtv = mtdefine('redo');
            end
            fprintf(1,'reloaded table definitions\n')
        catch
            warning('skipping underway data setup and directories')
        end
    else
        warning('skipping underway data directories')
    end
end
if exist('mrtv','var')
    MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; ...
        [cellfun(@(x) ['M_' upper(x)], mrtv.mstarpre, 'UniformOutput', false), ...
        mrtv.mstardir]];
    [~,ii] = unique(MEXEC_G.MDIRLIST(:,1),'stable');
    MEXEC_G.MDIRLIST = MEXEC_G.MDIRLIST(ii,:);
end


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
    housekeeping_version = fullfile(housekeeping_root, 'version');
    if ~exist(housekeeping_version,'dir')
        disp('making directory for tracking Mstar .nc data file versions')
        mkdir(housekeeping_version); mfixperms(housekeeping_version, 'dir');
    end
    version_file_name = ['mstar_versionfile_' MEXEC_G.SITE '.mat'];  % This setting should not normally be changed
    MEXEC_G.VERSION_FILE = fullfile(housekeeping_version, version_file_name);
    MEXEC.versfile = MEXEC_G.VERSION_FILE;
    MEXEC.simplelockfile = [MEXEC.versfile(1:end-4) '_lock'];
    if exist(MEXEC_G.VERSION_FILE,'file') ~= 2 || exist(MEXEC.simplelockfile,'file') ~= 2
        disp('Version file does not seem to exist; will create version file and version lock file')
        datanames = {};
        versions = [];
        save(MEXEC_G.VERSION_FILE,'datanames','versions'); mfixperms(MEXEC_G.VERSION_FILE);
        [us,ur] = system(['touch ''' MEXEC.simplelockfile '''']); mfixperms(MEXEC.simplelockfile);
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
            ['  ' housekeeping_version]
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
MEXEC_G.HISTORY_DIRECTORY = fullfile(housekeeping_root, 'history');
if exist(MEXEC_G.HISTORY_DIRECTORY,'dir') ~= 7
    disp('history directory does not seem to exist; will create it');
    mkdir(MEXEC_G.HISTORY_DIRECTORY); mfixperms(MEXEC_G.HISTORY_DIRECTORY,'dir');
end

