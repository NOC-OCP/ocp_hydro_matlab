function uway_process(dates, varargin)
%
% wrapper to load and process underway data
%
% uway_daily_proc(dates)
%   runs through loading, automatic editing of raw data, and averaging,
%   merging, and editing of combined data, either for all available 
%    dates can be either an Nx1 vector of decimal days
%   (dates since the start of the year in MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN)
%   or a Nx6 vector of [yyyy mm dd HH MM SS]
% uway_daily_proc(dates, mstar_prefix, 'reload_uway', 0); %processes, for
%   mstar_prefix files, days starting from already-loaded raw files and
%   skipping to editing and averaging stage (mday_01 and mday_02)
% uway_daily_proc(dates, [], 'reload_uway', 0, 'reload_av', 0);
%   %skips to editing of already-generated merged, averaged files
%
% by default it will process all the available techsas/scs/rvdas underway
% streams (of the set defined by mudefine), unless you add
% to the cruise options file list(s) of names (uway_excludes) or patterns
% (uway_excludep) to exclude
%
% note: year-days start from 1 at midnight on 1 January of the year defined
% by MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN (year-day is decimal day + 1)
%

m_common

if size(days,2)==6
    ddays = datenum(dates)-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,1,1);
elseif size(days,2)==1
    ddays = dates;
else
    error('dates must be either Nx1 vector of decimal days or Nx6 vector of [yyyy mm dd HH MM SS]')
end
%defaults
reload_uway = 1; %load raw data, set to 0 to skip ahead to editing/averaging/merging stage
reload_av = 1; %set to 0 to just redo edits not averages
%optional inputs
if nargin>2
    for no = 2:2:length(varargin)
        eval([varargin{no} ' = varargin{no+1};']);
    end
end

%%%%% get list of underway streams to process %%%%%
mtable = mudefine;
opt1 = 'uway_proc'; opt2 = 'proc_streams';
if exist('uway_proc_list','var') %only from this list
    [~,iik,~] = intersect(mtable.mstardir,uway_proc_list,'stable');
    mtable = mtable(iik,:);
elseif exist('uway_excludes','var')
    [~,iie,~] = intersect(mtable.mstardir, uway_excludes);
    mtable(iie,:) = [];
end
if nargin>1 && ~isempty(varargin{1})
    %only run reload_uway steps for one type, and don't run 
    mtable = mtable(ismember(mtable.mstarpre,varargin{1}),:);
end

%%%%% loop through processing steps for list of ddays %%%%%

if reload_uway
    % load one day at a time and append to one file per stream
    ns = length(mtable.mstardir);
    ls = nan+zeros(ns,length(ddays));
    for sno = 1:ns
            p = mtable.tablenames{sno};
        if strcmp(MEXEC_G.Mshipdatasystem,'scs_ascii')
            ls(sno,1) = mday_00_load(p, [], mtable);
        else
            for day = ddays
                ls(sno,day-ddays(1)+1) = mday_00_load(p, day, mtable);
                 disp(['loaded day ' num2str(day)]); pause(0.1)
            end
        end
    end
    ls(isnan(ls)) = 1;
    ms = logical(sum(ls,2)');
    if sum(ms)>0
        disp('some missing from: ')
        disp(mtable.tablenames(ms))
    end
end

% for each stream, starting with nav streams, apply additional processing
% and cleaning to data 
if reload_uway %something new to take through preliminary edits stage
    mudirs = cellfun(@(x,y) [x '/' y],mtable.mstardir,mtable.mstarpre,'UniformOutput',false);
    [mudirs,ii] = unique(mudirs);
    mufiles = mtable.mstarpre(ii);
    iin = find(contains(mudirs,'nav/'));
    iio = setdiff([1:length(mudirs)]',iin);
    mufiles = mufiles([iin;iio]);
    if exist('never_edit','var')
        mufiles = setdiff(mufiles,never_edit);
    end
    for sno = 1:length(mufiles)
        de = mday_01_edit(mufiles{sno}, ddays, mtable);
        if de
            fprintf(1,'edited %s\n', mufiles{sno})
        end
    end
end

% return %first examine all the edited data before merging/deciding what to do?***
%combine streams, do hand edits (for some streams), and average to produce
%output/best files
ctypes = {'nav','bathy','ocean','atmos'}; %important to do nav first
%ctypes = ctypes(2); %did ocean, need to redo nav for wind; bathy is a problem, save for later
for cno = 1:length(ctypes)
    mday_02_merge_av(ctypes{cno}, ddays, mtable, reload_av);
    fprintf(1,'merged %s files\n',ctypes{cno})
end

if ismember(ctypes,'ocean')
    disp('you could now run mtsg_bottle_ctd_compare')
end

% % make plots
