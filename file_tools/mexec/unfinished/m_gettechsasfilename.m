function fn = m_gettechsasfilename(ncfile)
% function fn = m_gettechsasfilename(ncfile)
%
% get the name of a techsas file. If there is an argument, unpack it; if
% not, prompt the keyboard

m_common

if nargin == 1 % take filename from argument
    fname = m_resolve_filename(ncfile);
    fn = fname.name;
else % prompt from keyboard
    msg = 'Type name of techsas file ';
    fn = m_getinput(msg,'s','no_ot');
end

MEXEC_A.MARGS_OT = [MEXEC_A.MARGS_OT fn];

return