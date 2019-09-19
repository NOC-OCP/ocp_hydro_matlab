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

%uway_streams_proc_include %include only these
uway_streams_proc_exclude = {'posmvtss'}; %exclude these
uway_pattern_proc_exclude = {'satinfo';'aux';'dps'}; %exclude those with this pattern anywhere

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
udirs(iie, :) = [];


year = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);
if ~exist('days'); days = floor(datenum(now)-datenum(year,1,1)); end %default: yesterday
if ~exist('restart_uway_append'); restart_uway_append = 0; end
if restart_uway_append; warning(['will delete appended file and start from ' num2str(days(1))]); end

%loop through processing steps for list of days
cd(MEXEC_G.MEXEC_DATA_ROOT)
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
   if 1
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
mtsg_medav_clean_cal
switch MEXEC_G.Mship
   case 'jcr'
      %update_allmat
end
