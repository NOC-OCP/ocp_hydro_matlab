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
% (at the start of a cruise, sync the .json files, and run mrjson_get_list.m)
%
% % These files generally do useful things
%
% mrgaps.m                    Load data from rvdas and search for gaps
% mrlast.m                    Load the last data cycle from the rvdas table
% mrlistit.m                  Load data from rvdas into matlab and list it to the screen
% mrlookd.m                   Show earliest and latest time in each rvdas table and number of cycles
% mrposinfo.m                 Get position from an rvdas table at the specified time
% mrrvdas2mstar.m             Load data from rvdas and save it to an mexec file
% mrload.m                    Load rvdas data into matlab
%
% % These files access the database (and may be called by the programs above): 
%
% mrdfinfo.m                  Get info about start and end time and number of cycles
% mrgettables.m               Make a list of all the tables in the rvdas database
% mrgettablevars.m            Look in the rvdas database and find the vars that are present for a table
%
% % These files are mainly called by the programs above
% 
% mrconverttime.m             Convert an array of rvdas time strings to matlab datenum                   
% mrdefine.m                  Create, or load, definitions for mexec processing of rvdas dataa          
% mr_make_psql.m              Make the psql command string for mrload 
% mr_try_psql.m               Put together command with psql prefix and try with and without LD_LIBRARY
% mrparseargs.m               Parse the varargin cell arrays of most functions
% mrresolve_table.m           Return the name of the rvdas table, based on the mexec name
%
% % These files are probably called once when setting up the cruise (once
%   the database is running), by running
% mrdefine('reload')
% 
% mrgetrvdascontents.m        Get a list of the entire contents of the rvdas database (calling mrgettables and mrgettablevars)
% mrdef_mstarnames.m          Call mstar_dirs_tables and limit to tables with mstar definitions
% mrdef_dirs_tables.m         This lists the translations between rvdas table names and mexec short names
% mrdef_json.m                Load json files, run jsondecode, parse sentences and add to lookup table
% mrdef_rename_varsunits.m    A lookup function for regularising rvdas variable names and units to our preferred format (also corrects for known spelling errors, and produces a list of variables which should have _raw appended to their name). This may need to be edited at the start of a cruise but should eventually pass through many cruises unchanged. 
%
% % This file is called once per session (or if variables cleared)
% mrvdas_check_dbaccess       Check credentials, store status in global
%                             variable***


