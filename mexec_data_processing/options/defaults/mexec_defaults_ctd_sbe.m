switch opt2
    %lines to be added to opt_cruise file, under opt1 = 'ctd_proc' by
    %create_opt_cruise, if MEXEC_G.datatypes.ctd = 'sbe' 
    case 'ctd_infiles'
        foundit = true;
        helptext = 'specify input .cnv file pattern to be resolved using stn_string';
        %set patterns for input file paths and names (including %s
        %to be filled with stn_string as set by setup,
        %m_stn_string case above)
        infiles.ctd_raw = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', ['CTD_' MEXEC_G.mcruise '_stn_string.cnv']); %stn_string
    case 'raw_edits_corrs'
        foundit = true;
        sbe_ctd_coeffs %set co.hyst_oxy0 and co.pumpsNaN
        co.dpoff_calc = 60; %try to calculate deck pressure from first 60 s of record, when it is assumed to be stable on deck
        co.dpoff_checked = []; %list of 
        % number of seconds to shift oxygen earlier, based on delay in membrane response (varies from 1-8 S partially depending on temperature)
        co.oxy_align = 2; %check hysteresis first?
        co.doturbV = 0; %don't recalculate turbidity from V
        %unusual: set dooxy1V or dooxy2V to 1 or 2 to recalculate using
        %temp1 or temp2
        co.dooxy1V = 0; co.dooxy2V = 0;
        %apply default oxygen hysteresis correction (if it was already applied in SBE processing, and no new coefficients are supplied, this will be skipped)
        co.re_dooxyhyst = 1;
        co.hyst_oxy1 = co.hyst_oxy0; 
        co.hyst_oxy2 = co.hyst_oxy0;
end
