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
MEXEC_G.MSCRIPT_CRUISE_STRING='ce26008';
MEXEC_G.SITE_suf = 'atsea'; % common suffixes 'atsea', 'athome', '', etc.
MEXEC_G.mexec_data_root = '/data/pstar/projects/goship/cruises/ce26008/data'; %if empty, will search for cruise directory near current directory and near home directory
MEXEC_G.mexec_shell_scripts = '/data/pstar/programs/repos_github/mexec_exec/';
MEXEC_G.sw = '/data/pstar/programs';
MEXEC_G.perms = [664; 775]; % permissions for files and directories
MEXEC_G.quiet = 2; %if 0, both file_tools/mexec programs and mexec_processing_scripts will be verbose; if 1, only the latter; if 2, neither
MEXEC_G.Muse_version_lockfile = 'yes'; % takes value 'yes' or 'no'
MEXEC_G.datatypes.ctd = 'sbe'; %currently the only option
MEXEC_G.datatypes.uway = 'auto'; %auto sets to rvdas, techsas, or scs depending on ship
MEXEC_G.datatypes.sadcp = 'uhdas'; %or vmdas
MEXEC_G.datatypes.ladcp = 'ix'; %or ix to process LADCP data with LDEO_IX
MEXEC_G.datatypes.moor = 'no'; %or yes (affects what is added to path)

%replace with user-supplied parameters for this session/run
if nargin>0 && isstruct(varargin{1})
    MGu = varargin{1};
    fn = fieldnames(MGu);
    fn0 = fieldnames(MEXEC_G);
    for fno = 1:length(fn)
        if ~ismember(fn{fno},fn0)
            MG0.(fn{fno}) = MGu.(fn{fno}); %store in case these are overwritten (test at end***)
        end
        MEXEC_G.(fn{fno}) = MGu.(fn{fno});
    end
else
    disp('no input arguments to m_setup; using defaults')
end
clear MGu

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
MEXEC_G.PLATFORM_NUMBER = ['Cruise ' upper(MEXEC_G.MSCRIPT_CRUISE_STRING)];
opt1 = 'ship'; mexec_defaults_all
MEXEC_G.MSTAR_TIME_ORIGIN = [1950 1 1 0 0 0];  % This setting should not
% normally be changed % not used any more
MEXEC_G.COMMENT_DELIMITER_STRING = ' \n ';     % This setting should not normally be changed
if strcmp(MEXEC_G.datatypes.uway,'auto')
    %look up which underway data system to use based on ship
    MEXEC_G.datatypes.uway = MEXEC_G.Mshipdatasystem;
elseif strcmp(MEXEC_G.datatypes.uway,'no')
    MEXEC_G.datatypes = rmfield(MEXEC_G.datatypes,'uway');
end

% cruise-specific settings
opt1 = 'setup'; opt2 = 'time_origin'; get_cropt %MDEFAULT_DATA_TIME_ORIGIN
if ~isfield(MEXEC_G,'MDEFAULT_DATA_TIME_ORIGIN')
    error('you must set MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN in opt_{cruise}.m under opt1=''setup''; opt2=''time_origin''')
end
opt1 = 'setup'; opt2 = 'setup_datatypes'; get_cropt

% find and add (append) paths to other libraries used in processing; also
% checks if processing ladcp or moored (if relevant) to avoid conflicts
sw_addpath

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
        try
            fprintf(1,'regenerating mstar-table lookup by running mrdefine(''redo'')\n')
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
            warning('skipping underway data setup')
        end
    end
end

% set data directories within MEXEC_G.mexec_data_root
opt1 = 'setup'; opt2 = 'mdirlist'; get_cropt


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

function sw_addpath
%
% add external software toolboxes specified by table ld to path
%
% defaults to finding the highest version available under swroot,
%   unless force_vers is a structure
%     (e.g. force_vers.gsw_matlab = 'gsw_matlab_v3_06_16';),
%   in which case uses any hard-coded versions listed there

m_common

slibs.seawater = 'sw_svel';
slibs.gsw_matlab = 'gsw_CT_from_t';
if strcmp(MEXEC_G.datatypes.ladcp,'ix')
    l = 1;
    if strcmp(MEXEC_G.datatypes.moor,'yes')
        l = input('processing ladcp (1) or moored (2) data this session?  ');
    end
    if l==1
        %add paths for LDEO_IX below
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
        ld = sw_vers_parse(ls{no}, slibs.(ls{no}), MEXEC_G.sw);
        if ~isempty(ld) && exist(ld,'dir')
            addpath(genpath(ld))
            fprintf(1,'added to path: %s\n',ld)
        else
            keyboard
            warning('%s not found',ls{no})
        end
    else
        w = fileparts(w);
        fprintf(1,'%s already on path\n',w)
    end
end

function ld = sw_vers_parse(l, f, rootdir)
% find highest version of a library in a given directory

%find candidates
d = dir(fullfile(rootdir,[l '*/' f '.m']));
if isempty(d)
    [s,d] = system(sprintf('find %s/ -name ''%s.m''',rootdir,f));
    if s==0 && ~isempty(d)
        d = cellfun(@(x) fileparts(x), strsplit(d,'\n'), 'UniformOutput', false);
        d = d(~cellfun('isempty',d));
    end
else
    d = {d.folder};
end

if isempty(d)
    ld = [];
elseif isscalar(d)
    ld = d{1};
else
    [lp,ln,~] = fileparts(d);
    %get version numbers to find the most recent
    b = cellfun(@(x) replace(replace(x,{l;'_ver';'_v'},''),{'_';'.'},' '), ln, 'UniformOutput', false);
    c = cellfun(@(x) str2num(x), b, 'UniformOutput', false); %a cell array of numeric vectors of different lengths
    l = cellfun(@(x) length(x), c);
    ii = find(l>0);
    if isempty(ii) %all contain letters, so do alphanumeric sort
        [~,ind] = sort(b); ind = ind(end);
    else %ignore any letters and sort by numbers
        if max(l)==1 %single level
            [~,ii1] = max(cell2mat(c(ii)));
            ind = ii(ii1);
        else %put levels into matrix to find highest version
            g = zeros(max(l),length(c));
            for n = 1:max(l)
                g(n,ii) = cellfun(@(x) [x(n)], c(ii));
                n = n+1;
                ii = find(l>=n);
            end
            n = 1; ind = 1:length(c);
            while n<=size(g,1) && length(ind)>1
                ii = find(g(n,:)==max(g(n,:)));
                ind = ind(ii); g = g(:,ii);
                n = n+1;
            end
        end
    end

    %use highest version
    if ~isscalar(ind)
        ind = ind(end);
    end
    ld = fullfile(lp{ind},ln{ind});

end
