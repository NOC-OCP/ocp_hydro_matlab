MATLAB scripts for a) at-sea processing, integration and primary quality control of CTD, water sample, and shipboard underway (via SCS, TECHSAS, or RVDAS systems) and integration with other data sources (e.g. ADCP); b) comparing and secondary QC, gridding/mapping, and plotting of hydrographic (CTD and bottle) data.
./

file_tools/

mexec_processing_scripts/
  scripts for standard mexec processing and calibration of CTD data
    m_setup.m sets paths and global variables -- run at start
    batch_*.m may be run on a set of stations
    ctd_all_*.m applies a set of steps to a single station
    m???_*.m (and msbe35_01.m) perform calculations on a single station
  see User Guide for more

mexec_processing_scripts/bottle_samples/
  scripts for standard mexec ingestion and processing of Niskin bottle sample data

mexec_processing_scripts/cruise_options/
  scripts to set defaults (setdef_cropt_*) and cruise-specific options (opt_*) used by other mexec scripts and functions

gridsec/
  scripts and functions for gridding and mapping data onto sections

mexec_processing_scripts/ladcp_scripts/
  scripts and functions for interfacing with LDEO IX and UH shear LADCP processing (external software)

mexec_processing_scripts/plots_output/
  scripts and functions for making plots and outputting summaries of data in other formats (e.g. WOCE exchange)

utilities/
  functions for commonly-performed operations on mexec data or files

mexec_processing_scripts/underway/
  scripts and functions for standard processing of underway data streams
  there are some extra functions for plotting still in here

varlists/
  lists of variable names and units for renaming (formerly templates/)


hydro_tools/
Scripts and functions for already-processed hydrographic station/section data (CTD, LADCP, water bottle sample profiles: loading, combining, gridding/mapping, plotting and comparing. 
