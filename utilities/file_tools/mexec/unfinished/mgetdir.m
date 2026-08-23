function mpath = mgetdir(M_ABBREV)
%function mpath = mgetdir(M_ABBREV);
%function mpath = mgetdir(abbrev);
%
% outputs the full path to the directory for data of type abbrev
%   set in m_setup
%
% e.g. root_sal = mgetdir('bot_sal');
%   or root_sal = mgetdir('M_BOT_SAL');
%   might give root_sal = '/local/users/pstar/cruise/data/ctd/BOTTLE_SAL';

m_common
fnames = fieldnames(MEXEC_G.MDIRLIST);

% Find matching rows using the extracted field names
ii = find(strcmp(M_ABBREV, fnames) | strcmp(['M_' upper(M_ABBREV)], fnames));

if length(ii)>1
    warning('%s set %d times in m_setup', M_ABBREV, length(ii))
elseif isempty(ii)
    warning('%s not set in m_setup, using default mexec_data_root', M_ABBREV)
    mpath = MEXEC_G.mexec_data_root;
    return
end

% Convert the index 'ii(1)' back to a string name, then read the struct dynamically
targetField = fnames{ii(1)};
mpath = fullfile(MEXEC_G.mexec_data_root, MEXEC_G.MDIRLIST.(targetField));
