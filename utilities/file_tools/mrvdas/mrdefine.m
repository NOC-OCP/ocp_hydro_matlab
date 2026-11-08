function mrtv = mrdefine(varargin)
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
%
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Create definitions for mexec processing of rvdas data

if nargin>0
    quiet = varargin{1};
else
    quiet = 1;
end

% Identify rvdas tables present in database
mrtables = mrgetrvdascontents(quiet);

% Limit to the tables and variables we want to load, add mstar names
limit = [1 1];
mrtables_use = mrdef_mstarnames(mrtables, limit);

% Check .json files for information on units
mrtables_use = mrdef_json(mrtables_use);

% get a list of variables for which we want to change names when loaded
% into mexec, and a list of tables whose variables should have _raw
% appended
mrtv = mrdef_rename_varsunits(mrtables_use);
