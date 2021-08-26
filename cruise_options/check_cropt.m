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
            case 'ctdsens_groups'
                iit = find(strcmp('temp1',ctdsens_groups(:,1)));
                iis = find(strcmp('cond1',ctdsens_groups(:,1)));
                iserr1 = 0;
                if length(ctdsens_groups{iit,2})==length(ctdsens_groups{iis,2})
                    for no = 1:length(ctdsens_groups{iit,2})
                        if length(ctdsens_groups{iit,2}{no})~=length(ctdsens_groups{iis,2}{no}) || min(ctdsens_groups{iit,2}{no}==ctdsens_groups{iis,2}{no})==0
                            iserr1 = 1;
                        end
                    end
                else
                    iserr1 = 1;
                end
                iit = find(strcmp('temp2',ctdsens_groups(:,1)));
                iis = find(strcmp('cond2',ctdsens_groups(:,1)));
                iserr2 = 0;
                if length(ctdsens_groups{iit,2})==length(ctdsens_groups{iis,2})
                    for no = 1:length(ctdsens_groups{iit,2})
                        if length(ctdsens_groups{iit,2}{no})~=length(ctdsens_groups{iis,2}{no}) || min(ctdsens_groups{iit,2}{no}==ctdsens_groups{iis,2}{no})==0
                            iserr2 = 1;
                        end
                    end
                else
                    iserr2 = 1;
                end
                errm = '';
                if iserr1
                    errm = [errm 'temp1 and cond1 sensor lists are not the same\n'];
                end
                if iserr2
                    errm = [errm 'temp2 and cond2 sensor lists are not the same\n'];
                end
                if ~isempty(errm)
                    errm = [errm 'check opt_cruise castpars, ctdsens_groups'];
                    warning(errm)
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
                if ~exist('calstr', 'var')
                    if sum(cell2mat(struct2cell(docal)))>0
                        warning(sprintf('mctd_02b found no calibration functions to apply in opt_%s', mcruise));
                    end
                else
                    calsens = fieldnames(calstr);
                    if length(unique(calsens))<length(calsens)
                        error(['duplicate sensor calibration functions found, check opt_' mcruise 'mctd_02b case'])
                    end
                    for sno = 1:length(calsens)
                        if ~isfield(calstr.(calsens{no}),mcruise)
                            warning(['calibration for ' calsens{no} ' not from this cruise; skipping'])
                        else
                            calf = calstr.(calsens{no}).(mcruise);
                            if strncmp(calsens{no}, 'cond', 4)
                                sensnum = calsens{no}(5);
                                iit = find(strcmp('temp', calf));
                                if ~isempty(iit)
                                    tnum = str2num(calf(iit+4)');
                                    if sum(tnum~=sensnum)>0
                                        error(['calibration for ' calsens{no} ' appears to depend on other CTD temp'])
                                    end
                                end
                            elseif strncmp(calsens{no}, 'oxygen', 6)
                                sensnum = calsens{no}(7);
                                iit = find(strcmp('temp', calf));
                                iit = [iit find(strcmp('cond', calf))];
                                if ~isempty(iit)
                                    tnum = str2num(calf(iit+4)');
                                    if sum(tnum~=sensnum)>0
                                        warning(['calibration for ' calsens{no} ' appears to depend on other CTD temp or cond'])
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
