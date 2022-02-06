% msim_02: merge on em120 data
%
% Use: msim_02        and then respond with day number, or for day 20
%      day = 20; msim_02;
%
% overhaul of this and mem120 on jr281
%
% sequence should be run msim_01 and mem120_01 to do median clean and
% 5 minute averages of each data stream
%
% then msim_02 and mem120_02 to cross-merge the datastreams
% then msim_plot and mem120_plot to edit bad data

scriptname = 'msim_02'; 
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

root_sim = mgetdir('M_SIM');
dstring = datestr(now,30);

switch MEXEC_G.Mship % bak on jr281 march 2013; cook branch couldn't be tested on jr281
    case {'cook','discovery'} % even though Discovery's is actually an EM122...
        root_em120 = mgetdir('M_EM120');
        prefix2 = ['em120_' mcruise '_'];
    case 'jcr'
        root_em120 = mgetdir('M_EM122');
        prefix2 = ['em122_' mcruise '_'];
    otherwise
        return
end

prefix1 = ['sim_' mcruise '_'];
infile1 = fullfile(root_sim, [prefix1 'd' day_string '_edt']);
infile2 = fullfile(root_em120, prefix2 'd' day_string '_edt']);

infile1 = m_add_nc(infile1);
infile2 = m_add_nc(infile2);

wkfile = ['wk_' scriptname '_' datestr(now,30)];
wkfile = m_add_nc(wkfile);

if exist(infile2,'file') ~= 2
   msg = [infile2 ' not found'];
   fprintf(2,'\n\n%s\n\n\n',msg);
   MEXEC_A.MARGS_IN = {
      infile1
      wkfile
      '/'
      'depth'
      'y = nan+x1;'
      'swath_depth'
      'metres'
      ' '
   };
   mcalc
   movefile(m_add_nc(wkfile), m_add_nc(infile1));

else
   h = m_read_header(infile1);
   MEXEC_A.MARGS_IN = {
      wkfile
      infile1
      sprintf('%s ',h.fldnam{:})
      'time'
      infile2
      'time'
      'swath_depth'
      'k'
   };
   mmerge
   movefile(m_add_nc(wkfile), m_add_nc(infile1));

end

