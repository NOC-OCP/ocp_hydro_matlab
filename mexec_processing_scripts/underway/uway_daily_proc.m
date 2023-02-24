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
%by default it appends the days processed to existing _01 files (and overwrites them if they are already there), unless you
%set restart_uway_append to 1, in which case it deletes the appended files
%and starts over

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


for daynumber = days
    loadstatus = zeros(1,length(shortnames));
    for sno = 1:length(shortnames)
        if loadstatus(sno)==0
            %load
            try
                loadstatus(sno) = mday_00_load(streamnames{sno}, shortnames{sno}, udirs{sno}, daynumber, year);
            catch
                loadstatus(sno) = 1;
                keyboard
            end
            if loadstatus(sno)==2 && strcmp(MEXEC_G.Mshipdatasystem,'rvdas')
                warning('enter to continue, skipping this stream, or Ctrl-C to quit');
                pause
                continue
            end
            %apply additional processing and cleaning for some
            %streams/variables, appending/merging edited data to _01 file
            if loadstatus(sno)==0
                mday_01_clean_append(shortnames{sno}, udirs{sno}, daynumber);
            end
        end
    end
end

shortnames(loadstatus==1) = [];
streamnames(loadstatus==1) = [];
udirs(loadstatus==1) = [];

% run scripts to average, edit, and combine data

%combine best nav and heading into bst_ file
mnav_best %get best nav stream into bst_ file

%combine wind with bestnav to get truewind
mwind_true

%edit (and calibrate) tsg; combine tsg and surfmet in some cases
try
    mtsg_medav_clean_cal
catch
end

%merge other related files into surfmet; tsg files are edited for the
%appended series, so do merge on appended files
if sum(strcmp('tsgsurfmet', umtypes))
    mtsgsurfmet_merge
end

%edit bathymetry (uses bestnav)


% make plots
%***