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

if ~exist('days','var')
    days = floor(datenum(now)-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1),1,1)); %default: yesterday
end

if ~exist('restart_uway_append','var'); restart_uway_append = 0; end
if restart_uway_append; warning(['will delete appended file and start from ' num2str(days(1))]); end

root_u = MEXEC_G.MEXEC_DATA_ROOT;
root_tsg = mgetdir('M_TSG');

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
shortnames = udirs(:,1); streamnames = udirs(:,4); udirs = udirs(:,3);

%%%%% loop through processing steps for list of days %%%%%

scriptname = mfilename; oopt = 'bathycomb'; get_cropt

for daynumber = days
   daystr = sprintf('%03d', daynumber);
  
   for sno = 1:size(udirs, 1)

      %load
      mday_01(['M_' upper(shortnames{sno})], streamnames{sno}, shortnames{sno}, daynumber, year);

      %apply additional processing and cleaning for some streams
      edname = [root_u '/' udirs{sno} '/' shortnames{sno} '_' mcruise '_d' daystr '_edt.nc'];
      if exist(edname, 'file'); unix(['/bin/rm -f ' edname]); end
      mday_01_clean_av(shortnames{sno}, daynumber);
      
   end
   
   %cross-merge bathy streams for later editing
   if bathycomb
   iis = find(strcmp('sim', shortnames) | strncmp('ea6',shortnames,3)); 
   iie = find(strncmp('em12', shortnames, 4));
   if length(iis)>0 & exist([root_u '/' udirs{iis} '/' shortnames{iis} '_' mcruise '_d' daystr '_raw.nc'],'file')
      day = daynumber; msim_02;
   end
   if length(iie)>0 & exist([root_u '/' udirs{iie} '/' shortnames{iie} '_' mcruise '_d' daystr '_raw.nc'],'file')
      day = daynumber; mem120_02;
   end
   end
   
   % on Discovery, we have temperature and salinity in tsg, other variables 
   % in met_tsg so we need to combine these streams into met_tsg. Originally, 
   % we tried to do this at the end, but this doesn't work when appending
   % additional days, as some variables will be missing from files being
   % appended...
   if strcmp(MEXEC_G.Mship,'discovery') 
     if exist([root_tsg '/tsg_' mcruise '_d' daystr '_edt.nc'],'file') & exist([root_tsg '/tsg/met_tsg_' mcruise '_d' daystr '_edt.nc'],'file')

      mdocshow(mfilename, ['merge tsg data from from tsg_' mcruise '_d' daystr '_edt.nc into met_tsg_' mcruise '_d' daystr '_edt.nc']);

      wkfile = ['wk_' mfilename '_' datestr(now,30)];
      cmd = ['/bin/cp -p ' root_tsg '/met_tsg_' mcruise '_d' daystr '_edt.nc ' m_add_nc(wkfile)]; unix(cmd);

      MEXEC_A.MARGS_IN = {
         [root_tsg '/met_tsg_' mcruise '_d' daystr '_edt.nc']
         m_add_nc(wkfile)
         '/'
         'time'
         ['tsg_' mcruise '_d' daystr '_edt.nc']
         'time'
         'psal temp_r temp_h cond sndspeed' % not deltat
         'k'
         };
      mmerge
      unix(['/bin/rm ' wkfile '.nc']);
     else % no TSG file for this day - so we need to add blank variables 
          % to MET_TSG so the files can be merged when data become available
      otfilestruct=struct('name',[root_tsg '/met_tsg_' mcruise '_d' daystr '_edt.nc']);
      h=m_read_header(otfilestruct.name);
      blankdata=repmat(-99999,h.rowlength,h.collength);
      m_write_variable(otfilestruct,struct('name','psal','units','pss-78','data',blankdata));
      m_write_variable(otfilestruct,struct('name','temp_r','units','degree_Celsius','data',blankdata));
      m_write_variable(otfilestruct,struct('name','temp_h','units','degree_Celsius','data',blankdata));
      m_write_variable(otfilestruct,struct('name','cond','units','S/m','data',blankdata));
      m_write_variable(otfilestruct,struct('name','sndspeed','units','m/s','data',blankdata));
     end
   end
  
   %update appended files
   for sno = 1:size(udirs, 1)
      if daynumber==days(1) & restart_uway_append     
          if strcmp(MEXEC_G.Mshipdatasystem, 'scs')
          unix(['rm -f ' root_u '/scs_mat/' udirs{sno,4}])
          end
         warning(['clobbering ' shortnames{sno} '_' mcruise '_01.nc'])
         unix(['/bin/rm ' root_u '/' udirs{sno} '/' shortnames{sno} '_' mcruise '_01.nc']);
      end
      mday_02(shortnames{sno}, daynumber);
   end

end
clear restart_uway_append

%%%%% further processing %%%%%

mbest_all %get best nav stream into bst_ file

mtruew_01

try
    mtsg_medav_clean_cal
catch
    warning('no tsg file, not running mtsg_medav_clean_cal')
end

switch MEXEC_G.Mshipdatasystem
   case 'scs'
      scriptname = mfilename; oopt = 'uwayallmat'; get_cropt
      if allmat; update_allmat; end
end
