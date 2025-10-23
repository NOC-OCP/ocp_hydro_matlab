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
%      ix_ladcp (no default) 1 to add LDEO IX LADCP processing scripts to
%        path; 0 to not add them -- this is to avoid interference between
%        scripts with the same names (e.g. 'julian.m') in different
%        toolboxes -- for example, ix_ladcp should be set to 0 for any
%        Matlab session where you want to process moored data using rodb
%        tools (as for RAPID and OSNAP/m_moorproc_toolbox)
%      external_sw.force_vers = []
%      external_sw.programs_root (e.g. '~/programs/others/')
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
MEXEC_G.MSCRIPT_CRUISE_STRING='dy180';
MEXEC_G.ix_ladcp = 1; %set to 0 to not add ldeo_ix paths (for instance if processing mooring data)
MEXEC_G.SITE_suf = 'atnoc'; % common suffixes 'atsea', 'athome', '', etc.
MEXEC_G.perms = [664; 775]; % permissions for files and directories
MEXEC_G.mexec_data_root = '/Users/yfiring/cruises/dy180/mcruise/data'; %if empty, will search for cruise directory near current directory and near home directory
MEXEC_G.mexec_shell_scripts = '/data/pstar/repos/NOC-OCP/mexec_exec/';
MEXEC_G.quiet = 2; %if 0, both file_tools/mexec programs and mexec_processing_scripts will be verbose; if 1, only the latter; if 2, neither
MEXEC_G.raw_underway = 2; %if 0, skip the rvdas setup
MEXEC_G.Muse_version_lockfile = 'yes'; % takes value 'yes' or 'no'
exsw_force_vers = []; %or this can be a structure e.g. force_swvers.gamma_n = 'eos80_legacy_gamma_n'; force_swvers.LDEO_IX = 'LDEO_IX_13';
exsw_rootdir = {'/Users/yfiring/programs/others/';'/Users/yfiring/repos/athurnherr/'}; %where do gsw etc. toolboxes live?

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
opt1 = 'setup'; opt2 = 'setup_datatypes'; get_cropt

% find and add (append) paths to other useful libraries
if exist('exsw_rootdir','var') && ~isempty(exsw_rootdir)
    ld = {'seawater', '';...
        'gsw_matlab', '';...
        'gamma_n', '';...
        'm_map', '';...
        'LDEO_IX', ''};
    ns = size(ld,1);
    if iscell(exsw_rootdir)
        if length(exsw_rootdir)==ns
            ld = [ld exsw_rootdir];
        else
            ld = [ld repmat(exsw_rootdir(1),ns,1)];
            if length(exsw_rootdir)==2
                ld(end,3) = exsw_rootdir(2);
            end
        end
    else
        ld = [ld repmat({exsw_rootdir},ns,1)];
    end
    if ~MEXEC_G.ix_ladcp
        ld(end,:) = [];
    end
    ld = cell2table(ld,'VariableNames',{'lib','vers','predir'});
    esw = sw_addpath(ld, exsw_force_vers);
    if isfield(MEXEC_G,'exsw_paths') && ~isempty(MEXEC_G.exsw_paths)
        MEXEC_G.exsw_paths = union(MEXEC_G.exsw_paths, esw);
    else
        MEXEC_G.exsw_paths = esw;
    end
end

% location processing and writing mexec files
if isempty(MEXEC_G.mexec_data_root)
    %look for base directory for this cruise: first in path of current
    %directory, then in home directory
    d = pwd;
    cd('~'); hd = pwd; cd(d);
    ii = strfind(d, MEXEC_G.MSCRIPT_CRUISE_STRING);
    if ~isempty(ii)
        d = d(1:ii-1);
        mpath = {fullfile(d,MEXEC_G.MSCRIPT_CRUISE_STRING,'mcruise','data');
            fullfile(d,MEXEC_G.MSCRIPT_CRUISE_STRING,'data')
            fullfile(d,MEXEC_G.MSCRIPT_CRUISE_STRING)};
    else
        mpath = {};
    end
    mpath = [mpath;
        fullfile(hd,MEXEC_G.MSCRIPT_CRUISE_STRING,'mcruise','data');
        fullfile(hd,MEXEC_G.MSCRIPT_CRUISE_STRING,'data')
        fullfile(hd,MEXEC_G.MSCRIPT_CRUISE_STRING)
        fullfile(hd,'cruises',MEXEC_G.MSCRIPT_CRUISE_STRING,'mcruise','data')];
    fp = 0; n=1;
    while fp==0 && n<=length(mpath)
        if exist(mpath{n},'dir')==7
            MEXEC_G.mexec_data_root = mpath{n};
            fp = 1;
        end
        n=n+1;
    end
    if fp==0 %none found; query
        disp('enter full path of cruise data processing directory')
        disp('e.g. /local/users/pstar/jc238/mcruise/data')
        MEXEC_G.mexec_data_root = input('  ', 's');
        disp('if you want, you can modify m_setup.m to hard-code this directory into MEXEC_G.mexec_data_root')
    else
        disp(['MEXEC data root: ' MEXEC_G.mexec_data_root])
    end
    clear mpath d fp n ii
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
    'M_BOT_SAL' fullfile('bottle_samples','BOTTLE_SAL')
    'M_BOT_OXY' fullfile('bottle_samples','BOTTLE_OXY')
    'M_BOT_NUT' fullfile('bottle_samples','BOTTLE_NUT')
    'M_BOT_PIG' fullfile('bottle_samples','BOTTLE_PIG')
    'M_BOT_CO2' fullfile('bottle_samples','BOTTLE_CO2')
    'M_BOT_CFC' fullfile('bottle_samples','BOTTLE_CFC')
    'M_BOT_CH4' fullfile('bottle_samples','BOTTLE_CH4')
    'M_BOT_CHL' fullfile('bottle_samples','BOTTLE_PIG')
    'M_BOT_ISO' fullfile('bottle_samples','BOTTLE_SHORE')
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


