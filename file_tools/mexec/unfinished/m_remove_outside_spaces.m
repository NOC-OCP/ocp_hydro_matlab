function sot = m_remove_outside_spaces(sin)
% function sot = m_remove_outside_spaces(sin)
%
% remove any outside spaces from a string
% YLF edit jr17001: unless the string is just a single space

if length(sin)==1 & ~strncmp(sin, ' ', 1)
    sot = sin;
else
    s = [ ' ' sin ' '];

    while strcmp(s(1),' ') == 1
        s(1) = [];
        if isempty(s); break; end
    end

    s = [s ' '];
    while strcmp(s(end),' ') == 1
        s(end) = [];
        if isempty(s); break; end
    end

    sot = s;
end
return