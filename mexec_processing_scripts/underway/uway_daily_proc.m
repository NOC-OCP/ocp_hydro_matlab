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
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
year = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);

if ~exist('days','var')
    days = floor(now-datenum(year,1,1)); %default: yesterday
end

root_u = MEXEC_G.mexec_data_root;

%%%%% get list of underway streams to process %%%%%
uway_set_streams

%%%%% loop through processing steps for list of days %%%%%

%which variables to merge from one file into another
combvars = {}; %***
opt1 = 'uway_proc'; opt2 = 'comb_uvars'; get_cropt 


loadstatus = zeros(1,length(shortnames));
for daynumber = days
    for sno = 1:length(shortnames)
        if daynumber==days(1)
            udirs{sno} = fullfile(MEXEC_G.mexec_data_root,udirs{sno});
        end
        if loadstatus(sno)==0
            %load
%             try
                ls = mday_00_load(streamnames{sno}, shortnames{sno}, udirs{sno}, daynumber, year);
%             catch
%                 ls = 1; 
%                 keyboard
%             end
            loadstatus(sno) = loadstatus(sno) + ls;
        end
    end
end
%***should 2 also be thrown out? what if loadstatus was 0 for some days but
%1 for last?
% shortnames(loadstatus>0) = [];
% streamnames(loadstatus>0) = [];
% udirs(loadstatus>0) = [];

%apply additional processing and cleaning to data
for sno = 1:length(shortnames)
    mday_01_edit(udirs{sno}, shortnames{sno}, days)
end

%combine streams, do hand edits (for some streams), and average to produce
%output/best files
mnav_best(days)
mwind_true(days)
%mtsg_merge_av(days) %combines old mtsg_medav_clean_cal and mtsg_surfmet_merge
% mbathy_edit_av

% % make plots
