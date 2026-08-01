%sets CTD processing parameters based on SBE defaults or typical SBE
%response
%called from mexec_defaults_all in case opt1 = 'ctd_proc', 
% if MEXEC_G.ctd = 'sbe' 

if ~strcmp(opt1,'ctd_proc') || ~strcmp(MEXEC_G.datatypes.ctd,'sbe')
    error('this file should only be called when ctd type is SBE and to get options for ctd_proc case')

else
    switch opt2

        case 'ctdvarsunits'
            %do some renaming, within msbe_to_mstar
            %units to remove from names
            nu = {'Mm/Kg', 'umol/kg';
                'Mm/L', 'umol/L';
                'mS/cm', 'mS/cm';
                'S/m', 'S/m';
                '90C', 'deg C (ITS-90)'; 
                '68C', 'deg C (ITS-68)'};
            %units to reformat
            ut = {'db', 'dbar';
                'salt water, m', 'm';
                'deg', 'degrees';
                '%', 'percent'
                };
            %names (after applying nu) to change to standard names for
            %(but listed in header)
            nn = {'pumps', 'pumps'
                'latitude', 'latitude'
                'longitude', 'longitude'
                'scan', 'scan'
                'spar', 'spar'
                'prDM', 'press'
                't0', 'temp1'
                't1', 'temp2'
                'altM', 'altimeter'
                'ptempC', 'pressure_temp'
                'timeS', 'time'
                'c0', 'cond1'
                'c1', 'cond2'
                'sbeox0', 'oxy1'
                'sbox0', 'oxy1'
                'sbeox1', 'oxy2'
                'sbox1', 'oxy2'
                'sbeox0V', 'sbe_oxygen1V'
                'sbeox1V', 'sbe_oxygen2V'
                'flECO-AFL', 'fluor'
                'flC', 'fluor' %ug/l?
                'wetStar', 'fluor'
                'wetCDOM', 'fluor_cdom'
                'xmiss', 'transmittance'
                'CStarTr0', 'transmittance'
                'CstarAt0', 'attenuation'
                'turbWETbb0', 'turbidity' %m^-1/sr
                'turbWETntu0', 'turbidity' %NTU
                'par/sat/log', 'par' %umol photons/m^2/sec
                %'par1', 'par_downlook'
                };
            
        case 'rawedit_auto'
            %when pumps are off
            co.pumpsNaN.temp1 = 12; %T takes 1/2 s to recover
            co.pumpsNaN.temp2 = 12;
            co.pumpsNaN.cond1 = 12;
            co.pumpsNaN.cond2 = 12;
            co.pumpsNaN.oxy1 = 8*24; %O takes 8 s to recover
            co.pumpsNaN.oxy2 = 8*24;

        case 'raw_corrs'
            co.oxy_align = 6; %number of seconds to shift oxygen earlier
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

