% mem120_02: merge on sim data
%
% Use: mem120_02        and then respond with day number, or for day 20
%      day = 20; mem120_02;
%
% overhaul of this and sim on jr281
%
% sequence should be run msim_01 and mem120_01 to do median clean and
% 5 minute averages of each data stream
%
% then msim_02 and mem120_02 to cross-merge the datastreams
% then msim_plot and mem120_plot to edit bad data

scriptname = 'mem120_02'; 
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if exist('day','var')
    m = ['Running script ' scriptname ' for day ' sprintf('%03d',day)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    day = input('type day number ');
end
day_string = sprintf('%03d',day);
daylocal = day;
clear day % so that it doesn't persist

dstring = datestr(now,30);

root_sim = mgetdir('M_SIM');

switch MEXEC_G.Mship % bak on jr281 march 2013; cook branch couldn't be tested on jr281
    case 'cook'
        root_em120 = mgetdir('M_EM120'); 
        prefix1 = ['em120_' mcruise '_'];
    case 'jcr'
        root_em120 = mgetdir('M_EM122'); 
        prefix1 = ['em122_' mcruise '_'];
    otherwise
        return
end

prefix2 = ['sim_' mcruise '_'];
infile1 = [root_em120 '/' prefix1 'd' day_string '_edt'];
infile2 = [root_sim '/' prefix2 'd' day_string '_edt'];
infile1 = m_add_nc(infile1);
infile2 = m_add_nc(infile2);
wkfile = ['wk_' scriptname '_' datestr(now,30)];
wkfile = m_add_nc(wkfile);

if exist(infile2,'file') ~= 2
    msg = [infile2 ' not found'];
    fprintf(2,'\n\n%s\n\n\n',msg)
   MEXEC_A.MARGS_IN = {
      infile1
      'y'
      'swath_depth'
      'y = nan+x;'
      'depth'
      'm'
      ' '
   };
   mcalib

else
   MEXEC_A.MARGS_IN = {
      wkfile
      infile1
      'time time_bin_average swath_depth'
      'time'
      infile2
      'time'
      'depth'
      'k'
   };
   mmerge
   unix(['/bin/mv ' wkfile ' ' infile1]);

end
