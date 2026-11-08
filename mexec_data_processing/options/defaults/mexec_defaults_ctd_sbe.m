switch opt2
    %lines to be added to opt_cruise file, under opt1 = 'ctd_proc' by
    %create_opt_cruise, if MEXEC_G.datatypes.ctd = 'sbe' 
    case 'ctd_infiles'
        foundit = true;
        helptext = 'specify input .cnv, .bl or .btl, and SBE35 files using stn_string';
        %set patterns for input file paths and names (either including %s
        %to be filled with stn_string, or with wildcards to be used by dir
        %function)
        infiles.ctd_raw = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', ['CTD_' MEXEC_G.mcruise '_%s.cnv']); %stn_string
        infiles.ctd_nisk_fir = fullfile(MEXEC_G.data_root, 'ctd', 'ASCII_FILES', ['CTD_' MEXEC_G.mcruise '_%s.bl']); %stn_string
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
        co.dpoff_calc = 1; %try to calculate deck pressure from start of record
        co.dpoff_checked = []; %list of 
        % number of seconds to shift oxygen earlier, based on delay in membrane response (varies from 1-8 S partially depending on temperature)
        co.oxy_align = 2; %check hysteresis first?
        co.doturbV = 0; %don't recalculate turbidity from V
        %unusual: set dooxy1V or dooxy2V to 1 or 2 to recalculate using
        %temp1 or temp2
        co.dooxy1V = 0; co.dooxy2V = 0;
        %set re_dooxyhyst = 1 to apply oxygen hysteresis correction
        %hyst_oxy0 if not already applied in SBE processing, then undo and
        %redo using user-supplied hyst_oxy 
        %SBE defaults are: H1 = -0.033, H2 = 5000, H3 = 1450
        %change hyst_oxy0 if you have applied different values *before
        %mexec processing*
        co.hyst_oxy0.H1 = -0.033;
        co.hyst_oxy0.H2 = 5000;
        co.hyst_oxy0.H3 = 1450;
        co.hrev_oxy0 = co.hyst_oxy0;
end
