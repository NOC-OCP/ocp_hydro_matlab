function d = mrdefine
% function d = mrdefine
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
%    d.mrtables.ships_gyro_hehdt
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


% Identify rvdas tables of interest from json files
[d.mrtables, d.mrtables_list] = mrtables_from_json; % d.mrtables_list is a list of RVDAS tables we want to be able to use


% get table of mexec short names for RVDAS tables
d.tablemap = mrnames('q'); % any argument suppresses listing to screen

% get a list of variables for which we want to change names when loaded
% into mexec
[d.renametables, d.renametables_list] = mrrename_tables('q'); % any argument suppresses listing to screen

% get a list of rvdas tables for which variables will be renamed as raw
% when they are read into mexec, because we expect to do post-processing on
% them

d.rawlist = mrmakeraw;

