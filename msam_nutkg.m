%script to run on the final sample file to produce a version
%with nutrients in umol/kg rather than umol/L

scriptname = 'msam_nutkg';
stn = 0; minit
mdocshow(scriptname, ['add documentation string for ' scriptname])

root_ctd = mgetdir('M_CTD');
infile = [root_ctd '/sam_' mcruise '_all'];
otfile = [root_ctd '/sam_' mcruise '_all_nutkg'];

oopt = 'tlab'; get_cropt

%figure out which of the possible nutrients variables we have here
h = m_read_header(infile);
nutvars = {'silc' 'phos' 'totnit' 'tn' 'tp' 'no2' 'don' 'dop'};
isn = zeros(length(nutvars),1);
for no = 1:length(nutvars)
   ii = find(strcmp(nutvars{no}, h.fldnam));
   if ~isempty(ii)
      isn(no) = 1;
      if ~strcmpi(h.fldunts{ii}, 'umol/L')
         warning([h.fldnam{ii} ' units not umol/L but ' h.fldunts{ii} '; excluding from conversion])
	 isn(no) = 0;
      end
   end
end
nutvars = nutvars(isn);


%--------------------------------
MEXEC_A.MARGS_IN = {infile; otfile; '/'};
for no = 1:length(nutvars)
   MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
   [nutvars{no} ' asal']
   sprintf('y = x1./gsw_rho_t_exact(x2, %f, 0)', tlab);
   [nutvars{no} '_per_kg']
   'umol/kg'
end
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
mcalc
%--------------------------------
