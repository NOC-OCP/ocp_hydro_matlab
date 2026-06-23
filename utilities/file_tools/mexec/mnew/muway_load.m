function [vdata, vunits] = muway_load(instream,dn1,dn2,varlist);
%
% wrapper to load variables in varlist from stream instream between datenum
% dn1 and dn2

m_common

switch MEXEC_G.Mshipdatasystem
    case 'techsas'
        [vdata, vunits] = mtload(instream,dn1,dn2,varlist);
    case 'scs'
        [vdata, vunits] = msload(instream,dn1,dn2,varlist);
    case 'rvdas'
        [vdata, vunits] = mrload(instream,dn1,dn2,varlist);
end
