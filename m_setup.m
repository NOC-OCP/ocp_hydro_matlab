function m_setup(varargin)
%  m_setup: to be run before attempting any mexec processing of
%  cruise data; sets up environment (global variables and paths)
%
%  for a given cruise, you can configure the first block of code below
%  initially. the first time this is run, the cruise options file will be
%  initialised, and other processing parameters should be set there  
% 
%  for later processing you may then just change the first block of code,
%  or at most down to line containing "End of items to be edited on each
%  site/cruise" 
%
%
%  you can also pass selected fields (below) to MEXEC_G by passing a
%  structure as input, e.g.:
%    >> m_setup(MEXEC_G_user)
%    these may be useful if you want to reprocess an old cruise's data with
%    a newer branch's software.
%      mcruise (e.g. 'jc238')
%      data_time_origin_string (e.g. '2022-01-01 00:00:00)
%      SITE_suf (e.g. 'atsea' or 'atnoc' to make SITE 'jc238_atsea' etc.)
%      data_root (e.g. '~/cruises/jc238/mcruise/data/')
%      mexec_shell_scripts (if you are using them to sync data at sea,
%        specify the path) 
%      datatypes is itself a structure with fields specifying the types of
%        data available for processing: 
%        ctd ('sbe') or 'rbr'
%        nisk ('sbe')
%        tref ('sbe35') or 'no'
%        sadcp ('codas') or 'no'
%        ladcp ('ix') or 'no'
%        uway ('rvdas', 'scs', 'techsas', or 'no')
%      quiet (2) 0 to make both mexec_processing_scripts and
%        file_tools/mexec programs verbose, 1 to make only
%        mexec_processing_scripts verbose, 2 to minimise intermediate
%        output to screen
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
%MEXEC_G.mcruise = 'dy214';
%MEXEC_G.mcruise = 'mdexp1';
MEXEC_G.data_time_origin_string = '2026-01-01 00:00:00'; %yyyy-MM-dd HH:mm:SS, usually midnight on 1 Jan of the start year of the cruise. do not change once processing for a given cruise has started!
MEXEC_G.SITE_suf = 'atnoc'; % common suffixes 'atsea', 'athome', '', etc.
%MEXEC_G.SITE_suf = 'test';
%MEXEC_G.data_root = '/noc/mpoc/eurogoship/ce26008/data'; %contains raw (e.g. ctd/ASCII_FILES) and will contain processed (e.g. ctd/*.nc) data
%MEXEC_G.data_root = '/data/pstar/projects/osnap/cruises/dy214/data';
MEXEC_G.data_root = '/data/pstar/projects/goship/cruises/ce26008/data';
if strcmp(MEXEC_G.SITE_suf,'atsea')
    MEXEC_G.mexec_shell_scripts = '/data/pstar/programs/repos_github/mexec_exec/'; %optional; only relevant for on-ship processing to run bash scripts to sync data to Linux workstations
end
MEXEC_G.datatypes.ctd = 'sbe'; %sbe is currently the only option for CTD sensors, in future add rbr
MEXEC_G.datatypes.nisk = 'sbe'; %sbe .bl or .btl files
MEXEC_G.datatypes.tref = 'sbe35'; %there is an SBE35 deep standards thermometer, or 'no' if not
%MEXEC_G.datatypes.tref = 'no';
MEXEC_G.datatypes.uway = 'scs'; %underway data acquisition/storage system: rvdas is a PotgreSQL database (more recently also duplicated in NetCDF files***check); scs stores (minimally) parsed NMEA strings as either ASCII or NetCDF; techsas stores as NetCDF
%MEXEC_G.datatypes.uway = 'rvdas';
MEXEC_G.datatypes.sadcp = 'codas'; %type of processed VMADCP data. codas is currently the only option; code could be added to read in IFREMER or BAS processed matlab files, etc.
MEXEC_G.datatypes.ladcp = 'ix'; %ix to process LADCP data with LDEO_IX, no if no LADCP data
MEXEC_G.datatypes.moor = 'no'; %or yes (affects what is added to path)
%MEXEC_G.datatypes.moor = 'yes';
MEXEC_G.quiet = 2; %if 0, both file_tools/mexec programs and mexec_data_processing programs will be verbose; if 1, only the latter; if 2, neither
%not generally recommended to change the following, but you can
MEXEC_G.opt_cruise = ['opt_' MEXEC_G.mcruise '.m']; %change temporarily to try another options script (as much as possible, a single options script should record all processing choices)
MEXEC_G.perms = [664; 775]; % permissions for files and directories (n*x systems), keep rwX for at least user + group to allow multiple users to modify the processed files
MEXEC_G.Muse_version_lockfile = 'yes'; %takes value 'yes' or 'no', 'yes' is recommended but if only one person is processing from one matlab session at any one time, it may not matter

%replace above with any user-supplied parameters for this session/run
if nargin>0 && isstruct(varargin{1})
    MGu = varargin{1};
    fnu = fieldnames(MGu);
    for fno = 1:length(fnu)
        if isfield(MEXEC_G,fnu{fno}) && isstruct(MEXEC_G.(fnu{fno}))
            %datatypes: don't overwrite those that are not in MGu
            fn2 = fieldnames(MGu.(fnu{fno}));
            for fno2 = 1:length(fn2)
                MEXEC_G.(fnu{fno}).(fn2{fno2}) = MGu.(fnu{fno}).(fn2{fno2});
            end
        else
            MEXEC_G.(fnu{fno}) = MGu.(fnu{fno});
        end
    end
end
clear MGu

%%%%% with luck, you don't need to edit anything after this for standard installations %%%%%

MEXEC_G.SITE = [MEXEC_G.mcruise '_' MEXEC_G.SITE_suf];
MEXEC_G = rmfield(MEXEC_G, 'SITE_suf');
if ~isfield(MEXEC_G,'data_time_origin_string') || length(MEXEC_G.data_time_origin_string)~=19
    yr = input('cruise start year? (add MEXEC.data_time_origin_string near the top of m_setup to avoid this message in future)   ','s');
    MEXEC_G.data_time_origin_string = [yr '-01-01 00:00:00'];
end
MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = datevec(MEXEC_G.data_time_origin_string); %***check, does this always work
if strcmp(MEXEC_G.datatypes.sadcp,'uhdas') || strcmp(MEXEC_G.datatypes.sadcp,'vmdas')
    %if system environment variables were used to set datatypes, the
    %acquisition system may be specified, but what matters for
    %ocp_hydro_matlab is the processing system. codas is our default for
    %processing either uhdas or vmdas data.   
    fprintf(1,'MEXEC_G.datatypes.sadcp listed data acquisition system ''%s'';\n replacing with data processing system ''%s''\n',MEXEC_G.datatypes.sadcp,'codas')
    MEXEC_G.datatypes.sadcp = 'codas';
end

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
MEXEC_G.PLATFORM_IDENTIFIER = ship_codes(MEXEC_G.mcruise);
MEXEC_G.MSTAR_TIME_ORIGIN = [1950 1 1 0 0 0];  % This setting should not
% normally be changed % not used any more
MEXEC_G.COMMENT_DELIMITER_STRING = ' \n ';     % This setting should not normally be changed

% cruise-specific settings
if ~exist(MEXEC_G.opt_cruise,'file')
    create_opt_cruise
    %also runs test at the end
else
    %just test the syntax
    opt1 = 'test'; run(MEXEC_G.opt_cruise) 
end

% checks if external libraries are on path, and if processing ladcp or moored checks which to avoid conflicts
sw_checkpath

% location processing and writing mexec files
if isempty(MEXEC_G.data_root) || ~exist(MEXEC_G.data_root,'dir')
    MEXEC_G.data_root = input('input path to data directory (e.g. ~/cruises/ce26008/data/) where processed data will be written   ','s');
else
    fprintf(1,'working in %s\n',MEXEC_G.data_root)
end

% Set path for directory with housekeeping files (in subdirectories version and history)
housekeeping_root = fullfile(MEXEC_G.data_root, 'mexec_housekeeping');

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
% check if required software toolboxes are on path, and also try to avoid
% conflicts between m_moorproc_toolbox and LDEO_IX 

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

