function m_fix_hdr(otfile, hreplace)
% m_fix_hdr(otfile, hreplace)
%

m_common
otfile = m_add_nc(otfile);
h = m_read_header(otfile);

for fno = 1:size(hreplace,2)
    att = hreplace{1,fno};
    p = hreplace{2,fno};
    old = hreplace{3,fno};
    new = hreplace{4,fno};
    ii = find(strcmp(old, h.(['fld' att])) & contains(h.fldnam,p));
    if ~isempty(ii)
        nc_attput(otfile, h.fldnam{ii}, att, new);
    end
end
