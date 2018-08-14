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

scriptname = 'mtsg_medav_clean_cal';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

switch MEXEC_G.Mship
   case 'cook' % used on jc069
      prefix = 'met_tsg';
   case 'jcr'
      prefix = 'oceanlogger';
end

mdocshow(scriptname, ['averages to 1 minute and calls mtsg_cleanup to remove bad times from appended tsg file, producing ' prefix '_' mcruise '_01_medav_clean.nc; calls tsgsal_apply_cal to apply salinity calibration set in opt_' mcruise ', writing to ' prefix '_' mcruise '_01_medav_clean_cal.nc'])

root_dir = mgetdir(prefix);
infile1 = [root_dir '/' prefix '_' mcruise '_01'];
otfile1 = [root_dir '/' prefix '_' mcruise '_01_medav_clean']; % 1-minute median data
otfile2 = [root_dir '/' prefix '_' mcruise '_01_medav_clean_cal']; % 1-minute median data

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
scriptname0 = scriptname; scriptname = 'tsgsal_apply_cal';
salin = 1; time = 1; oopt = 'saladj'; eval(['opt_' mcruise])
scriptname = scriptname0;

%apply it if there is one
if exist('salout')

   switch MEXEC_G.Mship
      case 'cook'
         salvar = 'psal';
      case 'jcr'
         salvar = 'salinity';
   end
   salinline = ['y = tsgsal_apply_cal(x1,x2)'];

   MEXEC_A.MARGS_IN = {
      otfile1
      otfile2
      '/'
      ['time ' salvar]
      salinline
      [salvar '_cal']
      'pss-78'
      ' '
      };
  mcalc

end
