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
    ├── docs                       <- mexec user guide (for at-sea processing) and mapping guide (for gridding CTD and bottle profiles/sections)
    │
    ├── hydro_grid_compare                <- for gridding and plotting of historical (already-processed) hydrographic (CTD and bottle sample) data 
    │   ├── gridhsec.m             <- top-level wrapper function
    │   └── set_hsecpars.m         <- example file giving parameters for multiple cruises/sections
    │
    ├── mexec_processing_scripts   <- processing of CTD, bottle sample, and underway data. the user interacts with the scripts in wrappers/ and options/
    │   │
    │   ├── processing_steps       <- steps acting on data from one or more sources, called by the scripts in wrappers/
    │   │
    │   ├── options                <- scripts setting sensor-, parameter-, and/or cruise-specific processing options (e.g. averaging, calibration coefficients, etc.)
    │   │   ├── cruise_opt_scripts <- scripts from individual cruises, including past cruises
    │   │   ├── defaults           <-
    │   │   │   ├── mexec_defaults_all.m <- defaults
    │   │   │   ├── mexec_defaults_noc.m <- defaults
    │   │   │   └── mexec_defaults_sbe.m <- defaults
    │   │   ├── generate_cruise_opt_script.m   <- defaults
    │   │   ├── get_cropt.m   <- defaults
    │   │   └── parse_scripts_display_options.m <- help
    │   │
    │   ├── wrappers               <- wrapper scripts for processing different types of data through different stages
    │   │   ├── adcp_process.m     <- LADCP profiles, optionally with SADCP; sets up for and calls LDEO IX for LADCP processing, and reads in CODAS-processed SADCP
    │   │   ├── ctd_process.m      <- CTD profiles, with different options depending on stage(s). SBE/some RBR
    │   │   ├── samp_process.m     <- bottle sample data
    │   │   └── uway_process.m     <- underway time series (nav, met, surface ocean, and [centre beam] bathymetry)
    │   │
    │   └── tools               <- mappings between variable name (and units) schemas
    │       ├── conventions
    │       ├── inspect_edit
    │       └── summaries_output
    │
    └── utilities            
        ├── calculations     
        ├── carter_ssc       
        ├── ctd_profile_tools
        ├── data_tools
        ├── file_tools
        ├── function_tools
        ├── grid_1D
        ├── mexec
        └── plots


./*_process.m are wrapper functions

in ctd_steps, *_01_* can be done in parallel, but mfir_05_* must be done after all *_01*, *_02*, *_03*, *_04*

ctd processing is done one station at a time (***mctd_checkplots, mctd_evaluate_sensors)

sample processing is done on all available data

underway processing is done one day at a time (or can loop)

cruise_options/ has scripts used by many scripts/functions for setting cruise-specific processing parameters and choices
