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
% (at the start of a cruise, sync the .json files)
%
% % These files generally do useful things
%
% mrgaps.m                    Load data from rvdas and search for gaps
% mrlast.m                    Load the last data cycle from the rvdas table
% mrlistit.m                  Load data from rvdas into matlab and list it
%                               to the screen 
% mrlookd.m                   Show earliest and latest time in each rvdas
%                               table and number of cycles 
% mrposinfo.m                 Get position from an rvdas table at the
%                               specified time 
% mrrvdas2mstar.m             Load data from rvdas and save it to an mexec
%                               file (calls mrload)
% mrload.m                    Load rvdas data into matlab
% mrdefine.m                  Create, or load, definitions for mexec
%                               processing of rvdas data; output is a Matlab
%                               table with one row for each RVDAS
%                               table/view that will be processed,
%                               containing information on variables to be
%                               loaded as well as mstar name and location
%                               for processed data
%
%
% % These files access the database (and may be called by the programs
%     above):  
%
% mrdfinfo.m                  Get info about start and end time and number
%                               of cycles 
% mrgettables.m               Make a list of all the tables in the rvdas
%                               database 
% mrgettablevars.m            Look in the rvdas database and find the vars
%                               that are present for a table 
% mr_try_psql.m               Put together command with psql prefix and try
%                               with and without LD_LIBRARY 
%
% % These files are mainly called by the programs above
% 
% mrconverttime.m             Convert an array of rvdas time strings to 
%                               matlab datenum                   
% mr_make_psql.m              Make the psql command string for mrload
% mrparseargs.m               Parse the varargin cell arrays, or
%                               structures, of most top-level mr functions 
% mrresolve_table.m           Check the supplied name is an rvdas table, or
%                               if not, list the possible matches and
%                               prompt to supply another name
%
% % These files are called by running (probably just at start of cruise)
%     mrdefine('redo')
%
% mrgetrvdascontents.m        Get a list of the entire contents of the
%                               rvdas database (calling mrgettables and
%                               mrgettablevars): tables and variables  
% mrdef_mstarnames.m          Call mrdef_dirs_tables and apply its output
%                               to limit to tables with mstar definitions,
%                               and remove duplicate variables (same
%                               variable from same instrument read in via
%                               multiple messages) from the list
% mrdef_dirs_tables.m         This lists the translations between rvdas
%                               table names and mexec short names, as well
%                               as original and mexec names for variables
%                               to be loaded, and units where available
% mrdef_json.m                Load json files, run jsondecode, parse
%                               sentences and add units and longnames to
%                               lookup table  
% mrdef_rename_varsunits.m    A lookup function for regularising rvdas
%                               variable names and units to our preferred format (also corrects for known spelling errors, and produces a list of variables which should have _raw appended to their name). This may need to be edited at the start of a cruise but should eventually pass through many cruises unchanged.  
%
% % This file is called once per session (or if variables cleared)
% mrvdas_check_dbaccess       Check credentials, store status in global
%                             variable***


