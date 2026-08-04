function ms_generate_varname_translation_all

% Get list of all SCS streams and generate variable name translation tables
% for them all. 
%
% function ms_generate_varname_translation_all
%
% INPUT:
%   None. List of names comes from msnames command
%
% OUTPUT:
%   no output arguments
%   a rename file is created for each stream in cruise/data/templates directory,
%   eg scs_jr302_renamelist_seatex_gll.csv
%
% EXAMPLES:
%   ms_generate_varname_translation all
%
% UPDATED:
%   help comments added BAK 3 Jun 2014 on jr302

% bak for jr195 2009-sep-17 on nosea2
% run this script at the start of a cruise;
% edit the translation tables if needed.

m_common

all = msnames;

numnames = size(all,1);

for kloop = 1:numnames
    stream = all{kloop,3};
    ms_generate_varname_translation(stream);
end