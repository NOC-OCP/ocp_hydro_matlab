function d = mrvars(varargin)
% function d = mrvars(table,qflag)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
% 
% Get info about the variables in an rvdas table
%
% Examples
%
%   d = mrvars('pospmv','q');
%
%   mrvars pospmv q; d = ans;
%
%   mrvars pospmv;
%
% Input:
%
%   table: can be an mexec or rvdas table name
%   qflag: optional. If set to 'q' will suppress printing to screen
%
% Output:
%
%  Structure d has a field d.vdef which is a table definition of names and units
%    variable names are output in lowercase, even if uppercase in rvdas.

m_common

argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs
table = argot.table;
qflag = argot.qflag;


if nargin < 1
    error('error, no arguments in mrdfinfo')
end

def = mrdefine;


% sort out the table name
table = mrresolve_table(table); % table is now an RVDAS table name for sure.

vdef = def.mrtables.(table);



% now print names and units

vuse = vdef;
vuse{1,1} = 'time';
vuse{1,2} = 'string';

vuse(:,1) = lower(vuse(:,1));

d.vdef = vuse;

if ~isempty(qflag)
    return % skip printing
end

fprintf(MEXEC_A.Mfidterm,'\n%s\n\n',table);

for kl = 1:size(vuse,1)
    pad = '                                                           ';
    q = '''';
    s1 = vuse{kl,1}; s1 = [pad q s1 q]; s1 = s1(end-40:end);
    s2 = vuse{kl,2}; s2 = [q s2 q pad]; s2 = s2(1:30);
    
    fprintf(MEXEC_A.Mfidterm,'%s %s\n',s1,s2);
end


return






