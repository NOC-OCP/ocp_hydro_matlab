%sets CTD processing parameters based on SBE defaults or typical SBE
%response
%called from mexec_defaults_all in case opt1 = 'ctd_proc', 
% if MEXEC_G.ctd = 'sbe' 

if ~strcmp(opt1,'ctd_proc') || ~strcmp(MEXEC_G.datatypes.ctd,'sbe')
    error('this file should only be called when ctd type is SBE and to get options for ctd_proc case')

else
    switch opt2

        case 'rawedit_auto'
            %when pumps are off
            co.pumpsNaN.temp1 = 12; %T takes 1/2 s to recover
            co.pumpsNaN.temp2 = 12;
            co.pumpsNaN.cond1 = 12;
            co.pumpsNaN.cond2 = 12;
            co.pumpsNaN.oxy1 = 8*24; %O takes 8 s to recover
            co.pumpsNaN.oxy2 = 8*24;

        case 'raw_corrs'
            if ~doneco.alignctd
                co.oxy_align = 6; %number of seconds to shift oxygen earlier
            end
            co.doturbV = 0;
            co.dooxy1V = 0; co.dooxy2V = 0; %make 1 or 2 to recalculate using temp1 or temp2
            co.redooxyhyst = 0;
            %SBE defaults
            co.hyst_oxy0.H1 = -0.033;
            co.hyst_oxy0.H2 = 5000;
            co.hyst_oxy0.H3 = 1450;
            co.hrev_oxy0 = co.hyst_oxy0;

    end

end

