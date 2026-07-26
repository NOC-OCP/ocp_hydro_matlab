%sets CTD processing parameters based on SBE defaults or typical SBE
%response
%if relevant, put this at the top of your opt_{cruise}.m file, to be run
%after mexec_defaults_all.m and before the rest of the contents of
%opt_{cruise}.m

        switch opt2
            case 'oxy_align'
                oxy_align = 6; %number of seconds by which oxygen has been shifted in SBE processing (or should be shifted by mctd_02)
                oxy_end = 1; %set to 1 to truncate O oxy_align seconds earlier than T, C
                %mctd_01
            case 'rawedit_auto'
                %when pumps are off
                co.pumpsNaN.temp1 = 12; %T takes 1/2 s to recover
                co.pumpsNaN.temp2 = 12;
                co.pumpsNaN.cond1 = 12;
                co.pumpsNaN.cond2 = 12;
                co.pumpsNaN.oxygen_sbe1 = 8*24; %O takes 8 s to recover
                co.pumpsNaN.oxygen_sbe2 = 8*24;
        end
    case 'raw_corrs'
        %SBE defaults
        oxyhyst.H1 = -0.033;
        oxyhyst.H2 = 5000;
        oxyhyst.H3 = 1450;
        oxyrev = oxyhyst;
        co.H_0 = [oxyhyst.H1 oxyhyst.H2 oxyhyst.H3]; %stores defaults for later reference
