function [data, units] = muway_last(instream)
%
% wrapper to get the last values from stream instream, for whichever ship
% data system

m_common

switch MEXEC_G.Mshipdatasystem
    case 'techsas'
        [data, units] = mtlast(instream);
    case 'scs'
        [data, units] = mslast(instream);
    case 'rvdas'
        [data, units] = mrlast(instream);
end
