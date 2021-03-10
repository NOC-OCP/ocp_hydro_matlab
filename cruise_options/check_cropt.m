%%%%%%%%%% Warnings for unset options (called at end of get_cropt, after opt_cruise) %%%%%%%%%
switch scriptname
    
    %%%%%%%%%% castpars (not a script) %%%%%%%%%%
    case 'castpars'
        switch oopt
            case 'cal_stations'
                cvnames = intersect(fieldnames(cal_stations1),fieldnames(cal_stations2));
                for cvno = 1:length(cvnames)
                    ii = intersect(cal_stations1.(cvnames{cvno}),cal_stations2.(cvnames{cvno}));
                    if length(ii)>0
                        warning([cvnames{cvno} ' calibrations set to be applied in both ctd_all_part1 and ctd_all_postedit to stations:'])
                        disp(ii)
                    end
                end
        end
        %%%%%%%%%% end castpars (not a script) %%%%%%%%%%
       
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
            case 'ctdcals'
                if isempty(calstr)
                    warning(sprintf('mctd_02b found no calibration functions to apply in opt_%s', mcruise));
                    return
                
                else
                    
                    for sno = 1:size(calstr,1)
                        
                        %test for correct calmsg matching calstr
                        iis = strfind(calmsg{sno,1},[' ' mcruise]);
                        calsens_expect = calmsg{sno,1}(1:iis-1);
                        if ~strncmp(['dcal.' calsens_expect], calstr{sno}, length(calsens_expect)+5)
                            error(sprintf('based on calmsg, calstr row %d should start with %s; check opt_%s and try again',sno,calsens_expect,mcruise));
                        end
                        calmsg_expect = sprintf('%s %s',calsens_expect,mcruise);
                        if ~strcmp(calmsg{sno,1}, calmsg_expect)
                            error(sprintf('opt_%s calmsg row %d: %s does not match cruise expected: %s; check and try again',mcruise,sno,calmsg{sno,1},calmsg_expect))
                        end
                        
                        if strncmp(calsens_expect, 'cond', 4)
                            %check that if cond cal depends on temp it's from the same CTD
                            csens = str2num(calsens_expect(end));
                            if ~isempty(csens)
                                iit = findstr('temp',calstr{sno});
                                if length(iit)>0
                                    tsens = str2num(calstr{sno}(iit+4)');
                                    tsens(tsens==csens) = [];
                                    if length(tsens)>0
                                        error(sprintf('calibration of conductivity from CTD %d should not depend on temperature from CTD %d; check opt_%s and try again',csens,tsens,mcruise));
                                    end
                                end
                            end
                        elseif strncmp(calsens_expect, 'oxygen', 6)
                            %check that ocal uses temp from same ctd, but don't require it
                            osens = str2num(calsens_expect(end));
                            if ~isempty(osens)
                                iit = findstr('temp',calstr{sno});
                                if length(iit)>0
                                    tsens = str2num(calstr{sno}(iit+4)');
                                    tsens(tsens==osens) = [];
                                    if length(tsens)>0
                                        warning(sprintf('calibration of oxygen sensor %d is being based on temperature from CTD %d'),osens,tsens)
                                    end
                                end
                            end
                        end
                        
                    end
                    
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
