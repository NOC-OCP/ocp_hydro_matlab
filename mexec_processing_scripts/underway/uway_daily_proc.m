%wrapper script to process underway data
%
%by default it will process all the available techsas/scs/rvdas underway
%streams (of the set in mtnames/msnames/mrnames), unless you either
%specify uway_proc_list, a list of mexec short names to process, or add
%to the cruise options file list(s) of names (uway_excludes) or patterns
%(uway_excludep) to exclude
%
%by default it will process yesterday's data, unless you specify days, a
%vector of year-days to process
%
%by default it appends the days processed to existing _01 files (and
%overwrites them if they are already there), unless you set
%restart_uway_append to 1, in which case it deletes the appended files and
%starts over 

m_common

ydays = 207:208;

if ~exist('ydays','var')
    ydays = floor(now-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,1,1)); %default: yesterday
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

if ~exist('reload_uway','var') || reload_uway==1
    % load one day at a time and append to one file per stream
    ns = length(mtable.tablenames);
    ls = nan+zeros(ns,length(ydays));
    for yday = ydays
        for sno = 1:ns
            ls(sno,yday-ydays(1)+1) = mday_00_load(mtable.tablenames{sno}, yday, mtable);
        end
        disp(['loaded day ' num2str(yday)]); pause(0.1)
    end
    disp('some missing from: ')
    disp(mtable.tablenames(sum(ls,2)'>0))
end

% for each stream, starting with nav streams, apply additional processing
% and cleaning to data 
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
    de = mday_01_edit(mufiles{sno}, ydays, mtable);
    if de
        fprintf(1,'edited %s\n', mufiles{sno})
    end
end
return

%combine streams, do hand edits (for some streams), and average to produce
%output/best files
ctypes = {'nav','bathy','tsg'}; %important to do nav first
reload_av = 1; %set to 0 to just go through edit stage
for cno = 1:length(ctypes)
    mday_02_merge_av(ctypes{cno}, ydays, mtable, reload_av);
    fprintf(1,'merged %s files\n',ctypes{cno})
end
mwind_true(ydays)
% % make plots
