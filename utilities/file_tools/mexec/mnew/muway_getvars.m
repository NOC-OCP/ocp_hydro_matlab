function [vars, units] = muway_getvars(instream)
%
% wrapper to get list of vars and units in a given stream depending on the
% data system type (techsas, scs, rvdas) set in MEXEC_G

m_common

switch MEXEC_G.Mshipdatasystem
    case 'techsas'
        [vars, units] = mtgetvars(instream);
    case 'scs'
        [vars, units] = msgetvars(instream);
    case 'rvdas'
        [vars, units] = mrgettablevars(instream);
end

