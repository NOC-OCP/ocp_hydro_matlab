% mtsg_medav_clean_cal: clean and calibrate SBE45 tsg data
%
% Use: mtsg_medav_clean_cal
%
% runs on appended cruise file. This draft bak on jc069
% first reduce data to 1-minute bins, using median rather than mean;
% then apply cleanup and calibration using mcalib2, using function
% mtsg_cleanup, which can be constructed for each cruise. This function can
% discard data when the pumps were off, apply adjustments, etc.
%
% modded bak jr302 second SST

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

scriptname = 'ship'; oopt = 'ship_data_sys_names'; get_cropt

% bak jc211 ship_data_sys_names sets metpre and tsgpre. In this scripts we
% want tsgpre
prefix = tsgpre;

mdocshow(mfilename, ['averages to 1 minute and calls mtsg_cleanup to remove bad times from appended tsg file, producing ' prefix '_' mcruise '_01_medav_clean.nc; calls tsgsal_apply_cal to apply salinity calibration set in opt_' mcruise ', writing to ' prefix '_' mcruise '_01_medav_clean_cal.nc'])


root_dir = mgetdir(prefix);
infile1 = [root_dir '/' prefix '_' mcruise '_01'];
otfile1 = [root_dir '/' prefix '_' mcruise '_01_medav_clean']; % 1-minute median data
otfile2 = [root_dir '/' prefix '_' mcruise '_01_medav_clean_cal']; % 1-minute median data
wkfile1 = ['wk1_' mfilename '_' datestr(now,30)];

if ~exist(m_add_nc(infile1),'file')
    error(['no tsg file ' infile1])
    return
end

%average
MEXEC_A.MARGS_IN = {
    infile1
    otfile1
    ' '
    'time'
    '30 1e10 60'
    'b'
    };
mavmed

%cut out bad times
    
h = m_read_header(otfile1);
torg = datenum(h.data_time_origin);

MEXEC_A.MARGS_IN = {otfile1; 'y'};
for no = 1:length(h.fldnam)
   var = h.fldnam{no};
   if ~strcmp(var, 'time') & ~strcmp(var, 'deltat')
      vline = ['y = mtsg_cleanup(' sprintf('%20.10f',torg) ',x1,x2,''' var ''')'];
      MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; var; ['time ' var]; vline; ' '; ' '];
   end
end
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
mcalib2

%determine if there is a tsg salinity calibration
scriptname = 'tsgsal_apply_cal'; salin = 1; time = 1; oopt = 'tsgsaladj'; get_cropt; %eval(['opt_' mcruise])

%apply it if there is one
if exist('salout','var')

   salvar = mvarname_find({'salinity' 'psal' 'salinity_raw'},h.fldnam);
   salinline = ['y = tsgsal_apply_cal(x1,x2)'];
   
   switch salvar
       case 'salinity_raw'
           salcalvar = 'salinity_cal';
       otherwise
           salcalvar = [salvar '_cal'];
   end

   MEXEC_A.MARGS_IN = {
      otfile1
      otfile2
      '/'
      ['time ' salvar]
      salinline
      salcalvar % [salvar '_cal']
      'pss-78'
      ' '
      };
  mcalc
end

%determine if there is a tsg temperature adjustment
scriptname = 'tsgsal_apply_cal'; tempin = 1; time = 1; oopt = 'tempadj'; eval(['opt_' mcruise])

%apply it if there is one
if exist('tempout','var')

   if exist(m_add_nc(otfile2),'file')
      unix(['/bin/mv ' m_add_nc(otfile2) ' ' m_add_nc(wkfile1)]);
   else
      wkfile1=otfile1;
   end

   tempvar = mvarname_find({'remotetemp' 'temp_4' 'sstemp'},ht.fldnam);
   tempinline = ['y = tsgsal_apply_temp_cal(x1,x2)'];

   MEXEC_A.MARGS_IN = {
      wkfile1
      otfile2
      '/'
      ['time ' tempvar]
      tempinline
      [tempvar '_adj']
      'degree_Celsius'
      ' '
      };
  mcalc
  
  if ~strcmp(otfile1,wkfile1)
     unix(['/bin/rm ' m_add_nc(wkfile1)]);
  end

end

