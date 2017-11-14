function fn = m_getfilename(ncfile)
% function fn = m_getfilename(ncfile)
% get the name of an mstar file. If there is an argument, unpack it; if
% not, prompt the keyboard

m_common

if nargin == 1 % take filename from argument
    fname = m_resolve_filename(ncfile);
    fn = fname.name;
else % prompt from keyboard
    msg = 'Type name of mstar file ';
    fn = m_getinput(msg,'s','no_ot');
end


fn = m_add_nc(fn);
% DAS change 
% MEXEC_A.MARGS_OT = [MEXEC_A.MARGS_OT fn];
if isfield(MEXEC_A,'MARGS_OT')
   MEXEC_A.MARGS_OT = [MEXEC_A.MARGS_OT fn];
else
   MEXEC_A.MARGS_OT = [fn];
end

return