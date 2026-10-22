function [nu, ut, nn] = mcvars_rephrase(datatype)
%do some renaming, within msbe_to_mstar
%eventually join this with munderway_varname, mrdef_rename_varsunits, etc.
%because much of the code/conventions should be shared

%units to remove from names
        nu = {'Mm/Kg', 'umol/kg';
            'Mm/L', 'umol/L';
            'mS/cm', 'mS/cm';
            'S/m', 'S/m';
            '90C', 'deg C (ITS-90)';
            '68C', 'deg C (ITS-68)'};
        %units to rephrase
        ut = {'db', 'dbar';
            'salt water, m', 'm';
            'deg', 'degrees';
            '%', 'percent'
            };

        switch datatype
            case 'ctd_sbe'
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
            'CStarAt0', 'attenuation'
            'turbWETbb0', 'turbidity' %m^-1/sr
            'turbWETntu0', 'turbidity' %NTU
            'par/sat/log', 'par' %umol photons/m^2/sec
            'par', 'par'
            'cpar', 'par_corrected'
            'spar', 'surface_irradiance'
            %'par1', 'par_downlook'
            };
            otherwise 
                nn = {'nothing defined yet'}; %not defined
        end
