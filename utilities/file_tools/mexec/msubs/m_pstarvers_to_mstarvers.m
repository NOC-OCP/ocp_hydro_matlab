function v_ot = m_pstarvers_to_mstarvers(v_in)
% function v_ot = m_pstarvers_to_mstarvers(v_in)
%
% convert 2 char pstar version to numeric mstar vers
% allow upper or lower case characters
% allow pstar versions to range from 'space-space'  to 'space-Z' 
% followed by 'AA', 'AB', etc, because early pstar files could have 'space'
% as the first character of a 2-char version. 
% However, since most pstar files in recent times start with 'AA', we
% choose to convert 'AA' --> 1.
% Thus 
% '  ' --> -26
% ' Z' -->   0
% 'AA' -->   1
% 'ZZ' --> 676
%
% There should be no problem with negative version numbers in mstar

s = sprintf('%2s',v_in);   %ensure pad to 2 chars

s1 = s(1);
s2 = s(2);

% convert any nulls to spaces in case legacy pstar files happen to contain
% nulls. I don't know if this can ever happen or not, bu tbetter safe than
% sorry.
if strcmp(s1,char(0)); s1 = ' '; end
if strcmp(s2,char(0)); s2 = ' '; end

s_all = ' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'; %allow lower case 

k1 = strfind(s_all,s1);
if isempty(k1)
    error(['unexpected input pstar version '''  v_in ''' in m_pstarvers_to_mstarvers'])
end
if k1 <= 27; n1 = k1-1; end
if k1 >= 28; n1 = k1-27; end

k2 = strfind(s_all,s2);
if isempty(k2)
    error(['unexpected input pstar version '''  v_in ''' in m_pstarvers_to_mstarvers'])
end
if k2 <= 27; n2 = k2-1; end
if k2 >= 28; n2 = k2-27; end

v_ot = (n1-1)*26+n2;