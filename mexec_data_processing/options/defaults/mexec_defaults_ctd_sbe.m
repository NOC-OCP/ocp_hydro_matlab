switch opt2
    %lines to be added to opt_cruise file, under opt1 = 'ctd_proc' by
    %create_opt_cruise, if MEXEC_G.datatypes.ctd = 'sbe' 
    case 'ctd_infiles'
        foundit = true;
        helptext = 'specify input .cnv file pattern to be resolved using stn_string';
        %set patterns for input file paths and names (including %s
        %to be filled with stn_string as set by setup,
        %m_stn_string case above)
        infiles.ctd_raw = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', ['CTD_' MEXEC_G.mcruise '_%s.cnv']); %stn_string
    case 'rawedit_auto'
        foundit = true;
        %when pumps are off
        co.pumpsNaN.temp1 = 12; %based on jc159, T takes 1/2 s to recover
        co.pumpsNaN.temp2 = 12;
        co.pumpsNaN.cond1 = 12;
        co.pumpsNaN.cond2 = 12;
        co.pumpsNaN.oxy1 = 8*24; %based on jc159, O takes 8 s to recover
        co.pumpsNaN.oxy2 = 8*24;
    case 'raw_corrs'
        foundit = true;
        sbe_ctd_coeffs %set co.hyst_oxy0 and co.pumpsNaN
        co.dpoff_calc = 1; %try to calculate deck pressure from start of record
        co.dpoff_checked = []; %list of 
        % number of seconds to shift oxygen earlier, based on delay in membrane response (varies from 1-8 S partially depending on temperature)
        co.oxy_align = 2; %check hysteresis first?
        co.doturbV = 0; %don't recalculate turbidity from V
        %unusual: set dooxy1V or dooxy2V to 1 or 2 to recalculate using
        %temp1 or temp2
        co.dooxy1V = 0; co.dooxy2V = 0;
        %set re_dooxyhyst = 1 to apply oxygen hysteresis correction
end
