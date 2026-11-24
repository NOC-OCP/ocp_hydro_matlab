switch opt2
    %lines to be added to opt_cruise file, under opt1 = 'ctd_proc' by
    %create_opt_cruise, if MEXEC_G.datatypes.nisk = 'sbe'
    case 'nisk_infiles'
        foundit = true;
        helptext = 'specify input .bl or .btl file pattern to be resolved using stn_string';
        %set patterns for input file paths and names (including %s
        %to be filled with stn_string as set by setup,
        %m_stn_string case above)
        infiles.ctd_nisk_fir = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', ['CTD_' MEXEC_G.mcruise '_stn_string.bl']); %stn_string
end
