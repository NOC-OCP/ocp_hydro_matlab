function sot = m_remove_outside_spaces(sin)
% function sot = m_remove_outside_spaces(sin)
%
% remove any outside spaces from a string

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
return