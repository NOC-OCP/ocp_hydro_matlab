function d = mrdefine(varargin)
% function d = mrdefine
% function d = mrdefine('this_cruise')
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Create definitions for mexec processing of rvdas data
%
% Examples
%   
%   def = mrdefine
%
% Input:
%
% none
%
% Output:
%
% structure d
% eg
%   d = 
% 
%              mrtables: [1x1 struct]
%         mrtables_list: {25x1 cell}
%              tablemap: {26x2 cell}
%          renametables: [1x1 struct]
%     renametables_list: {16x1 cell}
%               rawlist: {6x1 cell}
%
% d.mrtables: a structure with one field for each table in rvdas that we 
%    are interested in, defined in mrtables_from_json. This is a subset of
%    about 25 of all the possible rvdas tables, which number about 70. eg
%    d.mrtables.ships_gyro_hehdt. If an input argument is supplied and is
%    'this_cruise', tables will be further limited to those in the current
%    cruise's database using mrgettables. (Once there is a metadata
%    database rather than using json files this step may be obsolete). 
% d.mrtables_list: A list of the fields in d.mrtables in a cell array. This
%    would be equivalent to fieldnames(d.mrtables)
% d.tablemap: The list that pairs RVDAS table names and mexec short names;
%    defined in mrnames.m. Each table has an rvdas name and a simpler mexec
%    name.eg
%    'pospmv'       'posmv_pos_gpgga' 
% d.renametables: A list of old and new variable or unit names that will be
%    changed when rvdas data are read in. Defined in mrrename_tables.m
%    d.renametables is a structure. The fields are the names of the table
%    for which there is renaming to be done and the values of the fields
%    are cell array with old names and units and new names and units
%    d.renametables.sbe45_tsg_nanan = {
%    'housingWaterTemperature'     'DegreesCelsius'    'temp_housing'    'degreesC'
%    'remoteWaterTemperature'      'DegreesCelsius'    'temp_remote'     'degreesC'
%    }
% d.renametables_list: A list of any tables in rvdas that will have some
%    variables renamed. Equivalent to (fieldnames(d.renametables))
% d.rawlist: A list of tables, in a cell array ,that will have names changed to _raw when
%    rvdas data are read in. Defined in mrmakeraw.m. This is because we
%    expect some variables in these files to be modified in postprocessing
%    and we want to be able to identify raw data.
%
% calls mrtables_from_json, mrnames, mrrename_varunits
%
% With optional input argument: 
%   'this_cruise': also calls mrgettables and limits lists to tables
%     actually in database for current cruise 


% Identify rvdas tables of interest from json files
d.mrtables = mrtables_from_json; % d.mrtables_list is a list of RVDAS tables we want to be able to use
d.mrtables_list = fieldnames(d.mrtables);
if nargin>0 && ismember('this_cruise',varargin)
    %compare to list of tables found by querying the database
    rt = fieldnames(mrgettables);
    [~, ia] = setdiff(d.mrtables_list,rt);
    if ~isempty(ia)
        d.mrtables = rmfield(d.mrtables,d.mrtables_list(ia));
        d.mrtables_list(ia) = [];
        warning('rvdas:mrdefine:mjsonextra','%d tables in .json files but not present for this cruise',length(ia))
        warning('off','rvdas:mrdefine:mjsonextra')
    end
end

% get table of mexec short names for RVDAS tables
d.tablemap = mrnames_new(d.mrtables_list,'q');
% limit to the names actually in mrtables_from_json
[~,ia,ib] = intersect(d.tablemap(:,2),d.mrtables_list,'stable');
d.tablemap = d.tablemap(ia,:);
if length(ib)<length(d.mrtables_list)
    ii = setdiff(1:length(d.mrtables_list),ib);
    warning('rvdas:mstar:no_match','discarding %d tables with no mstar lookup in mrnames_new',length(ii));
    warning('off','rvdas:mstar:no_match');
    d.mrtables = rmfield(d.mrtables,d.mrtables_list(ii));
    d.mrtables_list(ii) = [];
end
[~,ia] = unique(d.tablemap(:,1),'first');
if length(ia)<size(d.tablemap,1)
    warning('rvdas:mrdefine:mnamedup','duplicate mexec short names (with matching tables) detected; keeping first')
    warning('off','rvdas:mrdefine:mnamedup'); %only warn once per session
end
%d.tablemap = d.tablemap(ia,:);

% get a list of variables for which we want to change names when loaded
% into mexec, and a list of tables whose variables should have _raw
% appended
[d.renametables, d.rawlist] = mrrename_varsunits(d.mrtables, 'q'); % any argument suppresses listing to screen
d.renametables_list = fieldnames(d.renametables);


