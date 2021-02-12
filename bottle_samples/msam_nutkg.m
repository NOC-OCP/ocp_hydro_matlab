%script to run on the final sample file to produce a version
%with nutrients in umol/kg rather than umol/L

stn = 0; minit; scriptname = mfilename;
mdocshow(scriptname, ['converts nutrients from /L in sam_' mcruise '_all.nc to /kg in sam_' mcruise '_all_nutkg.nc'])

root_ctd = mgetdir('M_CTD');
infile = [root_ctd '/sam_' mcruise '_all'];
otfile = [root_ctd '/sam_' mcruise '_all_nutkg'];

%figure out which of the possible nutrients variables we have here
h = m_read_header(infile);
nutvars = {'silc' 'phos' 'totnit' 'tn' 'tp' 'no2' 'don' 'dop'};
isn = zeros(length(nutvars),1);
for no = 1:length(nutvars)
   ii = find(strcmp(nutvars{no}, h.fldnam));
   if ~isempty(ii)
      isn(no) = 1;
      if ~strcmpi(h.fldunt{ii}, 'umol/L')
         warning([h.fldnam{ii} ' units not umol/L but ' h.fldunt{ii} '; excluding from conversion'])
	 isn(no) = 0;
      end
   end
end
nutvars = nutvars(logical(isn));

oopt = 'labtemp'; get_cropt

%--------------------------------
MEXEC_A.MARGS_IN = {infile; otfile; '/'};
for no = 1:length(nutvars)
   MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
   [nutvars{no} ' uasal']
   'y = x1./(gsw_rho_t_exact(x2, ' num2str(labtemp) '+zeros(size(x2)) , 0)/1000);'
   [nutvars{no} '_per_kg']
   'umol/kg'];
end
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
mcalc
%--------------------------------
