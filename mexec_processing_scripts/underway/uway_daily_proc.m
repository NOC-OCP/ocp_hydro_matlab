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

if ~exist('restart_uway_append','var'); restart_uway_append = 0; end
if restart_uway_append; warning('will delete appended file and start from %d; this is probably not necessary as mday_02 merges on time',days(1)); end

root_u = MEXEC_G.mexec_data_root;

%%%%% get list of underway streams to process %%%%%
uway_set_streams

%%%%% loop through processing steps for list of days %%%%%

%which variables to merge from one file into another
scriptname = mfilename; oopt = 'comb_uvars'; get_cropt 


for daynumber = days
    daystr = sprintf('%03d', daynumber);

    loadstatus = zeros(1,length(shortnames));
    for sno = 1:length(shortnames)

        if loadstatus(sno)==0
            %load
            try
                loadstatus(sno) = mday_01(streamnames{sno}, shortnames{sno}, daynumber, year);
            catch
                loadstatus(sno) = 1;
            end
            if loadstatus(sno)==2
                %did not find directory in MEXEC_G.MDIRLIST, go to next shortname after single warning
                fprintf(1,'%s (%s) not found in MEXEC_G.MDIRLIST,\n',shortnames{sno},streamnames{sno})
                if strcmp(MEXEC_G.Mshipdatasystem,'rvdas')
                    fprintf(1,'or is in m_udirs.m but not in mrtables_from_json.m (rerun m_setudir and m_setup?),\n')
                end
                warning('enter to continue skipping this stream, or Ctrl-C to quit');

                pause
                continue
            end

            %apply additional processing and cleaning (and renaming) for some streams
            mday_01_clean(shortnames{sno}, daynumber);
        end

    end

end

%edit bathymetry files
if sum(strcmp('bathy', umtypes))
    for daynumber = days
        daystr = sprintf('%03d',daynumber);
        mbathy_edit_av
    end
end
 

shortnames(loadstatus==1) = [];
streamnames(loadstatus==1) = [];
udirs(loadstatus==1) = [];

%append to _01 files
%ii = find(strcmp('singleb',shortnames) | strcmp('multib',shortnames));
ii = 1:length(shortnames);
m_uway_append(shortnames(ii), udirs(ii), days, restart_uway_append)
clear restart_uway_append

%%%%% further processing %%%%%

mnav_best %get best nav stream into bst_ file

try
    mtsg_medav_clean_cal
catch
end

%merge other related files into surfmet; tsg files are edited for the
%appended series, so do merge on appended files
if sum(strcmp('tsgsurfmet', umtypes))
    mtsgsurfmet_merge
end

mwind_true % combine nav and met to get truewind, in surfmet file
