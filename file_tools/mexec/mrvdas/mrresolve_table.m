function [rtable, mtable] = mrresolve_table(tablein,varargin)
% function rtable = mrresolve_table(tablein)
% function [rtable, mtable] = mrresolve_table(tablein)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
%
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Return the name of the rvdas table, and optionally the mexec name, that
%   corresponds to the input mexec or rvdas table name.
%
% Examples
%
%   rtable = mresolve_table('tsg');
%
%   mresolve_table tsg; rtable = ans;
%
%   [rtable, mtable] = mrresolve_table('gnss_seapath_2');
%   [rtable, mtable] = mrresolve_table('sd025_gnss_seapath_320_2_ingga');
%
% Input:
%
% tablein: is an rvdas table name or the mexec shorthand
%
% Output:
%
% rtable: An rvdas table name. Either the same rvdas table name that was
%   input, or the  rvdas full name of the mexec shorthand.
% mtable: The mexec shorthand name corresponding to rtable.

% If the argument is given on the command line, then it will come in to
% tablein as a char string.

m_common

if isempty(tablein)
    error('Must specify non-empty tablein to lookup')
end
if nargin>1
    mrtv = varargin{1};
else
    mrtv = mrdefine;
end

tmap_mexec = mrtv.mstarpre;
tmap_rvdas = mrtv.tablenames;

rtable = []; mtable = [];
n = 0; nmax = 3;
while isempty(rtable) && isempty(mtable) && n<nmax

    krvdas = find(strcmp(tablein,tmap_rvdas), 1);
    kmexec = find(strcmp(tablein,tmap_mexec));

    if ~isempty(krvdas)
        % rvdas table name found
        rtable = tablein;
        if nargout>1
            mtable = tmap_mexec{krvdas};
        end
    elseif ~isempty(kmexec)
        % mexec shorthand table name found
        if length(kmexec) > 1 
            fprintf(MEXEC_A.Mfider,'%s\n%s\n','Input name is found more than once in the list of mexec shorthand names,','try one of the matching rvdas table names:');
            fprintf(MEXEC_A.Mfider,'%s\n',tmap_rvdas{kmexec})
            tablein = input('input new table name or ''q'' to quit ','s');
            if isempty(tablein) || strcmp(tablein,'q')
                n = nmax+1;
            end
        else
            rtable = tmap_rvdas{kmexec};
            if nargout>1
                mtable = tablein;
            end
        end
    end
        n = n+1;
end

if isempty(rtable) && isempty(mtable) % neither found
    fprintf(MEXEC_A.Mfider,'\n%s%s%s\n\n','Error trying to match name ''',tablein,'''');
    error('error in mrresolve_table. Input name is not found uniquely in the list of RVDAS names or mexec shorthand names');
end
