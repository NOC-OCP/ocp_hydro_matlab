%%%%%%%%%% Warnings for unset options (called at end of get_cropt, after opt_cruise) %%%%%%%%%
switch scriptname
    
    %%%%%%%%%% castpars (not a script) %%%%%%%%%%
    case 'castpars'
        switch oopt
            case 'cal_stations'
                cvnames = intersect(fieldnames(cal_stations1),fieldnames(cal_stations2));
                for cvno = 1:length(cvnames)
                    ii = intersect(cal_stations1.(cvnames{cvno}),cal_stations2.(cvnames{cvno}));
                    if ~isempty(ii)
                        warning([cvnames{cvno} ' calibrations set to be applied in both ctd_all_part1 and ctd_all_postedit to stations:'])
                        disp(ii)
                    end
                end
                iserr1 = 0; iserr2 = 0;
                if isfield(ctdsens,'cond1')
                    if sum(size(ctdsens.temp1)~=size(ctdsens.cond1)) || sum(ctdsens.temp1(:)~=ctdsens.cond1(:))
                        iserr1 = 1;
                    end
                end
                if isfield(ctdens,'cond2')
                    if sum(size(ctdsens.temp2)~=size(ctdsens.cond2)) || sum(ctdsens.temp2(:)~=ctdsens.cond2(:))
                        iserr2 = 1;
                    end
                end
                errm = '';
                if iserr1
                    errm = [errm 'temp1 and cond1 sensor lists are not the same\n'];
                end
                if iserr2
                    errm = [errm 'temp2 and cond2 sensor lists are not the same\n'];
                end
                if ~isempty(errm)
                    errm = [errm 'check opt_cruise castpars, ctdsens'];
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
                        error('variable %s not found in either templates/sam_varlist.csv or in samvars_add from opt_%s', samvars_use{vno}, mcruise);
                    end
                end
        end
        %%%%%%%%%% end msam_01 %%%%%%%%%%
        
        %%%%%%%%%% mctd_02 %%%%%%%%%%
    case 'mctd_02'
        switch oopt
            case 'rawedit_auto'
                if castopts.redoctm
                    if isempty(castopts.pvars) && isempty(castopts.sevars) && isempty(castopts.revars) && isempty(castopts.sevars) && isempty(castopts.dsvars)
                        warning(['rerunning cell thermal mass correction on raw file for station ' stn_string 'but no raw edits are specified under mctd_02, editraw in opt_' mcruise])
                    end
                end
            case 'raw_corrs'
                if castopts.dooxyrev
                    if sum(sum(isnan(cell2mat(struct2cell(castopts.oxyrev)))))>0
                        error('oxygen hysteresis reversal parameters have NaNs; check opt_%s', mcruise)
                    end
                else
                    castopts = rmfield(castopts,'oxyrev');
                end
                if castopts.dooxyhyst
                    try
                        a = sum(sum(isnan(cell2mat(castopts.oxyhyst.H1)))) || sum(sum(isnan(cell2mat(castopts.oxyhyst.H2)))) || sum(sum(isnan(cell2mat(castopts.oxyhyst.H3))));
                        if a
                            error('oxygen hysteresis parameters have NaNs; check opt_%s', mcruise)
                        end
                    catch
                    end
                else
                    castopts = rmfield(castopts,'oxyhyst');
                end
                if ~castopts.doturbV
                    castopts = rmfield(castopts,'turbVpars');
                end
            case 'ctd_cals'
                if sum(cell2mat(struct2cell(castopts.docal)))>0
                    if ~isfield(castopts, 'calstr')
                        warning('mctd_02b found no calibration functions to apply in opt_%s', mcruise)
                    end
                end
                %other checking done in ctd_apply_calibrations
        end
        %%%%%%%%%% end mctd_02b %%%%%%%%%%
        
        %%%%%%%%%% mctd_03 %%%%%%%%%%
    case 'mctd_03'
        switch oopt
            case '24hz_edit'
                if ~isempty(switchscans24) && sum(strcmp('temp', switchscans24(:,1))) + sum(strcmp('cond', switchscans24(:,1))) == 1
                    warning('you have chosen to switch primary and secondary for either cond or temp but not both')
                    error('using T and C from different CTDs will lead to erroneous salinity; revise opt_cruise file ''mctd_03'', ''24hz_edit'' case')
                end
        end
        %%%%%%%%%% end mctd_03 %%%%%%%%%%
        
        %%%%%%%%%% msal_standardise_avg %%%%%%%%%%
    case 'msal_standardise_avg'
        switch oopt
            case 'plot_stations'
                if ~exist('iistno','var'); iistno = [1:length(stnos)]; end
            case 'std2use'
                if ~exist('std2use','var'); disp('set autosal standards readings to use for this cruise'); keyboard; end
            case 'sam2use'
                if ~exist('sam2use','var'); disp('set salinity sample readings to use for this cruise'); keyboard; end
        end
        %%%%%%%%%% end msal_standardise_avg %%%%%%%%%%
        
        %%%%%%%%%% miso_02 %%%%%%%%%%
    case 'miso_02'
        if ~exist('cvars','var'); warning(['must set cvars, list of isotope variable names to write, in miso_02 options']); end
        %%%%%%%%%% end miso_02 %%%%%%%%%%
        
        %%%%%%%%%% mday_01_fcal %%%%%%%%%%
    case 'mday_01_fcal'
        switch oopt
            case 'uway_factory_cal'
                if sum(strcmp(MEXEC_G.Mshipdatasystem,{'techsas' 'rvdas'})) && strcmp(abbrev,'surfmet') && ~exist('sensorcals','var')
                    warning('do factory calibrations need to be applied to your datastream? for techsas or rvdas surfmet, probably so')
                end
        end
        %%%%%%%%%% end mday_01_fcal %%%%%%%%%%
        
end % End of second "switch scriptname" to check for unset options
