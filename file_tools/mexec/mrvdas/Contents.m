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
% % These files generally do useful things
%
% mrgaps.m                    Load data from rvdas and search for gaps
% mrlast.m                    Load the last data cycle from the rvdas table
% mrlistit.m                  Load data from rvdas into matlab and list it to the screen
% mrlookd.m                   Show earliest and latest time in each rvdas table and number of cycles
% mrposinfo.m                 Get position from an rvdas table at the specified time
% mrrvdas2mstar.m             Load data from rvdas and save it to an mexec file
%
% % These files access the database (and may be called by the programs above): 
%
% mrdfinfo.m                  Get info about start and end time and number of cycles
% mrload.m                    Load rvdas data into matlab
% mrgettables.m               Make a list of all the tables in the rvdas database
% mrgettablevars.m            Look in the rvdas database and find the vars that are present for a table
% mrvars_info.m               List the variables names and units in a rvdas table
%
% % These files are mainly called by the programs above
% 
% mrconverttime.m             Convert an array of rvdas time strings to matlab datenum                   
% mrdefine.m                  Create definitions for mexec processing of rvdas dataa          
% mr_make_psql.m              Make the psql command string for mrload 
% mr_try_psql.m               Put together command with psql prefix and try with and without LD_LIBRARY
% mrparseargs.m               Parse the varargin cell arrays of most functions
% mrresolve_table.m           Return the name of the rvdas table
% mrgetrvdascontents.m        Get a list of the entire contents of the rvdas database
%
% % These files are called by mrdefine to set up the relationship between rvdas and mexec
%
% mrnames.m                   This lists the translations between rvdas table names and mexec short names (also called by mrposinfo.m)
% mrrename_varsunits.m           A lookup function for regularising rvdas variable names and units to our preferred format (also corrects for known spelling errors, and produces a list of variables which should have _raw appended to their name). This may need to be edited at the start of a cruise but should eventually pass through many cruises unchanged. 
% mrtables_from_json.m        The list of rvdas tables that mexec may want to copy. This should be (re)generated at the start of a cruise by running mrjson_get_list, and can then be edited by hand to comment out additional variables to be skipped (or these can be added to the cruise options file). 
%
% % These files are used for converting .json files to .mat files and reading information from them; mrjson_get_list should be run at the start of a cruise (and again if tables are added or variables modified)
% mrjson_get_list.m           Sync json files from rvdas machine, allow for editing list, then call mrjson_load_all to write to mrtables_from_json.m
% mrjson_load_all.m           Load json files, run jsondecode, then call internal function mrjson_show to parse sentences and output varible names and units to .m file
%


