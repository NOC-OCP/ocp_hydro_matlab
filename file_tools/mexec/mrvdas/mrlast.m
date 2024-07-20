function [dd,varnames,varunits] = mrlast(varargin)
% function mrlast(table,qflag)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Load data from the rvdas table. Load 1 second that spans the latest time,
% and report the last cycle in that one second.
%
% Calls mrdfinfo to determine the latest time, and mrload to load the data.
% This could be made quicker by directly calling and processing the last
% cycle, but mrload looks after variable naming.
%
% Examples
%
%   dd = mrlast('tsg','q');
%
%   [dd,varnames,varunits] = mrlast('tsg','q');
% 
%   mrlast tsg;
%
%   mrlast tsg q; dd = ans;
%
% Input:
%
% The input arguments are parsed through mrparseargs. See the extensive
%   help in that function for descriptions of the arguments.
%
% table: is the rvdas table name or the mexec shorthand
% If qflag is 'q', fprintf will be suppressed in calls to mrdfinfo and 
%   mrload. Default is ''.
%
% Output:
%
% Listing to screen
% dd   : data structure, in which the fieldnames should match the variable
%          names in the names cell array.
% varnames: cell array of names of the fields in the data structure
% varunits: cell array of units that correspond to the names, with the same indexing
% 
% Unless exactly 3 output variables are specified in the call, varnames and
%   varunits are added to the dd structure.
%
% If no data are found, empty arrays of size [0x1 double] are returned in
%   the fields in dd.


m_common

argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs
rtable = argot.table;
qflag = argot.qflag;
mrtv = argot.mrtv;

d = mrdfinfo('noparse','rtable',rtable,'qflag',qflag,'mrtv',mrtv);

dstart = floor(86400*d.dn2)/86400;
dend = ceil(86400*d.dn2)/86400;
argot.dnums = [dstart dend];

if isempty(qflag); fprintf(MEXEC_A.Mfidterm,'\n'); end
[dd,nn,uu] = mrload('noparse',argot);
if isempty(qflag); fprintf(MEXEC_A.Mfidterm,'\n'); end

nvar = length(nn);

for kl = 1:nvar
    vname = nn{kl};
    vunits = uu{kl};
    vdata = dd.(vname);
    if numel(vdata) == 0
        vd = nan;
    else
        vd = vdata(end);
    end
    if iscell(vd)
        vd = vd{1};
    end
    if ischar(vd)
        continue
    end
    dnum = 0;
    if strcmp(vname,'dnum')
        dnum = 1;
    end
    vname = [repmat(' ',1,30) vname];
    vname = vname(end-30:end);
    if isempty(qflag)
        if dnum == 1
            if isfinite(vd)
                datestring = datestr(vd,31);
            else
                datestring = 'No data found';
            end
            fprintf(MEXEC_A.Mfidterm,'%s : %s\n',vname,datestring);
        else
            try
            fprintf(MEXEC_A.Mfidterm,'%s : %19.6f     %s\n',vname,vd,vunits);
            catch; keyboard; end
        end
    end
end

switch nargout
    case 3
        varnames = nn;
        varunits = uu;
    otherwise % unless exactly 3 output arguments are specified, add the names and units to the structure
        dd.varnames = nn;
        dd.varunits = uu;
end


return
