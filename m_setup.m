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
%      mcruise (e.g. 'jc238')
%      MDEFAULT_DATA_TIME_ORIGIN (e.g. [2022 1 1 0 0 0]) -- but note this
%        is only necessary if reprocessing a cruise from before 2022
%      SITE_suf (e.g. 'atsea' or 'atnoc' to make SITE 'jc238_atsea' etc.)
%      mexec_data_root (e.g. '~/cruises/jc238/mcruise/data/')
%      underway (1) to set up underway data directories and test
%        database access, 2 to set up underway data directories only,
%        0 to skip
%      quiet (2) 0 to make both mexec_processing_scripts and
%        file_tools/mexec programs verbose, 1 to make only
%        mexec_processing_scripts verbose, 2 to minimise intermediate
%        output to screen
%      ladcp ('no') 'ix' to add LDEO IX LADCP processing scripts to
%        path; 0 to not add them -- this is to avoid interference between
%        scripts with the same names (e.g. 'julian.m') in different
%        toolboxes -- for example, ladcp should be set to 'no' for any
%        Matlab session where you want to process moored data using rodb
%        tools (as for RAPID and OSNAP/m_moorproc_toolbox)
%      sw location for programs like gsw (e.g. '~/programs/others/')
%
%  note: m_setup is not necessary if you only want to use mexec tools to
%    read/parse mexec-format files (e.g. use mload or mloadq, m_commontime
%    or timeunits_mstar_cf); if not reading in raw data/writing
%    mexec-processed files, simply add ocp_hydro_matlab and its
%    subdirectories to your path
%

clear MEXEC_G
global MEXEC_G

