
%  GNU nano 2.0.6                       File: Downloads/m_uway_append_all.m                                                    

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

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
ex1 = 0; ex2 = 0;
if exist('uway_streams_proc_exclude', 'var'); ex1 = 1; end
if exist('uway_pattern_proc_exclude', 'var'); ex2 = 1; end

iie = [];
for sno = 1:size(udirs,1)
   if ex1 & sum(strcmp(udirs{sno,1}, uway_streams_proc_exclude))
      iie = [iie; sno];
   end
   if ex2
      for no = 1:size(uway_pattern_proc_exclude,1)
         if length(strfind(udirs{sno,1}, uway_pattern_proc_exclude{no}))>0; iie = [iie; sno]; end
      end
   end
end
udirs(iie, :) = [];

year = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1);

%loop through mday_02 for days up to yesterday
cd(MEXEC_G.mexec_data_root)
day0 = 41;
for daynumber = day0:floor(datenum(now)-datenum(year,1,1));

   daystr = ['00' num2str(daynumber)]; daystr = daystr(end-2:end);

   %update appended files
   for sno = 1:size(udirs, 1)
      if daynumber==day0
         cd(MEXEC_G.mexec_data_root)
         delete(fullfile(udirs{sno,3}, [udirs{sno,1} '_' mcruise '_01.nc']));
      end
      mday_02(udirs{sno,2}, udirs{sno,1}, daynumber);
   end

end