if MEXEC_G.raw_underway
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
        if MEXEC_G.raw_underway==1
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
                warning('skipping underway data setup')
            end
        end
    end
    if exist('mrtv','var')
        MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; ...
            [cellfun(@(x) ['M_' upper(x)], mrtv.mstarpre, 'UniformOutput', false), ...
            mrtv.mstardir]];
        [~,ii] = unique(MEXEC_G.MDIRLIST(:,1),'stable');
        MEXEC_G.MDIRLIST = MEXEC_G.MDIRLIST(ii,:);
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

function mpath = sw_addpath(ld, force_vers)
%
% add external software toolboxes specified by table ld to path
%
% defaults to finding the highest version available in swroot,
%   unless force_vers is a structure 
%     (e.g. force_vers.gsw_matlab = 'gsw_matlab_v3_06_16';),
%   in which case uses any hard-coded versions listed there

if isstruct(force_vers)
    % replace empty vers with force_vers
    fn = fieldnames(force_vers);
    for no = 1:length(fn)
        m = strcmp(fn{no},ld.lib);
        ld.vers(m) = replace(force_vers.(fn{no}),ld.lib{no},'');
    end
end

% find highest version available for the rest
ld = sw_vers_parse(ld);

% add to path where not already on path
mpath = cellfun(@(x,y,z) fullfile(x,[y z]),...
    ld.predir, ld.lib, ld.vers,...
    'UniformOutput',false);
isnew = ~ismember(mpath,split(path,':'));
for lno = 1:length(mpath)
    if exist(mpath{lno},'dir')==7 %presume subdirectories will also be present     
        if isnew(lno)
            fprintf(1,'adding to path: %s\n',mpath{lno})
            addpath(genpath(mpath{lno}), '-end')
        end
    else
        warning([mpath{lno} ' not found'])
        mpath{lno} = '';
    end
end
mpath = setdiff(mpath,{''},'stable');


function lib_tab = sw_vers_parse(lib_tab)
% lib_tab = sw_vers_parse(lib_tab)
%
% find highest version of a library in a given directory
%
% verstr: Nx1 cell array
%
% lib_tab is a table with fields:
%     predir (where to look),
%     lib (library name),
%     vers (empty string to search)

notfound = [];

for lno = find(cellfun('isempty',lib_tab.vers))'
    
    %get list of matching directory names
    d = dir(fullfile(lib_tab.predir{lno}, [lib_tab.lib{lno} '*']));
    a = {d.name};
    a = a(cell2mat({d.isdir}));
        
    if isempty(a)
        notfound = [notfound; lno];
    else
        if isscalar(a)
            ind = 1;
        else
            %get version numbers
            b0 = replace(a,{[lib_tab.lib{lno} '_ver'];[lib_tab.lib{lno} '_v'];[lib_tab.lib{lno} '_'];lib_tab.lib{lno}},''); %remove initial part
            b = replace(replace(b0,'_',' '),'.',' '); %so we can compare numbers
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
                    d = zeros(max(l),length(c));
                    for n = 1:max(l)
                        d(n,ii) = cellfun(@(x) [x(n)], c(ii));
                        n = n+1;
                        ii = find(l>=n);
                    end
                    n = 1; ind = 1:length(c);
                    while n<=size(d,1) && length(ind)>1
                        ii = find(d(n,:)==max(d(n,:)));
                        ind = ind(ii); d = d(:,ii);
                        n = n+1;
                    end
                end
            end
        end
           
        %save string corresponding to highest version
        lib_tab.vers{lno} = replace(a{ind},lib_tab.lib{lno},'');
        
    end
    
end

lib_tab(notfound,:) = [];

