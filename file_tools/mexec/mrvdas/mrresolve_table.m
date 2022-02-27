function mrtable = mrresolve_table(tablein)
% function mrtable = mrresolve_table(tablein)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Return the name of the rvdas table that corresponds to the input mexec or
%    rvdas table name.
%
% Examples
%
%   mrtable = mresolve_table('tsg');
%
%   mresolve_table tsg; mrtable = ans;
%
% Input:
%
% tablein: is an rvdas table name or the mexec shorthand
%
% Output:
%
% mrtable: An rvdas table name. Either the same rvdas table name that was input, or the 
%   rvdas full name of the mexec shorthand.

% If the argument is given on the command line, then it will come in to
% tablein as a char string.

m_common

if isempty(tablein)
    error('Must specify non-empty tablein to lookup')
end

def = mrdefine;

tmap_mexec = def.tablemap(:,1);
tmap_rvdas = def.tablemap(:,2);

krvdas = find(strcmp(tablein,tmap_rvdas), 1);
kmexec = find(strcmp(tablein,tmap_mexec));

if ~isempty(krvdas)
    % rvdas table name found
    mrtable = tablein;
    return
elseif ~isempty(kmexec)
    % mexec shorthand table name found
    if length(kmexec) > 1 % the table is defective and an mexec short name appears more than once
        fprintf(MEXEC_A.Mfider,'\n%s%s%s\n\n','Error trying to match name ''',tablein,'''');
        error('error in mrresolve_table. Input name is found more than once in the list of mexec shorthand names');
    end
    mrtable = tmap_rvdas{kmexec};
    return
else % neither found
    fprintf(MEXEC_A.Mfider,'\n%s%s%s\n\n','Error trying to match name ''',tablein,'''');
    error('error in mrresolve_table. Input name is not found in the list of RVDAS names or mexec shorthand names');
end



