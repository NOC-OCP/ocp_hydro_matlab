function uway_daily_proc(varargin)
%
% wrapper to load and process underway data
%
% uway_daily_proc(ydays) %processes year-days in vector ydays
% uway_daily_proc %processes yesterday
% uway_daily_proc(ydays, parameter, 'reload_uway', 0); %processes ydays
%   %starting from already-loaded raw files and skipping to
%   %editing and averaging stage (mday_01 and mday_02)
% uway_daily_proc(ydays, parameter, 'reload_uway', 0, 'reload_av', 0);
%   %skips to editing of already-generated merged, averaged files
%
% by default it will process all the available techsas/scs/rvdas underway
% streams (of the set in mtnames/msnames/mrnames), unless you add
% to the cruise options file list(s) of names (uway_excludes) or patterns
% (uway_excludep) to exclude
%
% note: year-days start from 1 at midnight on 1 January of the year defined
% by MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN (year-day is decimal day + 1)
%

m_common

%defaults
ydays = floor(now-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1),1,1)); %default: yesterday
reload_uway = 1; %load raw data, set to 0 to skip ahead to editing/averaging/merging stage
reload_av = 1; %set to 0 to just redo edits not averages
%optional inputs
if nargin>0
    ydays = varargin{1};
    for no = 2:2:length(varargin)
        eval([varargin{no} ' = varargin{no+1};']);
    end
end

%%%%% get list of underway streams to process %%%%%
switch MEXEC_G.Mshipdatasystem
    case 'rvdas'
        mtable = mrdefine;
    case 'scs'
        mtable = msdefine; %***
    case 'techsas'
        mtable = mtdefine; %***
end
opt1 = 'uway_proc'; opt2 = 'proc_streams';
if exist('uway_proc_list','var') %only from this list
    [~,iik,~] = intersect(mtable.mstardir,uway_proc_list,'stable');
    mtable = mtable(iik,:);
elseif exist('uway_excludes','var')
    [~,iie,~] = intersect(mtable.mstardir, uway_excludes);
    mtable(iie,:) = [];
end


%%%%% loop through processing steps for list of days %%%%%

if reload_uway
    % load one day at a time and append to one file per stream
    ns = length(mtable.tablenames);
    ls = nan+zeros(ns,length(ydays));
    for yday = ydays
        for sno = 1:ns
            ls(sno,yday-ydays(1)+1) = mday_00_load(mtable.tablenames{sno}, yday, mtable);
        end
        disp(['loaded day ' num2str(yday)]); pause(0.1)
    end
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
    mufiles = {'surfmet'};
    for sno = 1:length(mufiles)
        de = mday_01_edit(mufiles{sno}, ydays, mtable);
        if de
            fprintf(1,'edited %s\n', mufiles{sno})
        end
    end
end

%combine streams, do hand edits (for some streams), and average to produce
%output/best files
ctypes = {'nav','bathy','ocean','atmos'}; %important to do nav first
ctypes = ctypes(4); %did ocean, need to redo nav for wind; bathy is a problem, save for later
for cno = 1:length(ctypes)
    mday_02_merge_av(ctypes{cno}, ydays, mtable, reload_av);
    fprintf(1,'merged %s files\n',ctypes{cno})
end

if ismember(ctypes,'ocean')
    disp('you could now run mtsg_bottle_ctd_compare')
end

% % make plots
