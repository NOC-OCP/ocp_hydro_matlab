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

dn = torg+time/86400;

MARGS_STORE = MEXEC_A.MARGS_IN_LOCAL; % need to save this because it would otherwise be used by mcsetd
scriptname = 'ship'; oopt = 'ship_data_sys_names'; get_cropt
roottsg = mgetdir(tsgpre);
MEXEC_A.MARGS_IN_LOCAL = MARGS_STORE;

vout = vin;

scriptname = mfilename; oopt = 'tsg_editvars'; get_cropt %which variables to edit based on bad times

scriptname = mfilename; oopt = 'tsg_badlims'; get_cropt
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

scriptname = mfilename; oopt = 'tsg_moreedit'; get_cropt %any other edits
