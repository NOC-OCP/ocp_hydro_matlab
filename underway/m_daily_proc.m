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
%by default it appends the days processed to existing _01 files, unless you
%set restart_uway_append to 1, in which case it deletes the appended files
%and starts over***need better way to do this, including merging data into the
%middle***

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
year = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);

if ~exist('days','var')
    days = floor(datenum(now)-datenum(year,1,1)); %default: yesterday
end

if ~exist('restart_uway_append','var'); restart_uway_append = 0; end
if restart_uway_append; warning(['will delete appended file and start from ' num2str(days(1))]); end

root_u = MEXEC_G.mexec_data_root;

%%%%% get list of underway streams to process %%%%%
[udirs, udcruise] = m_udirs;

scriptname = mfilename; oopt = 'excludestreams'; get_cropt

if exist('uway_proc_list', 'var') %only from this list
    iik = [];
    for sno = 1:size(uway_proc_list,1)
        ii = find(strcmp(uway_proc_list{sno}, udirs(:,1))); iik = [iik; ii];
    end
    udirs = udirs(iik, :);
    
elseif exist('uway_excludes','var') | exist('uway_excludep','var') %whole list except excluded
    iie = [];
    for sno = 1:size(udirs,1)
        if exist('uway_excludes','var') & sum(strcmp(udirs{sno,1}, uway_excludes))
            iie = [iie; sno];
        end
        if exist('uway_excludep', 'var')
            for no = 1:size(uway_excludep,1)
                if length(strfind(udirs{sno,1}, uway_excludep{no}))>0; iie = [iie; sno]; end
            end
        end
    end
    udirs(iie, :) = [];
    
end
shortnames = udirs(:,1); streamnames = udirs(:,3); udirs = udirs(:,2);

%merging variables from one file into another
scriptname = mfilename; oopt = 'comb_uvars'; get_cropt 

%%%%% loop through processing steps for list of days %%%%%

for daynumber = days
    daystr = sprintf('%03d', daynumber);
    
    for sno = 1:length(shortnames)
        
        %load
        mday_01(streamnames{sno}, shortnames{sno}, daynumber, year);
        
        %apply additional processing and cleaning for some streams
        mday_01_clean(shortnames{sno}, daynumber);
        
    end
    
    %merge bathymetry streams with each other
    if sum(strcmp('bathy', umtypes))
        mbathy_av
        mbathy_merge
    end
    
    % compute salinity and add to tsg file
    if sum(strcmp('tsgsal', umtypes))
        mday_01_tsgsal %***selection of temperature variable to use?
    end
    
    for sno = 1:length(shortnames)
        
        %update appended files
        if daynumber==days(1) & restart_uway_append
            if strcmp(MEXEC_G.Mshipdatasystem, 'scs')
                delete(fullfile(root_u,'scs_mat',udirs{sno}));
            end
            warning(['clobbering ' shortnames{sno} '_' mcruise '_01.nc'])
            delete(fullfile(root_u, udirs{sno}, [shortnames{sno} '_' mcruise '_01.nc']));
        end
        mday_02(shortnames{sno}, daynumber);
    end
    
end
clear restart_uway_append

return

%%%%% further processing %%%%%

mbest_all %get best nav stream into bst_ file

%add data from one file to another by interpolation for comparison and
%editing, as specified in cruise options
if sum(strcmp('tsgsurfmet', umtypes))
    mtsgsurfmet_merge
end

mtruew_01
% % % % % % % % % % 
% % % % % % % % % % try
% % % % % % % % % %     mtsg_medav_clean_cal
% % % % % % % % % % catch
% % % % % % % % % %     warning('no tsg file, not running mtsg_medav_clean_cal')
% % % % % % % % % % end
% % % % % % % % % % 
% % % % % % % % % % switch MEXEC_G.Mshipdatasystem
% % % % % % % % % %     case 'scs'
% % % % % % % % % %         scriptname = mfilename; oopt = 'uwayallmat'; get_cropt
% % % % % % % % % %         if allmat; update_allmat; end
% % % % % % % % % % end
