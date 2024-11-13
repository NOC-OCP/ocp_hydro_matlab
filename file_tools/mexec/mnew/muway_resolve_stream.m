function strnm = muway_resolve_stream(stream)
%
% wrapper to translate mexec short name to input stream/table name for
% whichever data system is set in MEXEC_G

m_common

switch MEXEC_G.Mshipdatasystem
    case 'techsas'
        strnm = mtresolve_stream(stream);
    case 'rvdas'
        strnm = mrresolve_table(stream);
    case 'scs'
        strnm = msresolve_stream(stream);
end
