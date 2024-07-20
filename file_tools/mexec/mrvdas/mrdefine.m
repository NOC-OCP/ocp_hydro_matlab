function mrtv = mrdefine(varargin)
% function mrtv = mrdefine
% function mrtv = mrdefine('reload')
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
%
% calls mrtables_from_json, mrnames, mrrename_varunits
%
% With optional input arguments (order unimportant):
%   'this_cruise': also calls mrgettables and limits lists to tables
%     actually in database for current cruise
%   'check_missing': also prints list of tables defined in mrnames but not
%     in mrtables (for this cruise)

m_common
%save to readable (and git-friendly) .csv
tabledefcsv = fullfile(fileparts(mfilename('fullpath')),'rvtabledef.csv');
%but it doesn't load back in the same way, so also save as .mat
tabledefmat = fullfile(MEXEC_G.mexec_data_root,'rvdas','rvtabledef.mat');

if nargin>0 && strcmp(varargin{1},'reload')

    quiet = 1; if nargin>1; quiet = varargin{2}; end

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

    writetable(mrtv, tabledefcsv, 'Delimiter', ',')
    save(tabledefmat, 'mrtv')

else

    df = dir(tabledefmat);
    fprintf(1,'loading %s\n saved on %s\n',tabledefmat,df.date)
    load(tabledefmat,'mrtv')

end

%***write something to parse .csv file correctly later? .mat is kept with
%the backup of the raw data though
