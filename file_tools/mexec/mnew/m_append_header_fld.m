function h = m_append_header_fld(h, newnames, newunits, newserv);
% h = m_append_header_fld(h, newnames, newunits, var_to_copy);
% h = m_append_header_fld(h, newnames, newunits, newserials);
%
% append to names and units stored in h.fldnam and h.fldunt, keeping
% consistent sizes of the other variable attribute, h.fldserial, by either
% copying from var_to_copy, or putting in empty strings, or using
% newserials
%
%

h.fldnam = [h.fldnam newnames];
h.fldunt = [h.fldunt newunits];
if isfield(h, 'fldserial')
    nn = length(newnames);
    if iscell(newserv)
        h.fldserial = [h.fldserial newserv];
    elseif isempty(newserv)
        h.fldserial = [h.fldserial repmat({' '},1,nn)];
    else
        s = strcmp(newserv,h.fldnam);
        h.fldserial = [h.fldserial repmat(h.fldserial(s),1,nn)];
    end
end