function sot = m_remove_spaces(sin)
% function sot = m_remove_spaces(sin)
%
% remove any spaces from string sin

s = sin;
k = strfind(sin,' ');
s(k) = [];
sot = s;
return