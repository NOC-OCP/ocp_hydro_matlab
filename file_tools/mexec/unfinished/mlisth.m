function mlisth(varargin)

m_common
m_margslocal
m_varargs

fn = m_getfilename; % this uses the optional argument if there is one
ncfile.name = fn;

h = m_read_header(ncfile);
m_print_header(h)

return