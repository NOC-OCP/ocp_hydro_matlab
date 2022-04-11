% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Library of routines to enable access to rvdas files
% requires the mexec setup to be configured
%
% Programs begin "mr", and have their own help comments
% 
% Many of the functions have variable arguments parsed by mrparseargs,
%   which has extensive help comments. 
% mrparseargs recognises arguments common to most functions including
%   table names, datenums/detevecs, variable lists, the quiet flag, 
%   and other numbers and strings.
%
% Contents.m                  this file
%
% % These files generally do useful things;
%
% mrdfinfo.m                  Get info about start and end time and number of cycles
% mrgaps.m                    Load data from rvdas and search for gaps
% mrgettables.m               Make a list of all the tables in the rvdas database
% mrlast.m                    Load the last data cycle from the rvdas table
% mrlistit.m                  Load data from rvdas into matlab and list it to the screen
% mrload.m                    Load rvdas data into matlab
% mrlookd.m                   Show earliest and latest time in each rvdas table and number of cycles
% mrnames.m                   Define and show rvdas table names and their mexec short equivalents
% mrposinfo                   Get position from an rvdas table at the specified time
% mrrvdas2mstar.m             Load data from rvdas and save it to an mexec file; calls mrload.m
% mrvars.m                    List the variables names and units in a rvdas table
%
% % These files are mainly called by the programs above
% 
% mrconverttime.m             Convert an array of rvdas time strings to matlab datenum                   
% mrdefine.m                  Create definitions for mexec processing of rvdas dataa          
% mr_make_psql.m              Make the psql command string for mrload 
% mrparseargs.m               Parse the varargin cell arrays of most functions
% mrresolve_table.m           Return the name of the rvdas table
% mrgetrvdascontents.m        Get a list of the entire contents of the rvdas database
% mrgettablevars              Look in the rvdas database and find the vars that are present for a table
%
% % These files are used to set up the relationship between rvdas and mexec
%   The files may need to be edited at the start of a cruise, but should pass through
%   many cruises without being modified
%
% mrmakeraw.m                 Make a list of rvdas tables whose variables will be renamed to _raw when read in with mrload          
% mrrename_tables.m           A list of rvdas variable names and units we wish to rename              
% mrtables_from_json.m        Make the list of rvdas tables that mexec may want to copy                    
%
% % These files are used for converting .json files to .mat files and reading information out of them
%   The json files describe the contents of the rvdas tables - variable names
%   and units. Since units aren't stored in the database (true on JC211 at 28 Jan
%   2021) we get units from the .json files. At present the path names are
%   local, so the functions have to be run in the directory where the json
%   and mat files are.
%
% mrjson2mat_all.m            Run function mrjson2mat on a set of json files       
% mrjson2mat.m                Decode a .json file to a .mat file. Needs jsondecode
% mrshow_json_all.m           Run function mrshow_json on a set of json/mat files    
% mrshow_json.m               Show the sentences in the rvdas json file, and store variable names and units.
%
%
%


