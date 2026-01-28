function status = mrrvdas2mstar(varargin)
% function status = mrrvdas2mstar(table, dn1, dn2, otfile, dataname, varlist, qflag);
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Load data from rvdas table and save it to an mexec file. This is done
% with a call to mrload.
%
% Examples
%
%   mrrvdas2mstar('surfmet',[28 0 0 0],[28 23 59 59],'surfmetwind_jc211_d028_raw','surfmet_jc211_d028','windspeed,winddirection','q');
%
%   mrrvdas2mstar surfmet [28 0 0 0] [29 23 59 59] surfmetflow_jc211_d028_raw surfmet_jc211_d028 'flow,fluo'
%
% Input:
% 
% The input arguments are parsed through mrparseargs. See the extensive
%   help in that function for descriptions of the arguments.
% table: is the rvdas table name or the mexec shorthand
% dn1 and dn2 are datevecs or datenums for the start and end of data.
% If qflag is 'q', fprintf will be suppressed in the call to mrload. Note
%   that this does not suppress the mexec processing output from msave.
% otfile is the mexec file name. Default is the same as the mexec table
%   name
% dataname is the mexec dataname. Default is the same as the mexec table
%   name
% varlist is a list of rvdas variable names to be loaded. Default is all.
%
% otfile, dataname and varlist are read off the list of arguments in order.
% So to use dataname, otfile must be present. To use varlist, otfile and
% dataname must both be present.
%
% Output: 
% 
% Saves an mexec NetCDF file

 
m_common
status = 1;

if nargin>0 && strcmp(varargin{1},'noparse')
    argot = varargin{2};
    otfile = argot.otfile;
    dataname = argot.dataname;
else
    argot = mrparseargs(varargin); % varargin is a cell array, passed into mrparseargs
    if length(argot.otherstrings)<1
        otfile = argot.table;
    else
        otfile = argot.otherstrings{1};
    end
    if length(argot.otherstrings)<2
        dataname = otfile;
    else
        dataname = argot.otherstrings{2};
    end
end
clear varargin % because otherwise they confuse msave

otfile = m_add_nc(otfile);

[dd, names, units] = mrload('noparse',argot);

if numel(dd.dnum) == 0
    % no data found, quit without writing a file
    warning('No data cycles loaded with mrload from %s',argot.table)
    return
end

%change dnum to mexec time in seconds
to = ['seconds since ' datestr(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,'yyyy-mm-dd HH:MM:SS')];
dd.time = m_commontime(dd.dnum,'datenum',to);
names = [names; 'time'];
opt1 = 'mstar'; get_cropt
if docf
    units = [units; to];
else
    units = [units; 'seconds'];
end
dd = rmfield(dd, 'dnum');
[names, ia] = setdiff(names, {'dnum'}, 'stable');
units = units(ia);

%add variable names and units to hnew, or remove from dd
%also remove duplicate times, after (if set in opt_cruise) subsampling
%and/or rounding times
opt1 = 'uway_proc'; opt2 = 'tstep_save'; get_cropt
tstep = 1;
if ~isempty(tstep_force)
    dt = diff(dd.time); dt = dt(dt>0); 
    dt = mode(dt);
    tstep = max(round(1/dt),1); 
end
if ~isempty(tstep_resol)
    dd.time = round(dd.time/tstep_resol)*tstep_resol;
end
if tstep>1
    iits = 1:tstep:length(dd.time);
    [~,iit] = unique(dd.time(iits),'stable');
    iit = iits(iit);
else
    [~,iit] = unique(dd.time,'stable');
end
iit = iit(~isnan(dd.time(iit)));

clear hnew
hnew.fldnam = names(:)';
hnew.fldunt = units(:)';
m = false(1,length(names));
for kl = 1:length(names)
    vname = names{kl};
    if isnumeric(dd.(vname))
        m(kl) = true;
        dd.(vname) = dd.(vname)(iit);
    else
        dd = rmfield(dd,vname);
        warning('skipping non-numeric variable %s from table %s',vname,argot.table)
    end
end
hnew.fldnam = hnew.fldnam(m); hnew.fldunt = hnew.fldunt(m);

if docf
    hnew.data_time_origin = [];
else
    hnew.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
end

hnew.dataname = dataname;
hnew.comment = ['Variables written from rvdas to mstar at ' datestr(now,31) ' by ' MEXEC_G.MUSER MEXEC_G.COMMENT_DELIMITER_STRING];
if exist(m_add_nc(otfile),'file')
    mfsave(otfile, dd, hnew, '-merge', 'time');
else
    mfsave(otfile, dd, hnew);
end
status = 0;