%defaults that can be overwritten by input structure: what are we
%processing, and where?
MEXEC_G.mcruise='ce26008';
MEXEC_G.data_time_origin_string = '2026-01-01 00:00:00'; %yyyy-MM-dd HH:mm:SS, usually midnight on 1 Jan of the start year of the cruise. do not change once processing for a given cruise has started!
MEXEC_G.SITE_suf = 'atnoc'; % common suffixes 'atsea', 'athome', '', etc.
MEXEC_G.mexec_data_root = '/noc/mpoc/eurogoship/ce26008/data'; %contains raw (e.g. ctd/ASCII_FILES) and will contain processed (e.g. ctd/*.nc) data
MEXEC_G.mexec_shell_scripts = '/data/pstar/programs/repos_github/mexec_exec/'; %optional; only relevant for on-ship processing to run bash scripts to sync data to Linux workstations
MEXEC_G.sw = '/noc/mpoc/eurogoship/programs'; %if the required GSW and Seawater toolboxes (and optionally gamma_n, and LDEO_IX) are not on the path already, they should be here
MEXEC_G.datatypes.ctd = 'sbe'; %sbe is currently the only option, in future add rbr
MEXEC_G.datatypes.uway = 'scs'; %underway data acquisition/storage system: rvdas is a PotgreSQL database (more recently also duplicated in NetCDF files***check); scs stores (minimally) parsed NMEA strings as either ASCII or NetCDF; techsas stores as NetCDF
MEXEC_G.datatypes.sadcp = 'codas'; %type of processed VMADCP data. codas is currently the only option; code could be added to read in IFREMER or BAS processed matlab files, etc.
MEXEC_G.datatypes.ladcp = 'ix'; %ix to process LADCP data with LDEO_IX, no if no LADCP data
MEXEC_G.datatypes.moor = 'no'; %or yes (affects what is added to path)
MEXEC_G.quiet = 2; %if 0, both file_tools/mexec programs and mexec_data_processing programs will be verbose; if 1, only the latter; if 2, neither
%not generally recommended to change the following, but you can
MEXEC_G.opt_cruise = ['opt_' MEXEC_G.mcruise '.m']; %this could be changed to temporarily try another options script but this is not recommended (as much as possible, a single options script should record all processing choices)
MEXEC_G.perms = [664; 775]; % permissions for files and directories
MEXEC_G.Muse_version_lockfile = 'yes'; %takes value 'yes' or 'no', 'yes' is recommended but if only one person is processing from one matlab session at any one time, it may not matter

%replace above with any user-supplied parameters for this session/run
if nargin>0 && isstruct(varargin{1})
    MGu = varargin{1};
    fn = fieldnames(MGu);
    fn0 = fieldnames(MEXEC_G);
    for fno = 1:length(fn)
        if ~ismember(fn{fno},fn0)
            MG0.(fn{fno}) = MGu.(fn{fno}); %store in case these are overwritten (***need to add test at end***)
        end
        MEXEC_G.(fn{fno}) = MGu.(fn{fno});
    end
else
    disp('no input arguments to m_setup; using defaults')
end
clear MGu

%%%%% with luck, you don't need to edit anything after this for standard installations %%%%%

MEXEC_G.SITE = [MEXEC_G.mcruise '_' MEXEC_G.SITE_suf];
MEXEC_G = rmfield(MEXEC_G, 'SITE_suf');
if ~isfield(MEXEC_G,'data_time_origin_string') || length(MEXEC_G.data_time_origin_string)~=19
    yr = input('cruise start year? (add MEXEC.data_time_origin near the top of m_setup to avoid this message in future)   ','s');
    MEXEC_G.data_time_origin_string = [yr '-01-01 00:00:00'];
end
MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = datevec(MEXEC_G.data_time_origin_string); %***check, does this always work

fprintf(1,'m_setup for %s mexec (ocp_hydro_matlab) to process\n', MEXEC_G.mcruise)
disp(MEXEC_G.datatypes)
fprintf(1,'using settings in %s\n', MEXEC_G.opt_cruise)

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
if isempty(which('mexec_defaults_all')) || isempty(which('m_common'))
    disp(['adding MEXEC_G.mexec_source_root to path, currently: ' MEXEC_G.mexec_version])
    % add paths at and below source
    addpath(genpath(MEXEC_G.mexec_source_root))
    rmpath(genpath(fullfile(MEXEC_G.mexec_source_root,'.git')))
end

% set more defaults
MEXEC_G.PLATFORM_TYPE= 'ship';
MEXEC_G.PLATFORM_NUMBER = ['Cruise ' upper(MEXEC_G.mcruise)];
switch MEXEC_G.mcruise(1:2)
    case {'di' 'dy'}
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS Discovery';
    case 'jc'
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS James Cook';
    case 'sd'
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS Sir David Attenborough';
    case 'jr'
        MEXEC_G.PLATFORM_IDENTIFIER = 'RRS James Clark Ross';
    case 'kn'
        MEXEC_G.PLATFORM_IDENTIFIER = 'RV Knorr';
    case 'en'
        MEXEC_G.PLATFORM_IDENTIFIER = 'RV Endeavor';
    case 'ce'
        MEXEC_G.PLATFORM_IDENTIFIER = 'RV Celtic Explorer';
    otherwise
        MEXEC_G.PLATFORM_IDENTIFIER = input('ship ID not recognised in cruise; enter platform identifier (ship long name), e.g. ''RRS James Cook'' ','s');
        warning('add case to m_setup'); pause(0.1)
end
MEXEC_G.MSTAR_TIME_ORIGIN = [1950 1 1 0 0 0];  % This setting should not
% normally be changed % not used any more
MEXEC_G.COMMENT_DELIMITER_STRING = ' \n ';     % This setting should not normally be changed
if strcmp(MEXEC_G.datatypes.sadcp,'uhdas') || strcmp(MEXEC_G.datatypes.sadcp,'vmdas')
    %if system environment variables were used to set datatypes, the acquisition system may be specified, but what matters at this stage (reading in processed data) is the processing system. we usually process both uhdas and vmdas data with codas.
    warning('setting sadcp processing system: MEXEC_G.datatypes.sadcp = ''codas'';')
    MEXEC_G.datatypes.sadcp = 'codas';
end

% cruise-specific settings
if ~exist(MEXEC_G.opt_cruise,'file')
    create_opt_cruise
end
run(MEXEC_G.opt_cruise) 

% checks if external libraries are on path, and if processing ladcp or moored checks which to avoid conflicts
sw_checkpath

% location processing and writing mexec files
if isempty(MEXEC_G.mexec_data_root) || ~exist(MEXEC_G.mexec_data_root,'dir')
    MEXEC_G.mexec_data_root = input('input path to data directory (e.g. ~/cruises/ce26008/data/) where processed data will be written   ','s');
else
    fprintf(1,'working in %s\n',MEXEC_G.mexec_data_root)
end

% Set path for directory with housekeeping files (in subdirectories version and history)
housekeeping_root = fullfile(MEXEC_G.mexec_data_root, 'mexec_housekeeping');

if ~strcmp(MEXEC_G.datatypes.uway,'no')
    %***still need to configure where directories are for some applications***
    try
        mutv = mudefine;
        fprintf(1,'using cached %s stream/table list & mstar lookup\n',MEXEC_G.Mshipdatasystem)
    catch
        try
            fprintf(1,'regenerating mstar-stream/table lookup by running mudefine(''redo'')\n')
            mutv = mudefine('redo');
            fprintf(1,'reloaded underway stream/table definitions\n')
        catch
            warning('skipping underway data setup')
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%% --------------------------- %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%   End of items to be edited on each site/cruise   %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% --------------------------- %%%%%%%%%%%%%%%%%%%%%%%%%%%

m_common

[MEXEC.status, MEXEC.uuser] = system('whoami');
if MEXEC.status ~= 0; MEXEC.uuser = 'user_not_identified'; end
[MEXEC.status, MEXEC.uname] = system('uname -n');
if MEXEC.status ~= 0; MEXEC.uname = 'unixname_not_identified'; end
[~, dat] = version(); MEXEC_G.MMatlab_version_date = datenum(dat);
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
        [us,~] = system(['touch ''' MEXEC.simplelockfile '''']); mfixperms(MEXEC.simplelockfile);
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

function sw_checkpath
%
% add external software toolboxes if they are in MEXEC_G.sw
%

m_common

slibs.seawater = 'sw_svel';
slibs.gsw_matlab = 'gsw_CT_from_t';
if strcmp(MEXEC_G.datatypes.ladcp,'ix')
    l = 1;
    if strcmp(MEXEC_G.datatypes.moor,'yes')
        l = input('processing ladcp (1) or moored (2) data this session?  ');
    end
    if l==1
        %check paths for LDEO_IX below
        slibs.LDEO_IX = 'getinv';
    else
        %if LDEO_IX is on path, remove because there are conflicts with
        %names of functions in mooring toolbox
        prm = which('getinv');
        if ~isempty(prm)
            rmpath(genpath(prm))
        end
    end
end
slibs.gamma_n = 'eos80_legacy_gamma_n';
%slibs.m_map = 'm_coast';

ls = fieldnames(slibs);
for no = 1:length(ls)
    w = which(slibs.(ls{no}));
    if isempty(w)
        warning('%s not found, add to path',ls{no})
    end
end

