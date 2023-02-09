% mout_exch_sam: write the sample data in sam_cruise_all.nc to CCHDO exchange file
% Use: mout_exch_sam        
%
% variables to be written are listed in templates/exch_sam_varlist.csv, 
%    a comma-delimited list of vars to be renamed
%    The format of each column is
%    CCHDOname,CCHDOunits,mstarname,format string
%

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

scriptname = 'mout_exch'; oopt = 'woce_expo'; get_cropt
if ~exist('expocode','var')
    warning('no expocode set in opt_%s.m; skipping', mcruise)
    return
end

clear in out
in.type = 'sam'; 
out.type = 'exch';

%which vars to write
[vars, out.varsh] = m_exch_vars_list(2);
scriptname = 'mout_exch'; oopt = 'woce_vars_exclude'; get_cropt
[~,ia] = setdiff(vars(:,1),vars_exclude_sam);
out.vars_units = vars(ia,:);

%extras (variables to tile)
out.extras.expocode = expocode;
out.extras.sect_id = sect_id;
out.extras.castno = 1;

%header
scriptname = 'mout_exch'; oopt = 'woce_sam_headstr'; get_cropt

%%%%% write %%%%%
out.csvpre = fullfile(mgetdir('sum'), sprintf('%s_hy1',expocode));
status = mout_csv(in, out);
