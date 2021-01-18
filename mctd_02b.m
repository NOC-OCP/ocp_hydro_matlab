% mctd_02b: oxygen hysteresis and other corrections to raw file
%
% Use: mctd_02b        and then respond with station number, or for station 16
%      stn = 16; mctd_02;
%
% uses parameters set in mexec_processing_scripts/cruise_options/opt_${cruise}

minit; scriptname = mfilename;
mdocshow(scriptname, ['makes corrections/conversions (for instance for oxygen hysteresis), as set in get_cropt and opt_' mcruise '.m) and writes to ctd_' mcruise '_' stn_string '_24hz.nc']);

% resolve root directories for various file types
root_ctd = mgetdir('M_CTD');

prefix = ['ctd_' mcruise '_'];

%figure out which file to start from
infile = [root_ctd '/' prefix stn_string '_raw_cleaned'];
if ~exist(m_add_nc(infile), 'file')
   infile = [root_ctd '/' prefix stn_string '_raw'];
end
unix(['chmod u+w ' m_add_nc(infile)]);

otfile2 = [root_ctd '/' prefix stn_string '_24hz'];

oopt = 'calibs_to_do'; get_cropt

wkfile1 = ['wk1_mctd_02b_' datestr(now,30)];
wkfile2 = ['wk2_mctd_02b_' datestr(now,30)];
unix(['/bin/cp ' m_add_nc(infile) ' ' m_add_nc(wkfile1)]);

if ismember(dooxyhyst, -1) %reverse oxy hyst first
   wkfile3 = ['wk3_mctd_02b_' datestr(now,3)];
   oopt = 'oxyrev'; get_cropt;
   disp(['reversing oxy hyst for ' stn_string ', output to'])
   varnames
   MEXEC_A.MARGS_IN = {
   infile
   wkfile3
   '/'
   };
   for vno = 1:size(varnames,1)
      MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN
      var_strings{vno}
      sprintf('y = mcoxyhyst_reverse(x1,x2,x3,%f,%f,%f);', pars{vno}(1), pars{vno}(2), pars{vno}(3))
      varnames{vno}
      ' '
      ];
   end
   MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN
   ' '
   ];
   mcalc
   unix(['/bin/mv ' m_add_nc(wkfile3) ' ' m_add_nc(wkfile1)])   
end


if ismember(dooxyhyst, 1)
   oopt = 'oxyhyst'; get_cropt;
   disp(['applying oxy hyst for ' stn_string ', output to'])
   varnames
   MEXEC_A.MARGS_IN = {
   wkfile1
   wkfile2
   '/'
   };
   for vno = 1:size(varnames,1)
      MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN
      var_strings{vno}
      sprintf('y = mcoxyhyst(x1,x2,x3,%f,%f,%f,%i);',pars{vno}(1),pars{vno}(2),pars{vno}(3),vno)
      varnames{vno}
      ' '
      ];
   end
   MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN
   ' '
   ];
   mcalc;
   unix(['/bin/mv ' m_add_nc(wkfile2) ' ' m_add_nc(wkfile1)]);
end

if doturbV
   disp(['computing turbidity from turbidity volts for ' stn_string])
   oopt = 'turbV'; get_cropt
   MEXEC_A.MARGS_IN = {
   wkfile1
   'y'
   varname
   var_string
   sprintf('y = (x1-%f)*%f;', pars(2), pars(1))
   ' '
   'm^-1/sr'
   ' '
   };
   mcalib2;
end    

unix(['chmod a-w ' m_add_nc(infile)]);
unix(['/bin/mv ' m_add_nc(wkfile1) ' ' m_add_nc(otfile2)]);