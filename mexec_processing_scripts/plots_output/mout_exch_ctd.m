% mout_exch_ctd: write data from ctd_cruise_nnn_2db.nc to CCHDO exchange file
% Use: mout_exch_ctd        
%
% edit jc159 so that this can write a file for exch and also a file 
% containing other uncalibrated ctd variables for internal use, if 
% writeallctd exists and is set to 1. in this case it will get the template
% from all_ctd_renamelist and write to outfileall rather than outfile (both
% are set in opt_cruise)***

opt1 = 'castpars'; opt2 = 'minit'; get_cropt

opt1 = 'mout_exch'; opt2 = 'woce_expo'; get_cropt
if ~exist('expocode','var')
    warning('no expocode set in opt_%s.m; skipping', mcruise)
    return
end

clear in out
in.type = 'ctd'; in.stnlist = stnlocal;
out.type = 'exch';

%which vars to write
[vars, varsh] = m_exch_vars_list(1);
opt1 = 'mout_exch'; opt2 = 'woce_vars_exclude'; get_cropt
[~,ia] = setdiff(vars(:,1),vars_exclude_ctd);
out.vars_units = vars(ia,:);

%header
opt1 = 'mout_exch'; opt2 = 'woce_ctd_headstr'; get_cropt
status = mout_csv(in, out);
