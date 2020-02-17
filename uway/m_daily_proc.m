%this one is not completely general but works for the jcr and now hopefully for the jc!
%
%by default it will process all the available underway streams (of the set in mtnames or msnames)
%or you can specify uway_streams_proc_list, a list of mexec short names to process
%or uway_streams_proc_exclude, a list of mexec short names to exclude from processing
%
%you can specify days, a vector of year-days to process, or it will default
%to yesterday

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
scriptname='m_daily_proc'

oopt = 'exclude'; get_cropt %%%***opt_jc174 should maybe set uway_pattern_proc_exclude = {'satinfo';'aux'}; only

%get list of underway streams to process
[udirs, udcruise] = m_udirs;
if exist('uway_streams_proc_list', 'var')
   iik = [];
   for sno = 1:size(uway_streams_proc_list,1)
      ii = find(strcmp(uway_streams_proc_list{sno}, udirs(:,1))); iik = [iik; ii];
   end
   udirs = udirs(iik, :);
end

%remove the ones to exclude
iie = [];
for sno = 1:size(udirs,1)
   if exist('uway_streams_proc_exclude', 'var') & sum(strcmp(udirs{sno,1}, uway_streams_proc_exclude))
      iie = [iie; sno];
   end
   if exist('uway_pattern_proc_exclude', 'var')
      for no = 1:size(uway_pattern_proc_exclude,1)
         if length(strfind(udirs{sno,1}, uway_pattern_proc_exclude{no}))>0; iie = [iie; sno]; end
      end
   end
end
clear uway_streams_proc_exclude uway_pattern_proc_exclude
udirs(iie, :) = [];


year = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
if ~exist('days'); days = floor(datenum(now)-datenum(year,1,1)); end %default: yesterday
if ~exist('restart_uway_append'); restart_uway_append = 0; end
if restart_uway_append; warning(['will delete appended file and start from ' num2str(days(1))]); end

%loop through processing steps for list of days
cd(MEXEC_G.MEXEC_DATA_ROOT)
oopt = 'bathycomb'; get_cropt
for daynumber = days

   daystr = ['00' num2str(daynumber)]; daystr = daystr(end-2:end);
  
   for sno = 1:size(udirs, 1)

      %load
      if strcmp(MEXEC_G.Mshipdatasystem, 'scs') & daynumber==days(1) & restart_uway_append
          unix(['rm -f ' MEXEC_G.MEXEC_DATA_ROOT '/scs_mat/' udirs{sno,4}])
      end
      mday_01(udirs{sno,2}, udirs{sno,4}, udirs{sno,1}, daynumber, year);

      %apply additional processing and cleaning for some streams
      edname = [udirs{sno,3} '/' udirs{sno,1} '_' mcruise '_d' daystr '_edt.nc'];
      if exist(edname, 'file'); unix(['/bin/rm ' edname]); end
      mday_01_clean_av(udirs{sno,1}, daynumber);
      
   end
   
   %cross-merge bathy streams for later editing
   if bathycomb
   iis = find(strcmp('sim', udirs(:,1))); iie = find(strncmp('em12', udirs(:,1), 4));
   if length(iis)>0 & exist([udirs{iis,3} '/' udirs{iis,1} '_' mcruise '_d' daystr '_raw.nc'])
      day = daynumber; msim_02;
   end
   cd(MEXEC_G.MEXEC_DATA_ROOT)
   if length(iie)>0 & exist([udirs{iie,3} '/' udirs{iie,1} '_' mcruise '_d' daystr '_raw.nc'])
      day = daynumber; mem120_02;
   end
   cd(MEXEC_G.MEXEC_DATA_ROOT)
   end
   
   % on Discovery, we have temperature and salinity in tsg, other variables 
   % in met_tsg so we need to combine these streams into met_tsg. Originally, 
   % we tried to do this at the end, but this doesn't work when appending
   % additional days, as some variables will be missing from files being
   % appended...
   if strcmp(MEXEC_G.Mship,'discovery') 
     if exist([MEXEC_G.MEXEC_DATA_ROOT '/ocl/tsg/tsg_' mcruise '_d' daystr '_edt.nc'])

      scriptname='m_daily_proc';

      mdocshow(scriptname, ['merge tsg data from from tsg_' mcruise '_d' daystr '_edt.nc into met_tsg_' mcruise '_d' daystr '_edt.nc']);

      wkfile = ['wk_' scriptname '_' datestr(now,30)];
      cd([MEXEC_G.MEXEC_DATA_ROOT '/ocl/tsg']);
      cmd = ['/bin/cp -p ' 'met_tsg_' mcruise '_d' daystr '_edt.nc ' m_add_nc(wkfile)]; unix(cmd);

      MEXEC_A.MARGS_IN = {
         ['met_tsg_' mcruise '_d' daystr '_edt.nc']
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
      cd(MEXEC_G.MEXEC_DATA_ROOT)
     else % no TSG file for this day - so we need to add blank variables 
          % to MET_TSG so the files can be merged when data become available
      cd([MEXEC_G.MEXEC_DATA_ROOT '/ocl/tsg']);
      otfilestruct=struct('name',['met_tsg_' mcruise '_d' daystr '_edt.nc']);
      h=m_read_header(otfilestruct.name);
      blankdata=repmat(-99999,h.rowlength,h.collength);
      m_write_variable(otfilestruct,struct('name','psal','units','pss-78','data',blankdata));
      m_write_variable(otfilestruct,struct('name','temp_r','units','degree_Celsius','data',blankdata));
      m_write_variable(otfilestruct,struct('name','temp_h','units','degree_Celsius','data',blankdata));
      m_write_variable(otfilestruct,struct('name','cond','units','S/m','data',blankdata));
      m_write_variable(otfilestruct,struct('name','sndspeed','units','m/s','data',blankdata));
      cd(MEXEC_G.MEXEC_DATA_ROOT)
     end
   end
  
   %update appended files
   for sno = 1:size(udirs, 1)
      if daynumber==days(1) & restart_uway_append
         warning(['clobbering ' udirs{sno,1} '_' mcruise '_01.nc'])
         cd(MEXEC_G.MEXEC_DATA_ROOT)
         unix(['/bin/rm ' udirs{sno,3} '/' udirs{sno,1} '_' mcruise '_01.nc']);
      end
      mday_02(udirs{sno,2}, udirs{sno,1}, daynumber);
   end

end

%what about wamos (on techsas)? 
mbest_all


mtruew_01
try
    mtsg_medav_clean_cal
catch
    warning('no tsg file, not running mtsg_medav_clean_cal')
end
switch MEXEC_G.Mship
   case 'jcr'
      oopt = 'allmat'; get_cropt
      if allmat; update_allmat; end
end
