MATLAB scripts for a) at-sea processing, integration and primary quality control of CTD, water sample, and shipboard underway (via SCS, TECHSAS, or RVDAS systems) and integration with other data sources (e.g. ADCP); b) comparing and secondary QC, gridding/mapping, and plotting of hydrographic (CTD and bottle) data.
./

├── m_setup.m script to run first to set paths and global variables
│
├── docs/
│      documentation (Mexec user guide)
│
├── file_tools/
│      mostly just called by other scripts/functions
│
├── hydro_tools/
│     scripts and functions for already-processed hydrographic station/section data (CTD, LADCP, water bottle sample profiles: loading, combining, gridding/mapping, plotting and comparing. 
│       gridhsec.m is the wrapper function; specify cruise name
│       set_hsecpars.m switches on cruise name to set input files and other parameters for loading and gridding data
│ 
├── mexec_processing_scripts/
│   │  scripts for standard mexec processing and calibration of CTD data
│   │    *_all_*.m apply a set of steps to a single or multiple station(s)
│   │    m???_*.m (and msbe35_01.m) perform calculations on a single station
│   │    see User Guide for more
│   │
│   ├── adcp_scripts/
│   │     scripts and functions for interfacing with LADCP and VMADCP data processed using external software (LDEO IX and UH shear; CODAS)
│   │
│   ├── bottle_samples/
│   │     scripts for standard mexec ingestion and processing of Niskin bottle sample data
│   │	
│   ├── cruise_options/
│   │     scripts to set defaults (setdef_cropt_*) and cruise-specific options (opt_*) used by other mexec scripts and functions
│   │	
│   │	
│   ├── plots_output/
│   │  scripts and functions for making plots and outputting summaries of data in other formats (e.g. WOCE exchange)
│   │
│   ├── remedies/
│   │	  not part of standard processing path, but useful if something has changed (e.g. new header info) and you need to edit, or has gone wrong and you need to regenerate files
│   │
│   ├── renovate/
│   │	  these (probably) aren't currently working! to be reviewed for renovation or discard
│   │
│   ├── underway/
│   │	  scripts and functions for standard processing of underway data streams
│   │
│   ├── varlists/
│         lists of variable names and units for renaming (formerly templates/)
│   
├── utilities/
│     functions for operations on mexec-style data structures (e.g. grid_profile, hdata_flagnan), as well as generally-useful functions (e.g. m_nanmean, a replacement for matlab's nanmean)


