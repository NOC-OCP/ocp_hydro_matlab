function vout = mtsg_cleanup(torg,time,vin,varinid)
%function vout = mtsg_cleanup(torg,time,vin,varinid)
%
% cleanup tsg data by excluding bad times from cruise-specific options
% torg is datenum of data origin in header
% time is in seconds, the usual mstar time variable
% varin is input variable, eg salinity or a temperature
% varinid tells you which variable to clean up, so we can
% select cases in the function. varinid is the variable name.

m_common

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
scriptname = 'mtsg_cleanup';
oopt = '';

dn = torg+time/86400;

MARGS_STORE = MEXEC_A.MARGS_IN_LOCAL; % need to save this because it would otherwise be used by mcsetd
switch MEXEC_G.Mship
   case {'cook' 'discovery'} % used on jc069
      prefix = 'met_tsg'; %discovery after some date should be different name maybe, or else one of the partial files should have a different name
   case 'jcr'
      prefix = 'oceanlogger';
end
roottsg = mgetdir(prefix);
MEXEC_A.MARGS_IN_LOCAL = MARGS_STORE;

vout = vin;

oopt = 'editvars'; get_cropt %which variables to edit based on bad times

oopt = 'kbadlims'; get_cropt
if iscell(kbadlims)
   for kb = 1:size(kbadlims,1)
      if ischar(kbadlims{kb,3}) & sum(strcmp(kbadlims{kb,3},'all'))
         edvar = editvars;
      else
         edvar = kbadlims{kb,3};
      end
      if sum(strcmp(varinid, edvar))
         kbad = find(dn >= kbadlims{kb,1} & dn <= kbadlims{kb,2});
	 vout(kbad) = NaN;
      end
   end
elseif sum(strcmp(varinid, editvars)) %always the same ones
   for kb = 1:size(kbadlims,1)
      kbad = find(dn >= kbadlims(kb,1) & dn <= kbadlims(kb,2));
      vout(kbad) = NaN;
   end
end

oopt = 'moreedit'; get_cropt %any other edits
