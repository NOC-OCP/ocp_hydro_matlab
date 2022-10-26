## ocp_hydro_matlab

==============================

MATLAB scripts for:  
a) at-sea processing, integration and primary quality control of CTD, water sample, and shipboard underway (via SCS, TECHSAS, or RVDAS systems) and integration with other data sources (e.g. ADCP);   
b) comparing and secondary QC, gridding/mapping, and plotting of hydrographic (CTD and bottle) data.

### Organization

    ├── LICENSE
    ├── README.md        
    │
    ├── m_setup.m                  <- run this first to set paths and global variables
    │
    ├── docs                       <- mexec user guide
    │
    ├── file_tools                 <- mostly just called by other scripts/functions
    │   ├── mexec                  <- specifically for interacting with mexec .nc files and data history logs
    │   └── pstar                  <- for converting from old pstar format
    │
    ├── hydro_tools                <- for gridding and plotting of historical (already-processed) hydrographic (CTD and bottle sample) data 
    │   ├── gridhsec.m             <- top-level wrapper function
    │   └── set_hsecpars.m         <- example file giving parameters for multiple cruises/sections
    │
    ├── mexec_processing_scripts   <- processing of CTD, bottle sample, and underway data
    │   ├── ctd_all_*.m            <- wrappers to apply a set of steps to one or more station(s), calling:
    │   ├── m???_*.m               <- calculations on a single station
    │   │
    │   ├── adcp_scripts           <- interface with LDEO IX LADCP and CODAS VMADCP processing
    │   │
    │   ├── bottle_samples         <- ingest bottle sample data
    │   │
    │   ├── cruise_options         <- cruise-specific processing options (e.g. averaging options, calibration coefficients)
    │   │   ├── get_cropt.m        <- wrapper
    │   │   ├── setdef_cropt_*.m   <- defaults
    │   │   └── opt_*.m            <- one per cruise
    │   │
    │   ├── plots_output           <- diagnostic/summary plots, or output data in other formats (e.g. WOCE exchange)
    │   │
    │   ├── remedies               <- not part of standard processing path, use if files need to be specially edited or processing restarted
    │   │
    │   ├── rennovate              <- temporary storage for scripts that may not be working with current version (to be reviewed for update or discard)
    │   │
    │   ├── underway               <- standard processing of underway data streams
    │   │   └── m_daily_proc.m     <- wrapper
    │   │
    │   └── varlists               <- mappings between variable name (and units) schemas
    │
    └── utilities                  <- functions called by others
        ├── general                <- don't require specific data input format
        ├── mexec                  <- work on mexec-style data structures
        └── profile_tools          <- calculations specific to CTD profiles


