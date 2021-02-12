%%%%%%%%%% Warnings for unset options (called at end of get_cropt, after opt_cruise) %%%%%%%%%
switch scriptname
    
        %%%%%%%%%% msam_01 %%%%%%%%%%
    case 'msam_01'
        switch oopt
            case 'samvars'
                if sum([strcmp(samvars_replace,'sampnum');strcmp(samvars_replace,'statnum');strcmp(samvars_replace,'position')])>0
                    warning('are you sure you want to change units or default value for sampnum, statnum, or position?')
                end
                for vno = 1:length(samvars_use)
                    if sum(strcmp([ds_sam.varname; samvars_add(:,1)], samvars_use{vno}))==0
                        error(sprintf('variable %s not found in either templates/sam_varlist.csv or in samvars_add from opt_%s', samvars_use{vno}, mcruise));
                    end
                end
        end
        %%%%%%%%%% end msam_01 %%%%%%%%%%

        %%%%%%%%%% mctd_02a %%%%%%%%%%
    case 'mctd_02a'
        switch oopt
            case 'prectm_rawedit'
                if redoctm & length(pvars)+length(sevars)+length(revars)+length(dsvars)==0
                    warning(['rerunning cell thermal mass correction on raw file for station ' stn_string 'but no raw edits are specified under mctd_02a, editraw in opt_' mcruise])
                end
        end
        %%%%%%%%%% end mctd_02a %%%%%%%%%%
        
        %%%%%%%%%% mctd_02b %%%%%%%%%%
    case 'mctd_02b'
        switch oopt
            case {'oxyrev' 'oxyhyst'}
                if sum(isnan(H1))+sum(isnan(H2))+sum(isnan(H3))>0
                    error(['oxygen hysteresis parameters have NaNs; check opt_' mcruise])
                end
        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case '24hz_edit'
                if length(switchscans24)>0 & sum(strcmp('temp', switchscans24(:,1))) + sum(strcmp('cond', switchscans24(:,1))) == 1
                    warning('you have chosen to switch primary and secondary for either cond or temp but not both')
                    error('using T and C from different CTDs will lead to erroneous salinity; revise opt_cruise file ''mctd_03'', ''24hz_edit'' case')
                end
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'plot_stations'
                if ~exist('iistno'); iistno = [1:length(stnos)]; end
            case 'std2use'
                if ~exist('std2use'); disp('set autosal standards readings to use for this cruise'); keyboard; end
            case 'sam2use'
                if ~exist('sam2use'); disp('set salinity sample readings to use for this cruise'); keyboard; end
        end
        %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%
        
        %%%%%%%%%% mctd_senscal %%%%%%%%%%
    case 'mctd_senscal'
        %check that expected variable name and (where relevant) sensor
        %number is being used, that calmsg has been updated to the correct
        %variable/sensor/cruise (hopefully this will catch in case of
        %copy-pasting in from previous cruise and without updating
        %parameters), and that cond cal is not using temperature from a
        %different CTD (just warn if oxy cal is)
        if isempty(calvars) | isempty(calstr)
            warning(sprintf('mctd_senscal finds no %s calibration function to apply in opt_%s', oopt, mcruise));
            return
        end
        if exist('senslocal', 'var')
            calsens_expect = [oopt num2str(senslocal)];
        else
            calsens_expect = oopt;
        end
        if ~strcmp(calsens_expect, calvars{1})
            error(sprintf('first element of calvars, %s, should be %s; check opt_%s and try again',calvars{1},calsens_expect,mcruise));
        end
        calmsg_expect = sprintf('%s %s',calsens_expect,mcruise);
        if ~strcmp(calmsg, calmsg_expect)
            error(['opt_' mcruise ' calmsg: ' calmsg ' does not match variable/sensor/cruise expected: ' calmsg_expect '; check and try again'])
        end
        switch oopt
            case 'condcal'
                %also check that if it depends on temp it's from the same CTD
                iit = find(strncmp('temp',calvars,4));
                if length(iit)==0
                    tsens = senslocal;
                elseif length(iit)==1
                    tsens = calvars{iit}(end);
                end
                if length(iit)>1 | tsens~=senslocal
                    error(sprintf('calibration of conductivity from CTD %d should not depend on temperature from CTD %d; check opt_%s and try again',senslocal,tsens,mcruise));
                end
            case 'oxygencal'
                iit = find(strncmp('temp',calvars,4));
                if length(iit)==0
                    tsens = senslocal;
                elseif length(iit)==1
                    tsens = calvars{iit}(end);
                end
                if length(iit)>1 | tsens~=senslocal
                    warning(sprintf('calibration of oxygen sensor %d is being based on temperature from CTD %d'),senslocal,tsens)
                end
        end
        %%%%%%%%%% end mctd_senscal %%%%%%%%%%
        
        %%%%%%%%%% miso_02 %%%%%%%%%%
    case 'miso_02'
        if ~exist('cvars'); warning(['must set cvars, list of isotope variable names to write, in miso_02 options']); end
        %%%%%%%%%% end miso_02 %%%%%%%%%%
        
        %%%%%%%%%% mday_01_fcal %%%%%%%%%%
    case 'mday_01_fcal'
        switch oopt
            case 'uway_factory_cal'
                if sum(strcmp(MEXEC_G.Mshipdatasystem,{'techsas' 'rvdas'})) & length(sensors_to_cal)==0
                    warning('do factory calibrations need to be applied to your datastream? for techsas and scs surfmet, probably so')
                end
        end
        %%%%%%%%%% end mday_01_fcal %%%%%%%%%%
        
end % End of second "switch scriptname" to check for unset options
