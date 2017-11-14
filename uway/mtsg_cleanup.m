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

cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
scriptname = 'mtsg_cleanup';
oopt = '';

dn = torg+time/86400;

oopt = 'kbadlims'; get_cropt
MARGS_STORE = MEXEC_A.MARGS_IN_LOCAL; % need to save this because it would otherwise be used by mcsetd
roottsg = mgetdir('M_MET_TSG');
MEXEC_A.MARGS_IN_LOCAL = MARGS_STORE;

kbadall = [];
for kb = 1:size(kbadlims,1)
    kbad = find(dn >= kbadlims(kb,1) & dn <= kbadlims(kb,2));
    kbadall = [kbadall(:)' kbad(:)'];
end

oopt = 'vout'; get_cropt
vout = vin; vout(kbadall) = NaN;
