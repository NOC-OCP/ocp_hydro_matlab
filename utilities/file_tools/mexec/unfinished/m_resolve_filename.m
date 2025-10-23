function ncfile = m_resolve_filename(invar)
% function ncfile = m_resolve_filename(invar)
%
%sort out whether a filename is already a structure ncfile.name or just the
%filename component.

m_common

if nargin < 1
    error('Must supply precisely one argument to m_resolve_filename');
end

if isstruct(invar)
    % assume the real file name is field 'name' of struct variable ncfile
    if ~isfield(invar,'name')
        m1 = 'You are trying to resolve a filename in a ';
        m1a = 'structure variable but the field ''name'' is missing';
        m2 = 'The problem variable has fields';
        fprintf(MEXEC_A.Mfider,'%s\n',m1,m1a,m2);
        disp(invar)
        error(' ')
    end
    ncfile = invar;
else
    %its just a simple file name
    ncfile.name = invar;
end


ncfile.name = m_add_nc(ncfile.name);